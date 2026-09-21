import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { CheckAbility, CheckAbilityGuard } from '../../common/abilities/check-ability.guard';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { displayNameOf } from '../../common/sql/display-name';

export interface AuditEntryView {
  id: string;
  at: string;
  actor: { id: string | null; display_name: string; role: string | null };
  action: string;
  resource_type: string;
  resource_id: string | null;
  /** A human label for the resource, resolved where the type allows. */
  resource_label: string | null;
  device_meta: Record<string, unknown> | null;
}

/**
 * The audit log (EXEC-M-13, `AUD-01..04`). Admin only, read only — the
 * runtime role cannot update or delete a row, and this controller offers no
 * route that would try.
 *
 * `?action=child.health_view` is the health-access view: who read which
 * child's health information and when, the promise made at every reveal.
 */
@Controller('audit-log')
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
@CheckAbility('read', 'AuditLogEntry')
export class AuditController {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  @Get()
  async list(
    @Query('action') action?: string,
    @Query('limit') limit?: string,
  ): Promise<{ data: AuditEntryView[]; page: { cursor: null; has_more: false } }> {
    const params: unknown[] = [];
    let where = '';
    if (action) {
      params.push(action);
      where = `where a.action = $${params.length}`;
    }
    const size = Math.min(Math.max(Number.parseInt(limit ?? '100', 10) || 100, 1), 500);
    params.push(size);

    const rows: Array<
      Omit<AuditEntryView, 'at' | 'actor'> & {
        at: Date;
        actor_id: string | null;
        actor_name: string;
        actor_role: string | null;
      }
    > = await this.dataSource.query(
      `select a.id, a.at, a.actor_user_id as actor_id,
              coalesce(${displayNameOf('a.actor_user_id')}, '') as actor_name,
              (select ra.role from role_assignment ra where ra.user_id = a.actor_user_id
                order by case ra.role when 'admin' then 0 when 'executive' then 1
                                      when 'educator' then 2 else 3 end limit 1) as actor_role,
              a.action, a.resource_type, a.resource_id, a.device_meta,
              case a.resource_type
                when 'child' then (select c.full_name from child c where c.id = a.resource_id)
                when 'attendance_record' then (select c.full_name from attendance_record ar
                                                 join child c on c.id = ar.child_id
                                                where ar.id = a.resource_id)
                when 'group' then (select g.name from "group" g where g.id = a.resource_id)
                when 'announcement' then (select an.title from announcement an where an.id = a.resource_id)
                when 'post' then (select al.title from post p join album al on al.id = p.album_id
                                   where p.id = a.resource_id)
                when 'app_user' then ${displayNameOf('a.resource_id')}
                when 'season' then (select se.label from season se where se.id = a.resource_id)
                else null
              end as resource_label
         from audit_log_entry a
        ${where}
        order by a.at desc, a.id
        limit $${params.length}`,
      params,
    );

    return {
      data: rows.map((row) => ({
        id: row.id,
        at: row.at.toISOString(),
        actor: { id: row.actor_id, display_name: row.actor_name, role: row.actor_role },
        action: row.action,
        resource_type: row.resource_type,
        resource_id: row.resource_id,
        resource_label: row.resource_label,
        device_meta: row.device_meta,
      })),
      page: { cursor: null, has_more: false },
    };
  }
}
