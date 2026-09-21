import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { loadLocale, scheduleLabel } from '../../common/i18n/user-locale';
import { ApiError } from '../../common/http/api-error';

export interface GroupView {
  id: string;
  name: string;
  category: { id: string; name: string };
  enrolled_count: number;
  capacity: number | null;
  /** Ids only: `app_user` carries no display name yet. */
  educators: Array<{ id: string }>;
  schedule_label: string | null;
  place: string | null;
}

export interface GroupSessionView {
  id: string;
  group_id: string;
  title: string | null;
  starts_at: string;
  ends_at: string;
  status: 'planned' | 'delivered' | 'cancelled';
  attendance: {
    recorded: boolean;
    present_count: number | null;
    enrolled_count: number | null;
  };
}

interface GroupRow {
  id: string;
  name: string;
  capacity: number | null;
  branch_id: string;
  category_id: string;
  category_name: string;
  enrolled_count: number;
  educator_ids: string[];
  weekly_schedule_json: unknown;
  place: string | null;
}

/**
 * Groups as the executive's list and the educator's own view read them.
 *
 * Scope is applied in the query: an executive sees the active season's
 * groups in their branch scope, an educator exactly the groups they lead
 * (`group_educator.unassigned_at is null`), and a parent nothing at all — the
 * ability model grants parents no `read` on `Group`, and the guard turns
 * that into a 403 before this runs.
 */
@Injectable()
export class GroupsService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  async list(user: AuthenticatedUser): Promise<GroupView[]> {
    const params: unknown[] = [];
    const where: string[] = ["g.deleted_at is null", "se.status = 'active'"];

    if (user.hasOversight) {
      if (user.branchId) {
        params.push(user.branchId);
        where.push(`g.branch_id = $${params.length}`);
      }
    } else {
      params.push([...user.reachableGroupIds]);
      where.push(`g.id = any($${params.length}::uuid[])`);
    }

    const rows = await this.query(where, params, 'order by g.name, g.id');
    const locale = await loadLocale(this.dataSource, user.id);
    return rows.map((row) => this.toView(row, locale));
  }

  async detail(user: AuthenticatedUser, groupId: string): Promise<GroupView> {
    const row = await this.loadReadable(user, groupId);
    const locale = await loadLocale(this.dataSource, user.id);
    return this.toView(row, locale);
  }

  /** The group's sessions, most recent first. */
  async sessions(
    user: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupSessionView[]> {
    const group = await this.loadReadable(user, groupId);

    const rows: Array<{
      id: string;
      title: string | null;
      starts_at: Date;
      ends_at: Date;
      status: GroupSessionView['status'];
      attendance_recorded: boolean;
      present_count: number;
    }> = await this.dataSource.query(
      `select s.id, s.title, s.starts_at, s.ends_at, s.status,
              exists (select 1 from attendance_record ar
                       where ar.session_id = s.id and ar.superseded_at is null)
                as attendance_recorded,
              (select count(*) from attendance_record ar
                where ar.session_id = s.id and ar.superseded_at is null
                  and ar.status in ('present', 'late'))::int as present_count
         from session s
        where s.group_id = $1 and s.deleted_at is null
        order by s.starts_at desc
        limit 60`,
      [group.id],
    );

    return rows.map((row) => ({
      id: row.id,
      group_id: group.id,
      title: row.title,
      starts_at: row.starts_at.toISOString(),
      ends_at: row.ends_at.toISOString(),
      status: row.status,
      attendance: {
        recorded: row.attendance_recorded,
        present_count: row.attendance_recorded ? row.present_count : null,
        enrolled_count: row.attendance_recorded ? group.enrolled_count : null,
      },
    }));
  }

  /**
   * Loads a group and checks the caller may read it — against the row's own
   * branch, never anything the request supplied. A missing group answers
   * exactly like a forbidden one.
   */
  private async loadReadable(
    user: AuthenticatedUser,
    groupId: string,
  ): Promise<GroupRow> {
    const rows = await this.query(['g.id = $1', 'g.deleted_at is null'], [groupId], '');
    const row = rows[0];
    if (!row) throw ApiError.scopeForbidden('No such group, or not yours.');

    const ability = defineAbilityFor(user);
    const resource = subject('Group', { id: row.id, branchId: row.branch_id });
    if (!ability.can('read', resource)) throw ApiError.scopeForbidden();
    return row;
  }

  private query(
    where: string[],
    params: unknown[],
    orderBy: string,
  ): Promise<GroupRow[]> {
    return this.dataSource.query(
      `select g.id, g.name, g.capacity, g.branch_id, g.weekly_schedule_json,
              cat.id as category_id, cat.name_ar as category_name,
              (select count(*)
                 from child_group cg
                 join child c on c.id = cg.child_id and c.deleted_at is null
                where cg.group_id = g.id and cg.valid_to is null)::int as enrolled_count,
              coalesce((select array_agg(ge.educator_user_id order by ge.assigned_at)
                          from group_educator ge
                         where ge.group_id = g.id and ge.unassigned_at is null),
                       '{}'::uuid[]) as educator_ids,
              (select s.place from session s
                where s.group_id = g.id and s.deleted_at is null and s.place is not null
                order by s.starts_at desc limit 1) as place
         from "group" g
         join category cat on cat.id = g.category_id
         join season se on se.id = g.season_id
        where ${where.join(' and ')}
        ${orderBy}`,
      params,
    );
  }

  private toView(row: GroupRow, locale: 'ar' | 'fr' | 'en'): GroupView {
    return {
      id: row.id,
      name: row.name,
      category: { id: row.category_id, name: row.category_name },
      enrolled_count: row.enrolled_count,
      capacity: row.capacity,
      educators: row.educator_ids.map((id) => ({ id })),
      schedule_label: scheduleLabel(locale, row.weekly_schedule_json),
      place: row.place,
    };
  }
}
