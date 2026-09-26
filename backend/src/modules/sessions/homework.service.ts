import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';
import { loadLocale, pick } from '../../common/i18n/user-locale';
import { NotifyService } from '../notifications/notify.service';
import { CreateHomeworkDto } from './dto/session.dto';
import { HomeworkView, SessionsService } from './sessions.service';

export interface GroupHomeworkView extends HomeworkView {
  session_starts_at: string;
  is_open: boolean;
}

/**
 * Homework, set by an educator for a whole group or named children
 * (`HWK-01`). Done is self-reported by guardians (`HWK-03`); the counts
 * here are labelled so wherever they are shown.
 */
@Injectable()
export class HomeworkService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly sessions: SessionsService,
    private readonly notify: NotifyService,
  ) {}

  async create(
    user: AuthenticatedUser,
    sessionId: string,
    input: CreateHomeworkDto,
  ): Promise<HomeworkView> {
    const session = await this.sessions.loadReadable(user, sessionId, 'read');
    const ability = defineAbilityFor(user);
    if (!ability.can('create', subject('Homework', { groupId: session.group_id, branchId: session.branch_id }))) {
      throw ApiError.scopeForbidden();
    }

    const enrolled: Array<{ id: string }> = await this.dataSource.query(
      `select c.id from child_group cg
         join child c on c.id = cg.child_id and c.deleted_at is null
        where cg.group_id = $1 and cg.valid_to is null
        order by c.full_name, c.id`,
      [session.group_id],
    );
    const enrolledIds = new Set(enrolled.map((child) => child.id));

    // Targets are checked against the group's live roster: a child id the
    // request names that is not enrolled here is refused, not silently
    // dropped — the educator would believe that child got the homework.
    const targets = input.target_child_ids ?? null;
    if (targets !== null) {
      if (targets.length === 0) throw ApiError.validationFailed({ target_child_ids: 'pick at least one child' });
      const outside = targets.filter((id) => !enrolledIds.has(id));
      if (outside.length > 0) throw ApiError.validationFailed({ target_child_ids: `not in this group: ${outside.join(', ')}` });
    }
    const recipients = targets ?? [...enrolledIds];
    const locale = await loadLocale(this.dataSource, user.id);

    const homeworkId = await this.dataSource.transaction(async (tx) => {
      const rows: Array<{ id: string }> = await tx.query(
        `insert into homework (session_id, group_id, title, instructions, attachment_storage_key, due_at, target_child_ids)
         values ($1, $2, $3, $4, $5, $6, $7)
         returning id`,
        [
          session.id,
          session.group_id,
          input.title?.trim() || null,
          input.instructions.trim(),
          input.attachment_storage_key ?? null,
          input.due_at,
          targets,
        ],
      );
      const id = rows[0].id;
      if (recipients.length > 0) {
        await tx.query(
          `insert into homework_status (homework_id, child_id)
           select $1, c from unnest($2::uuid[]) as c`,
          [id, recipients],
        );
      }
      const guardians = await this.notify.guardiansOfChildren(tx, recipients);
      await this.notify.notify(tx, guardians, {
        kind: 'other',
        title: pick(locale, {
          ar: `واجب جديد — ${session.group_name}`,
          fr: `Nouveau devoir — ${session.group_name}`,
          en: `New homework — ${session.group_name}`,
        }),
        body: input.title?.trim() || input.instructions.trim().slice(0, 120),
        destination: 'groups',
        data: { type: 'homework', homework_id: id },
      });
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'homework.create', 'homework', $2, $3::jsonb)`,
        [user.id, id, JSON.stringify({ session_id: session.id, group_id: session.group_id, targets: recipients.length })],
      );
      return id;
    });

    const all = await this.sessions.homeworkOf(session.id);
    return all.find((item) => item.id === homeworkId)!;
  }

  /** A group's homework, newest first, with the self-reported done count. */
  async listForGroup(user: AuthenticatedUser, groupId: string): Promise<GroupHomeworkView[]> {
    const groups: Array<{ id: string; branch_id: string }> = await this.dataSource.query(
      'select id, branch_id from "group" where id = $1 and deleted_at is null',
      [groupId],
    );
    const group = groups[0];
    if (!group) throw ApiError.scopeForbidden('No such group, or not yours.');
    const ability = defineAbilityFor(user);
    if (!ability.can('read', subject('Homework', { groupId: group.id, branchId: group.branch_id }))) {
      throw ApiError.scopeForbidden();
    }

    const rows: Array<{
      id: string;
      session_id: string;
      session_starts_at: Date;
      title: string | null;
      instructions: string;
      due_at: Date;
      target_child_ids: string[] | null;
      attachment_storage_key: string | null;
      created_at: Date;
      target_count: number;
      done_count: number;
    }> = await this.dataSource.query(
      `select h.id, h.session_id, s.starts_at as session_starts_at, h.title, h.instructions, h.due_at,
              h.target_child_ids, h.attachment_storage_key, h.created_at,
              (select count(*) from homework_status hs where hs.homework_id = h.id)::int as target_count,
              (select count(*) from homework_status hs where hs.homework_id = h.id and hs.done)::int as done_count
         from homework h
         join session s on s.id = h.session_id
        where h.group_id = $1 and h.deleted_at is null
        order by h.due_at desc, h.created_at desc
        limit 50`,
      [group.id],
    );
    const now = Date.now();
    return rows.map((row) => ({
      id: row.id,
      session_id: row.session_id,
      session_starts_at: row.session_starts_at.toISOString(),
      title: row.title,
      instructions: row.instructions,
      due_at: row.due_at.toISOString(),
      target_child_ids: row.target_child_ids,
      target_count: row.target_count,
      done_count: row.done_count,
      attachment_url: row.attachment_storage_key ? `/api/v1/media/${row.attachment_storage_key}` : null,
      created_at: row.created_at.toISOString(),
      is_open: row.due_at.getTime() >= now,
    }));
  }
}
