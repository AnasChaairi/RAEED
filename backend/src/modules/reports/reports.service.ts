import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ORG_TIMEZONE } from '../../common/i18n/user-locale';
import { ApiError } from '../../common/http/api-error';
import { displayNameOf } from '../../common/sql/display-name';
import { CreateExportDto, ExportField, HEALTH_FIELDS } from './dto/export.dto';

export interface RateRow {
  id: string;
  name: string;
  present: number;
  expected: number;
}

export interface EducatorActivityRow {
  id: string;
  display_name: string;
  planned: number;
  delivered: number;
  marked_on_time: number;
  /** Median first-reply time in child threads; null until messaging keeps it. */
  reply_minutes: number | null;
}

export interface EngagementView {
  guardians_activated: { count: number; total: number };
  presence_answers: { count: number; total: number };
  /** Homework is self-reported and not implemented yet — null, never a guess. */
  homework_done_rate: null;
}

export interface ExportView {
  filename: string;
  content_type: 'text/csv';
  /** UTF-8 CSV with a BOM so spreadsheets read the Arabic correctly. */
  content: string;
  fields: ExportField[];
  contains_health: boolean;
  row_count: number;
  created_at: string;
}

interface Scope {
  readonly clause: string;
  readonly params: unknown[];
}

/**
 * Reports for the executive (EXEC-M-11), read from the operational tables.
 *
 * Every rate is returned as the raw pair it comes from — the brief asks that
 * a percentage never appear without its count, because "100%" of three
 * children is not the same claim as "100%" of sixty.
 */
