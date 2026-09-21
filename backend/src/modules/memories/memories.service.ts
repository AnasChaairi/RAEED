import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';

export type ImageRightsLevel = 'allowed' | 'app_only' | 'not_allowed';
export type ModerationMode = 'publish_then_moderate' | 'approve_before_publish';

export interface ReviewPostView {
  id: string;
  album: { id: string; title: string; group_name: string | null; moderation_mode: ModerationMode };
  author_name: string;
  author_id: string;
  created_at: string;
  media_count: number;
  media_kind: 'photo' | 'video' | 'banner';
  /** Media URLs need the storage service; null until it exists. */
  thumbnail_url: null;
  tags: Array<{ child_id: string; full_name: string; image_rights_level: ImageRightsLevel }>;
  moderation_status: 'pending' | 'published' | 'hidden';
  is_blocked: boolean;
}

export interface ReviewQueueView {
  /** The one mode every album in scope runs under, or null when unset or mixed. */
  moderation_mode: ModerationMode | null;
  data: ReviewPostView[];
}

export interface AlbumView {
  id: string;
  title: string;
  post_count: number;
  group_name: string | null;
  cover_url: null;
  moderation_mode: ModerationMode;
}

interface PostRow {
  id: string;
  created_at: Date;
  moderation_status: ReviewPostView['moderation_status'];
  hidden_reason: string | null;
  media_kind: ReviewPostView['media_kind'];
  author_id: string;
  album_id: string;
  album_title: string;
  moderation_mode: ModerationMode;
  group_name: string | null;
  branch_id: string | null;
  tags: ReviewPostView['tags'];
}

/**
 * The Memories Wall moderation queue (EXEC-M-04, `WAL-06`).
 *
 * Every tagged child's *current* image-rights level is resolved from the
 * latest `consent_record` at read time and again at approval time, because
 * consent changes between the two — testing-strategy case 4 is exactly a
 * post whose tagged child's guardian later said no. Hiding never deletes.
 *
 * The moderation mode is the album's, reported as stored. The app never
 * defaults it: which mode the association runs is open decision #3.
 */
@Injectable()
export class MemoriesService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  async reviewQueue(user: AuthenticatedUser): Promise<ReviewQueueView> {
    this.assertOversight(user);
    const scope = this.scopeOf(user);

    const rows = await this.posts(
      `p.deleted_at is null
       and (p.moderation_status = 'pending'
            or (p.moderation_status = 'hidden' and p.hidden_reason = 'consent_blocked'))
       ${scope.clause}`,
      scope.params,
      'order by p.created_at, p.id',
    );

    const modes: Array<{ moderation_mode: ModerationMode }> =
      await this.dataSource.query(
        `select distinct a.moderation_mode
           from album a
           left join "group" g on g.id = a.group_id
          where true ${scope.clause}`,
        scope.params,
      );

    return {
      moderation_mode: modes.length === 1 ? modes[0].moderation_mode : null,
      data: rows.map((row) => this.toView(row)),
    };
  }

  async albums(user: AuthenticatedUser): Promise<AlbumView[]> {
    this.assertOversight(user);
    const scope = this.scopeOf(user);
    const rows: AlbumView[] = await this.dataSource.query(
      `select a.id, a.title, a.moderation_mode, g.name as group_name,
              null as cover_url,
              (select count(*) from post p
                where p.album_id = a.id and p.deleted_at is null
                  and p.moderation_status = 'published')::int as post_count
         from album a
         join season se on se.id = a.season_id and se.status = 'active'
         left join "group" g on g.id = a.group_id
        where true ${scope.clause}
        order by a.created_at desc`,
      scope.params,
    );
    return rows;
  }

  /**
   * Publishes a pending post, or re-publishes a blocked one.
   *
   * The consent re-check runs here, not on the device: a child whose
   * guardian withdrew image rights since the queue was fetched is refused
   * with `memories.consent_blocked` naming them.
   */
  async approve(user: AuthenticatedUser, postId: string): Promise<void> {
    const post = await this.loadForModeration(user, postId);

    const blocked = post.tags
      .filter((tag) => tag.image_rights_level === 'not_allowed')
      .map((tag) => tag.child_id);
    if (blocked.length > 0) throw ApiError.memoriesConsentBlocked(blocked);

    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update post set moderation_status = 'published', hidden_reason = null
          where id = $1`,
        [post.id],
      );
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'post.approve', 'post', $2, $3::jsonb)`,
        [user.id, post.id, JSON.stringify({ from: post.moderation_status })],
      );
    });
  }

  /** Hides a post. The row, its media and its tags all stay. */
  async hide(user: AuthenticatedUser, postId: string): Promise<void> {
    const post = await this.loadForModeration(user, postId);
    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update post set moderation_status = 'hidden', hidden_reason = 'moderation'
          where id = $1`,
        [post.id],
      );
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'post.hide', 'post', $2, $3::jsonb)`,
        [user.id, post.id, JSON.stringify({ from: post.moderation_status })],
      );
    });
  }

  private async loadForModeration(
    user: AuthenticatedUser,
    postId: string,
  ): Promise<PostRow> {
    const rows = await this.posts('p.id = $1 and p.deleted_at is null', [postId], '');
    const post = rows[0];
    if (!post) throw ApiError.scopeForbidden('No such post, or not yours.');

    const ability = defineAbilityFor(user);
    const resource = subject('MemoriesPost', { id: post.id, branchId: post.branch_id });
    if (!user.hasOversight || !ability.can('manage', resource)) {
      throw ApiError.scopeForbidden();
    }
    return post;
  }

  private posts(where: string, params: unknown[], orderBy: string): Promise<PostRow[]> {
    return this.dataSource.query(
      `select p.id, p.created_at, p.moderation_status, p.hidden_reason, p.media_kind,
              p.author_id,
              a.id as album_id, a.title as album_title, a.moderation_mode,
              g.name as group_name, g.branch_id,
              coalesce((
                select json_agg(json_build_object(
                         'child_id', c.id,
                         'full_name', c.full_name,
                         'image_rights_level', coalesce((
                           select cr.level from consent_record cr
                            where cr.child_id = c.id and cr.type = 'image_rights'
                            order by cr.effective_at desc, cr.created_at desc
                            limit 1), 'not_allowed'))
                       order by c.full_name)
                  from post_tag pt
                  join child c on c.id = pt.child_id and c.deleted_at is null
                 where pt.post_id = p.id), '[]'::json) as tags
         from post p
         join album a on a.id = p.album_id
         left join "group" g on g.id = a.group_id
        where ${where}
        ${orderBy}`,
      params,
    );
  }

  private toView(row: PostRow): ReviewPostView {
    return {
      id: row.id,
      album: {
        id: row.album_id,
        title: row.album_title,
        group_name: row.group_name,
        moderation_mode: row.moderation_mode,
      },
      author_name: '',
      author_id: row.author_id,
      created_at: row.created_at.toISOString(),
      media_count: 1,
      media_kind: row.media_kind,
      thumbnail_url: null,
      tags: row.tags,
      moderation_status: row.moderation_status,
      is_blocked:
        row.moderation_status === 'hidden' && row.hidden_reason === 'consent_blocked',
    };
  }

  private assertOversight(user: AuthenticatedUser): void {
    if (!user.hasOversight) throw ApiError.scopeForbidden();
  }

  /** Albums with no group are association-wide and visible to every branch. */
  private scopeOf(user: AuthenticatedUser): { clause: string; params: unknown[] } {
    return user.branchId
      ? { clause: 'and (g.id is null or g.branch_id = $1)', params: [user.branchId] }
      : { clause: '', params: [] };
  }
}
