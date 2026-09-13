import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';

/** A child as a list response describes them (`specs/04-api/openapi.yaml`). */
export interface ChildListItem {
  id: string;
  full_name: string;
  photo_url: string | null;
  dob: string;
  group: { id: string; name: string } | null;
  /** Presence-only flag. The health text itself is never in a list payload. */
  health_alert: boolean;
}

export interface ChildDetailView extends ChildListItem {
  school_level: string | null;
  health_json: Record<string, unknown>;
  image_rights_level: 'allowed' | 'app_only' | 'not_allowed';
}

@Injectable()
export class ChildrenService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  /**
   * Children the caller may see.
   *
   * The scope is applied **in the query**, not by filtering afterwards. A
   * "fetch everything then filter" shape is one forgotten `.filter()` away from
   * returning the whole association to a parent, and it would also read every
   * child's row to answer a question about three.
   */
  async list(
    user: AuthenticatedUser,
    options: { groupId?: string; limit: number; cursor?: string },
  ): Promise<{ items: ChildListItem[]; nextCursor: string | null }> {
    const params: unknown[] = [];
    const where: string[] = ['c.deleted_at is null'];

    if (!user.hasOversight) {
      // A parent or educator sees exactly their resolved set. An empty set
      // yields an empty list rather than everything — `= any('{}')` matches
      // nothing, which is the correct answer for a guardian with no links.
      params.push([...user.reachableChildIds]);
      where.push(`c.id = any($${params.length}::uuid[])`);
    } else if (user.branchId) {
      params.push(user.branchId);
      where.push(`g.branch_id = $${params.length}`);
    }

    if (options.groupId) {
      params.push(options.groupId);
      where.push(`cg.group_id = $${params.length}`);
    }

    // Cursor pagination, not offset: offset breaks under concurrent writes on
    // live lists (`specs/04-api/conventions.md`).
    if (options.cursor) {
      params.push(decodeCursor(options.cursor));
      where.push(`(c.full_name, c.id) > ($${params.length}::text, $${params.length + 1}::uuid)`);
      params.push(decodeCursorId(options.cursor));
    }

    params.push(options.limit + 1);

    const rows: Array<{
      id: string;
      full_name: string;
      photo_url: string | null;
      dob: string;
      group_id: string | null;
      group_name: string | null;
      health_alert: boolean;
    }> = await this.dataSource.query(
      `select c.id, c.full_name, c.photo_url, c.dob,
              g.id as group_id, g.name as group_name,
              (c.health_json is not null and c.health_json <> '{}'::jsonb) as health_alert
         from child c
         left join child_group cg on cg.child_id = c.id and cg.valid_to is null
         left join "group" g on g.id = cg.group_id
        where ${where.join(' and ')}
        order by c.full_name, c.id
        limit $${params.length}`,
      params,
    );

    const hasMore = rows.length > options.limit;
    const page = hasMore ? rows.slice(0, options.limit) : rows;

    return {
      items: page.map((row) => ({
        id: row.id,
        full_name: row.full_name,
        photo_url: row.photo_url,
        dob: row.dob,
        group:
          row.group_id && row.group_name
            ? { id: row.group_id, name: row.group_name }
            : null,
        health_alert: row.health_alert,
      })),
      nextCursor:
        hasMore && page.length > 0
          ? encodeCursor(page[page.length - 1].full_name, page[page.length - 1].id)
          : null,
    };
  }

  /**
   * One child's full profile, including health information.
   *
   * The ability check runs against the row **loaded from the database** — its
   * real group and branch — never against anything the caller supplied
   * (`specs/04-api/conventions.md`). A client that could name its own groupId
   * would assert its way past every scope rule.
   */
  async detail(user: AuthenticatedUser, childId: string): Promise<ChildDetailView> {
    const rows: Array<{
      id: string;
      full_name: string;
      photo_url: string | null;
      dob: string;
      school_level: string | null;
      health_json: Record<string, unknown>;
      group_id: string | null;
      group_name: string | null;
      branch_id: string | null;
    }> = await this.dataSource.query(
      `select c.id, c.full_name, c.photo_url, c.dob, c.school_level, c.health_json,
              g.id as group_id, g.name as group_name, g.branch_id
         from child c
         left join child_group cg on cg.child_id = c.id and cg.valid_to is null
         left join "group" g on g.id = cg.group_id
        where c.id = $1 and c.deleted_at is null`,
      [childId],
    );
    const row = rows[0];
    if (!row) throw ApiError.scopeForbidden('No such child, or not yours.');

    const ability = defineAbilityFor(user);
    const resource = subject('Child', {
      id: row.id,
      groupId: row.group_id,
      branchId: row.branch_id,
    });
    if (!ability.can('read', resource)) throw ApiError.scopeForbidden();

    return {
      id: row.id,
      full_name: row.full_name,
      photo_url: row.photo_url,
      dob: row.dob,
      school_level: row.school_level,
      group:
        row.group_id && row.group_name
          ? { id: row.group_id, name: row.group_name }
          : null,
      health_alert: Object.keys(row.health_json ?? {}).length > 0,
      health_json: row.health_json ?? {},
      image_rights_level: await this.currentImageRights(childId),
    };
  }

  /**
   * The child's effective image-rights level, most-restrictive-wins.
   *
   * Two guardians can hold different current levels. If any of them says
   * `not_allowed`, that is the answer (`specs/03-domain-model/entities.md`) —
   * this resolution lives in application code because the schema deliberately
   * keeps every guardian's row.
   */
  async currentImageRights(
    childId: string,
  ): Promise<'allowed' | 'app_only' | 'not_allowed'> {
    const rows: Array<{ level: 'allowed' | 'app_only' | 'not_allowed' }> =
      await this.dataSource.query(
        `select distinct on (guardian_id) level
           from consent_record
          where child_id = $1 and type = 'image_rights' and level is not null
          order by guardian_id, effective_at desc`,
        [childId],
      );

    // No recorded consent is treated as the most restrictive level, not as
    // permission. Absence of a "no" is not a "yes" where a child's image is
    // concerned.
    if (rows.length === 0) return 'not_allowed';
    if (rows.some((row) => row.level === 'not_allowed')) return 'not_allowed';
    if (rows.some((row) => row.level === 'app_only')) return 'app_only';
    return 'allowed';
  }
}

function encodeCursor(name: string, id: string): string {
  return Buffer.from(JSON.stringify({ n: name, i: id })).toString('base64url');
}

function decodeCursor(cursor: string): string {
  return parseCursor(cursor).n;
}

function decodeCursorId(cursor: string): string {
  return parseCursor(cursor).i;
}

function parseCursor(cursor: string): { n: string; i: string } {
  try {
    const parsed: unknown = JSON.parse(
      Buffer.from(cursor, 'base64url').toString('utf8'),
    );
    if (
      typeof parsed === 'object' &&
      parsed !== null &&
      typeof (parsed as { n?: unknown }).n === 'string' &&
      typeof (parsed as { i?: unknown }).i === 'string'
    ) {
      return parsed as { n: string; i: string };
    }
  } catch {
    // Falls through to the error below.
  }
  throw ApiError.validationFailed({ cursor: ['cursor is not valid'] });
}
