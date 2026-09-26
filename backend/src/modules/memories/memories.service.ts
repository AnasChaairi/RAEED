import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';
import { loadLocale, pick } from '../../common/i18n/user-locale';
import { displayNameOf } from '../../common/sql/display-name';
import { MediaService } from '../media/media.service';
import { NotifyService } from '../notifications/notify.service';
import { CreatePostDto } from './dto/post.dto';

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

/** One of the educator's own posts, as the Memories tab lists them (EDU-M-08). */
export interface MyPostView {
  id: string;
  album: { id: string; title: string; group_name: string | null };
  caption: string | null;
  media_count: number;
  thumbnail_url: string | null;
  tag_count: number;
  created_at: string;
  state: 'pending' | 'published' | 'edit_requested';
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
  author_name: string;
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
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly notify: NotifyService,
  ) {}

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

  /** The caller's own posts, newest first, with where each one stands. */
  async myPosts(user: AuthenticatedUser): Promise<MyPostView[]> {
    const rows: Array<{
      id: string;
      album_id: string;
      album_title: string;
      group_name: string | null;
      caption: string | null;
      storage_key: string;
      media_json: Array<{ storage_key: string }>;
      tag_count: number;
      created_at: Date;
      moderation_status: 'pending' | 'published' | 'hidden';
    }> = await this.dataSource.query(
      `select p.id, a.id as album_id, a.title as album_title, g.name as group_name,
              p.caption, p.storage_key, p.media_json, p.created_at, p.moderation_status,
              (select count(*) from post_tag pt where pt.post_id = p.id)::int as tag_count
         from post p
         join album a on a.id = p.album_id
         left join "group" g on g.id = a.group_id
        where p.author_id = $1 and p.deleted_at is null
        order by p.created_at desc
        limit 50`,
      [user.id],
    );
    return rows.map((row) => ({
      id: row.id,
      album: { id: row.album_id, title: row.album_title, group_name: row.group_name },
      caption: row.caption,
      media_count: Math.max(1, Array.isArray(row.media_json) ? row.media_json.length : 0),
      thumbnail_url: row.storage_key.startsWith('seed/') ? null : MediaService.urlFor(row.storage_key),
      tag_count: row.tag_count,
      created_at: row.created_at.toISOString(),
      state:
        row.moderation_status === 'published'
          ? 'published'
          : row.moderation_status === 'pending'
            ? 'pending'
            : 'edit_requested',
    }));
  }

  /**
   * Publishes a post to an album the caller may post in, after the consent
   * check that is the wall's whole point (`WAL-06`): a tagged child whose
   * current image rights are `not_allowed` refuses the post naming them.
   * `app_only` children may appear — the wall never leaves the app. Whether
   * the post is live at once or waits for an executive is the album's
   * `moderation_mode`, an open decision the server owns.
   */
  async create(user: AuthenticatedUser, input: CreatePostDto): Promise<MyPostView> {
    const albums: Array<{ id: string; group_id: string | null; branch_id: string | null; moderation_mode: ModerationMode; title: string }> =
      await this.dataSource.query(
        `select a.id, a.group_id, g.branch_id, a.moderation_mode, a.title
           from album a
           join season se on se.id = a.season_id and se.status = 'active'
           left join "group" g on g.id = a.group_id
          where a.id = $1`,
        [input.album_id],
      );
    const album = albums[0];
    if (!album) throw ApiError.scopeForbidden('No such album, or not yours.');
    const ability = defineAbilityFor(user);
    if (!ability.can('create', subject('MemoriesPost', { groupId: album.group_id, branchId: album.branch_id }))) {
      throw ApiError.scopeForbidden();
    }

    const tagged = [...new Set(input.tagged_child_ids)];
    const children: Array<{ id: string; full_name: string; group_id: string | null; level: string | null }> =
      tagged.length === 0
        ? []
        : await this.dataSource.query(
            `select c.id, c.full_name, cg.group_id,
                    (select case when bool_or(l.level = 'not_allowed') then 'not_allowed'
                                 when bool_or(l.level = 'app_only') then 'app_only'
                                 when count(*) > 0 then 'allowed' end
                       from (select distinct on (cr.guardian_id) cr.level
                               from consent_record cr
                              where cr.child_id = c.id and cr.type = 'image_rights' and cr.level is not null
                              order by cr.guardian_id, cr.effective_at desc) l) as level
               from child c
               left join child_group cg on cg.child_id = c.id and cg.valid_to is null and cg.is_main
              where c.id = any($1::uuid[]) and c.deleted_at is null`,
            [tagged],
          );
    for (const childId of tagged) {
      const child = children.find((row) => row.id === childId);
      // A child outside the caller's reach is refused as scope, not consent:
      // the educator should not learn anything about them from the error.
      if (!child || !ability.can('read', subject('Child', { id: child.id, groupId: child.group_id, branchId: album.branch_id }))) {
        throw ApiError.scopeForbidden('A tagged child is not in your groups.');
      }
    }
    const blocked = children.filter((child) => (child.level ?? 'not_allowed') === 'not_allowed');
    if (blocked.length > 0) throw ApiError.memoriesConsentBlocked(blocked.map((child) => child.id));

    const status = album.moderation_mode === 'approve_before_publish' ? 'pending' : 'published';
    const locale = await loadLocale(this.dataSource, user.id);

    const postId = await this.dataSource.transaction(async (tx) => {
      const rows: Array<{ id: string }> = await tx.query(
        `insert into post (album_id, author_id, storage_key, media_kind, moderation_status, caption, media_json)
         values ($1, $2, $3, $4, $5, $6, $7::jsonb)
         returning id`,
        [
          album.id,
          user.id,
          input.media[0].storage_key,
          input.media[0].media_kind,
          status,
          input.caption?.trim() || null,
          JSON.stringify(input.media),
        ],
      );
      const id = rows[0].id;
      if (tagged.length > 0) {
        await tx.query(
          `insert into post_tag (post_id, child_id) select $1, c from unnest($2::uuid[]) as c`,
          [id, tagged],
        );
      }
      if (status === 'published') {
        const guardians = await this.notify.guardiansOfChildren(tx, tagged);
        await this.notify.notify(tx, guardians, {
          kind: 'memories',
          title: pick(locale, { ar: `منشور جديد في «${album.title}»`, fr: `Nouvelle publication — ${album.title}`, en: `New post in “${album.title}”` }),
          body: input.caption?.trim() || null,
          destination: 'memories',
          data: { type: 'memories-post', post_id: id },
        });
      } else {
        const oversight = await this.notify.oversightUsers(tx);
        await this.notify.notify(tx, oversight, {
          kind: 'memories',
          title: pick(locale, { ar: `منشور جديد في «${album.title}»`, fr: `Nouvelle publication — ${album.title}`, en: `New post in “${album.title}”` }),
          body: pick(locale, { ar: 'بانتظار اعتمادك.', fr: 'En attente de votre approbation.', en: 'Awaiting your approval.' }),
          destination: 'memories',
          data: { type: 'memories-review', post_id: id },
        });
      }
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'post.create', 'post', $2, $3::jsonb)`,
        [user.id, id, JSON.stringify({ album_id: album.id, status, media: input.media.length, tags: tagged.length })],
      );
      return id;
    });

    const mine = await this.myPosts(user);
    return mine.find((post) => post.id === postId)!;
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
              p.author_id, ${displayNameOf('p.author_id')} as author_name,
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
      author_name: row.author_name ?? '',
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

  /**
   * Albums with no group are association-wide and visible to every branch;
   * an educator sees those and their own groups' albums.
   */
  private scopeOf(user: AuthenticatedUser): { clause: string; params: unknown[] } {
    if (!user.hasOversight) {
      return { clause: 'and (g.id is null or g.id = any($1::uuid[]))', params: [[...user.reachableGroupIds]] };
    }
    return user.branchId
      ? { clause: 'and (g.id is null or g.branch_id = $1)', params: [user.branchId] }
      : { clause: '', params: [] };
  }
}