@Injectable()
export class ReportsService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  async attendance(user: AuthenticatedUser): Promise<{ by_educator: RateRow[]; by_category: RateRow[] }> {
    this.assertOversight(user);
    const scope = this.scopeOf(user);
    const [byEducator, byCategory] = await Promise.all([
      this.dataSource.query(
        `${this.sessionMarks(scope)}
         select ge.educator_user_id as id, ${displayNameOf('ge.educator_user_id')} as name,
                coalesce(sum(m.present), 0)::int as present,
                coalesce(sum(m.expected), 0)::int as expected
           from marks m
           join group_educator ge on ge.group_id = m.group_id and ge.unassigned_at is null
          group by ge.educator_user_id
          order by expected desc, name`,
        scope.params,
      ),
      this.dataSource.query(
        `${this.sessionMarks(scope)}
         select cat.id, cat.name_ar as name,
                coalesce(sum(m.present), 0)::int as present,
                coalesce(sum(m.expected), 0)::int as expected
           from marks m
           join "group" g on g.id = m.group_id
           join category cat on cat.id = g.category_id
          group by cat.id
          order by expected desc, name`,
        scope.params,
      ),
    ]);
    return { by_educator: byEducator, by_category: byCategory };
  }

  async educators(user: AuthenticatedUser): Promise<EducatorActivityRow[]> {
    this.assertOversight(user);
    const scope = this.scopeOf(user);
    const rows: Array<Omit<EducatorActivityRow, 'reply_minutes'>> = await this.dataSource.query(
      `with past as (
         select s.id, s.group_id, s.ends_at,
                exists (select 1 from attendance_record ar
                         where ar.session_id = s.id and ar.superseded_at is null) as delivered,
                (select min(ar.recorded_at) from attendance_record ar
                  where ar.session_id = s.id) as first_mark
           from session s
           join "group" g on g.id = s.group_id
           join season se on se.id = g.season_id and se.status = 'active'
          where s.deleted_at is null and s.status <> 'cancelled' and s.ends_at < now()
            ${scope.clause}
       )
       select ge.educator_user_id as id, ${displayNameOf('ge.educator_user_id')} as display_name,
              count(p.id)::int as planned,
              count(p.id) filter (where p.delivered)::int as delivered,
              count(p.id) filter (where p.first_mark is not null
                                    and p.first_mark <= p.ends_at + interval '30 minutes')::int
                as marked_on_time
         from group_educator ge
         join past p on p.group_id = ge.group_id
        where ge.unassigned_at is null
        group by ge.educator_user_id
        order by planned desc, display_name`,
      scope.params,
    );
    return rows.map((row) => ({ ...row, reply_minutes: null }));
  }

  async engagement(user: AuthenticatedUser): Promise<EngagementView> {
    this.assertOversight(user);
    const scope = this.scopeOf(user);
    const rows: Array<{
      activated: number;
      guardians: number;
      answers: number;
      asked: number;
    }> = await this.dataSource.query(
      `with scoped_children as (
         select distinct c.id
           from child c
           join child_group cg on cg.child_id = c.id and cg.valid_to is null
           join "group" g on g.id = cg.group_id
          where c.deleted_at is null ${scope.clause}
       ),
       guardians as (
         select distinct pc.guardian_user_id as id
           from parent_child pc
           join scoped_children sc on sc.id = pc.child_id
          where pc.unlinked_at is null
       )
       select (select count(*) from guardians gu
                where exists (select 1 from user_device d
                               where d.user_id = gu.id and d.revoked_at is null
                                 and d.last_seen_at is not null))::int as activated,
              (select count(*) from guardians)::int as guardians,
              (select count(*) from presence_answer pa
                 join scoped_children sc on sc.id = pa.child_id)::int as answers,
              (select count(*)
                 from presence_confirmation pc
                 join session s on s.id = pc.session_id and s.deleted_at is null
                 join child_group cg on cg.group_id = s.group_id and cg.valid_to is null
                 join scoped_children sc on sc.id = cg.child_id)::int as asked`,
      scope.params,
    );
    const row = rows[0];
    return {
      guardians_activated: { count: row?.activated ?? 0, total: row?.guardians ?? 0 },
      presence_answers: { count: row?.answers ?? 0, total: row?.asked ?? 0 },
      homework_done_rate: null,
    };
  }

  /**
   * A children list as CSV, with exactly the fields asked for.
   *
   * Recorded with the field list before the file is built (`AUD-02`): an
   * export that includes a health column is the one place data about
   * children leaves the system, and the log must say who took it and what
   * it held. Health fields are never included unless named.
   */
  async export(user: AuthenticatedUser, input: CreateExportDto): Promise<ExportView> {
    this.assertOversight(user);
    const scope = this.scopeOf(user);
    const fields = [...new Set(input.fields)];
    const containsHealth = fields.some((field) => HEALTH_FIELDS.has(field));

    const params = [...scope.params];
    let groupClause = '';
    if (input.group_id) {
      params.push(input.group_id);
      groupClause = `and g.id = $${params.length}`;
    }

    const rows: Array<{
      full_name: string;
      dob: string;
      category_name: string | null;
      group_name: string | null;
      guardian_names: string[];
      guardian_phones: string[];
      image_rights: string;
      allergies: string[];
      medications: string[];
    }> = await this.dataSource.query(
      `select c.full_name, to_char(c.dob, 'YYYY-MM-DD') as dob,
              cat.name_ar as category_name, g.name as group_name,
              coalesce((select array_agg(coalesce(u.display_name, '') order by pc.linked_at)
                          from parent_child pc join app_user u on u.id = pc.guardian_user_id
                         where pc.child_id = c.id and pc.unlinked_at is null), '{}') as guardian_names,
              coalesce((select array_agg(coalesce(u.phone, '') order by pc.linked_at)
                          from parent_child pc join app_user u on u.id = pc.guardian_user_id
                         where pc.child_id = c.id and pc.unlinked_at is null), '{}') as guardian_phones,
              coalesce((select case when bool_or(l.level = 'not_allowed') then 'not_allowed'
                                    when bool_or(l.level = 'app_only') then 'app_only'
                                    else 'allowed' end
                          from (select distinct on (cr.guardian_id) cr.level from consent_record cr
                                 where cr.child_id = c.id and cr.type = 'image_rights' and cr.level is not null
                                 order by cr.guardian_id, cr.effective_at desc) l), 'not_allowed') as image_rights,
              coalesce((select array_agg(x) from jsonb_array_elements_text(
                          case when jsonb_typeof(c.health_json->'allergies') = 'array'
                               then c.health_json->'allergies' else '[]'::jsonb end) x), '{}') as allergies,
              coalesce((select array_agg(x) from jsonb_array_elements_text(
                          case when jsonb_typeof(c.health_json->'medications') = 'array'
                               then c.health_json->'medications' else '[]'::jsonb end) x), '{}') as medications
         from child c
         left join child_group cg on cg.child_id = c.id and cg.valid_to is null and cg.is_main
         left join "group" g on g.id = cg.group_id
         left join category cat on cat.id = g.category_id
        where c.deleted_at is null ${scope.clause} ${groupClause}
        order by g.name nulls last, c.full_name`,
      params,
    );

    const createdAt = new Date();
    await this.dataSource.query(
      `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
       values ($1, 'report.export', 'child', null, $2::jsonb)`,
      [
        user.id,
        JSON.stringify({
          fields,
          contains_health: containsHealth,
          group_id: input.group_id ?? null,
          row_count: rows.length,
        }),
      ],
    );

    const header: Record<ExportField, string> = {
      name: 'الاسم الكامل',
      dob: 'تاريخ الولادة',
      group: 'الفئة والمجموعة',
      guardian: 'ولي الأمر',
      phone: 'هاتف ولي الأمر',
      consent: 'حقوق الصورة',
      allergies: 'الحساسية',
      medications: 'الأدوية',
    };
    const lines = [fields.map((field) => csvCell(header[field])).join(',')];
    for (const row of rows) {
      const cells: Record<ExportField, string> = {
        name: row.full_name,
        dob: row.dob,
        group: [row.category_name, row.group_name].filter(Boolean).join(' · '),
        guardian: row.guardian_names.join(' · '),
        phone: row.guardian_phones.join(' · '),
        consent: row.image_rights,
        allergies: row.allergies.join('; '),
        medications: row.medications.join('; '),
      };
      lines.push(fields.map((field) => csvCell(cells[field])).join(','));
    }

    const stamp = createdAt.toISOString().slice(0, 10);
    return {
      filename: `raeed-children-${stamp}.csv`,
      content_type: 'text/csv',
      content: '﻿' + lines.join('\r\n') + '\r\n',
      fields,
      contains_health: containsHealth,
      row_count: rows.length,
      created_at: createdAt.toISOString(),
    };
  }

  /** Past, non-cancelled sessions of the active season with their marks. */
  private sessionMarks(scope: Scope): string {
    return `with marks as (
              select s.id, s.group_id,
                     (select count(*) from attendance_record ar
                       where ar.session_id = s.id and ar.superseded_at is null
                         and ar.status in ('present', 'late'))::int as present,
                     (select count(*) from child_group cg
                        join child c on c.id = cg.child_id and c.deleted_at is null
                       where cg.group_id = s.group_id and cg.valid_to is null)::int as expected
                from session s
                join "group" g on g.id = s.group_id
                join season se on se.id = g.season_id and se.status = 'active'
               where s.deleted_at is null and s.status <> 'cancelled'
                 and s.ends_at < now()
                 and exists (select 1 from attendance_record ar
                              where ar.session_id = s.id and ar.superseded_at is null)
                 ${scope.clause}
            )`;
  }

  private scopeOf(user: AuthenticatedUser): Scope {
    return user.branchId
      ? { clause: 'and g.branch_id = $1', params: [user.branchId] }
      : { clause: '', params: [] };
  }

  private assertOversight(user: AuthenticatedUser): void {
    if (!user.hasOversight) throw ApiError.scopeForbidden();
  }
}

function csvCell(value: string): string {
  return `"${value.replace(/"/g, '""')}"`;
}

export { ORG_TIMEZONE };
