import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { Locale, loadLocale, pick } from '../../common/i18n/user-locale';
import { ApiError } from '../../common/http/api-error';
import { displayNameOf } from '../../common/sql/display-name';
import { RoleName } from '../identity/entities/role-assignment.entity';

export type ConversationType = 'child' | 'staff' | 'executive';

export interface ConversationSummaryView {
  id: string;
  type: ConversationType;
  title: string;
  is_member: boolean;
  /** The group a child or staff thread belongs to — how the educator's list is sectioned. */
  group_name: string | null;
  last_message: { preview: string | null; sent_at: string } | null;
  unread_count: number;
  has_open_report: boolean;
}

export interface ConversationDetailView {
  id: string;
  type: ConversationType;
  title: string;
  is_member: boolean;
  /** "سعاد (الأم)" — a name and a role word, never a phone (`MSG-06`). */
  members: Array<{ id: string; label: string; role: RoleName | null }>;
}

export interface MessageView {
  id: string;
  sender: { id: string; display_name: string; role: RoleName | null };
  kind: 'text' | 'voice' | 'file';
  body: string | null;
  duration_seconds: number | null;
  created_at: string;
  hidden: { by_name: string; by_id: string; at: string } | null;
  report: { id: string; reporter_name: string; reporter_id: string; reason: string } | null;
}

interface ConversationRow {
  group_name: string | null;
  id: string;
  type: ConversationType;
  ref_child_id: string | null;
  ref_group_id: string | null;
  group_id: string | null;
  branch_id: string | null;
  title: string | null;
}

/**
 * Conversations with executive oversight (`MSG-08`).
 *
 * Membership is derived from live relationships, never stored: a child's
 * thread belongs to that child's current guardians and the educators of
 * their current group; a staff channel to the group's educators; the
 * executive channel to every oversight role. An executive reads any thread
 * in their branch scope, and a read of one they are not a member of is
 * written to the audit log before a single message is returned.
 *
 * No phone number appears in any payload here (`MSG-06`), and no message is
 * ever deleted by this service: hiding sets `hidden_at`/`hidden_by`, and the
 * row stays.
 */
@Injectable()
export class MessagingService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  async list(user: AuthenticatedUser): Promise<ConversationSummaryView[]> {
    const locale = await loadLocale(this.dataSource, user.id);
    const params: unknown[] = [];
    const where: string[] = [];

    if (user.hasOversight) {
      if (user.branchId) {
        params.push(user.branchId);
        where.push(`(cv.branch_id is null or cv.branch_id = $${params.length})`);
      }
    } else {
      params.push([...user.reachableChildIds], [...user.reachableGroupIds]);
      where.push(
        `((cv.type = 'child' and (cv.ref_child_id = any($1::uuid[]) or cv.group_id = any($2::uuid[])))
          or (cv.type = 'staff' and cv.ref_group_id = any($2::uuid[]))
          ${user.hasRole('educator') ? "or cv.type = 'executive'" : ''})`,
      );
    }

    const rows: Array<
      ConversationRow & {
        last_body: string | null;
        last_kind: string | null;
        last_at: Date | null;
        has_open_report: boolean;
      }
    > = await this.dataSource.query(
      `${this.conversationCte()}
       select cv.*,
              lm.body as last_body, lm.kind as last_kind, lm.created_at as last_at,
              exists (select 1 from message_report r
                        join message m on m.id = r.message_id
                       where m.conversation_id = cv.id and r.resolved_at is null)
                as has_open_report
         from conv cv
         left join lateral (
           select m.body, m.kind, m.created_at
             from message m
            where m.conversation_id = cv.id and m.hidden_at is null
            order by m.created_at desc
            limit 1
         ) lm on true
        ${where.length ? `where ${where.join(' and ')}` : ''}
        order by lm.created_at desc nulls last, cv.id`,
      params,
    );

    return rows.map((row) => ({
      id: row.id,
      type: row.type,
      title: this.titleOf(row, locale),
      is_member: this.isMember(user, row),
      group_name: row.group_name,
      last_message: row.last_at
        ? {
            preview:
              row.last_kind === 'text'
                ? row.last_body
                : pick(locale, { ar: 'رسالة صوتية', fr: 'Message vocal', en: 'Voice note' }),
            sent_at: row.last_at.toISOString(),
          }
        : null,
      // Read tracking per user lands with the rest of Epic E.
      unread_count: 0,
      has_open_report: row.has_open_report,
    }));
  }

  async detail(
    user: AuthenticatedUser,
    conversationId: string,
  ): Promise<ConversationDetailView> {
    const row = await this.loadReadable(user, conversationId);
    const locale = await loadLocale(this.dataSource, user.id);
    const members = await this.members(row);
    return {
      id: row.id,
      type: row.type,
      title: this.titleOf(row, locale),
      is_member: this.isMember(user, row),
      members: members.map((member) => {
        const roleWord = this.roleLabel(locale, member.role, member.relationship);
        return {
          id: member.id,
          role: member.role,
          label: member.display_name ? `${member.display_name} (${roleWord})` : roleWord,
        };
      }),
    };
  }

  /**
   * The thread, oldest first.
   *
   * A non-member's read is oversight and is recorded before the rows are
   * returned — the disclosure the members see in their thread header is
   * only honest if the log behind it is written every time.
   */
  async messages(
    user: AuthenticatedUser,
    conversationId: string,
  ): Promise<MessageView[]> {
    const row = await this.loadReadable(user, conversationId);
    const member = this.isMember(user, row);

    if (!member) {
      await this.dataSource.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id)
         values ($1, 'conversation.oversight_read', 'conversation', $2)`,
        [user.id, row.id],
      );
    }

    const rows: Array<{
      id: string;
      sender_id: string;
      sender_role: RoleName | null;
      kind: MessageView['kind'];
      body: string | null;
      hidden_at: Date | null;
      hidden_by: string | null;
      created_at: Date;
      report_id: string | null;
      reported_by: string | null;
      reason: string | null;
      sender_name: string;
      hidden_by_name: string;
      reporter_name: string;
    }> = await this.dataSource.query(
      `select m.id, m.sender_id, m.kind, m.body, m.hidden_at, m.hidden_by, m.created_at,
              ${this.roleSubquery('m.sender_id')} as sender_role,
              ${displayNameOf('m.sender_id')} as sender_name,
              coalesce(${displayNameOf('m.hidden_by')}, '') as hidden_by_name,
              coalesce(${displayNameOf('r.reported_by')}, '') as reporter_name,
              r.id as report_id, r.reported_by, r.reason
         from message m
         left join lateral (
           select r.id, r.reported_by, r.reason
             from message_report r
            where r.message_id = m.id and r.resolved_at is null
            order by r.created_at
            limit 1
         ) r on true
        where m.conversation_id = $1
        order by m.created_at, m.id
        limit 300`,
      [row.id],
    );

    return rows.map((message) => ({
      id: message.id,
      sender: { id: message.sender_id, display_name: message.sender_name ?? '', role: message.sender_role },
      kind: message.kind,
      // A hidden message's text stays visible to oversight, marked as
      // hidden; members get the stub with no body.
      body: message.hidden_at && !user.hasOversight ? null : message.body,
      duration_seconds: null,
      created_at: message.created_at.toISOString(),
      hidden: message.hidden_at
        ? {
            by_name: message.hidden_by_name ?? '',
            by_id: message.hidden_by ?? '',
            at: message.hidden_at.toISOString(),
          }
        : null,
      report:
        message.report_id && user.hasOversight
          ? {
              id: message.report_id,
              reporter_name: message.reporter_name ?? '',
              reporter_id: message.reported_by ?? '',
              reason: message.reason ?? '',
            }
          : null,
    }));
  }

  async send(
    user: AuthenticatedUser,
    conversationId: string,
    body: string,
  ): Promise<MessageView> {
    const row = await this.loadReadable(user, conversationId);
    const rows: Array<{ id: string; created_at: Date; role: RoleName | null; name: string }> =
      await this.dataSource.query(
        `insert into message (conversation_id, sender_id, kind, body)
         values ($1, $2, 'text', $3)
         returning id, created_at, ${this.roleSubquery('sender_id')} as role,
                   ${displayNameOf('sender_id')} as name`,
        [row.id, user.id, body.trim()],
      );
    const inserted = rows[0];
    return {
      id: inserted.id,
      sender: { id: user.id, display_name: inserted.name ?? '', role: inserted.role },
      kind: 'text',
      body: body.trim(),
      duration_seconds: null,
      created_at: inserted.created_at.toISOString(),
      hidden: null,
      report: null,
    };
  }

  /** Hides a message and closes any open report on it. Never a deletion. */
  async hide(user: AuthenticatedUser, messageId: string): Promise<void> {
    const message = await this.loadMessageForOversight(user, messageId);

    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update message set hidden_at = now(), hidden_by = $2
          where id = $1 and hidden_at is null`,
        [message.id, user.id],
      );
      await tx.query(
        `update message_report
            set resolved_at = now(), resolved_by = $2, resolution = 'hidden'
          where message_id = $1 and resolved_at is null`,
        [message.id, user.id],
      );
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'message.hide', 'message', $2, $3::jsonb)`,
        [user.id, message.id, JSON.stringify({ conversation_id: message.conversation_id })],
      );
    });
  }

  /** Closes a report without touching the message. */
  async dismissReport(user: AuthenticatedUser, reportId: string): Promise<void> {
    const reports: Array<{ id: string; message_id: string }> =
      await this.dataSource.query(
        'select id, message_id from message_report where id = $1 and resolved_at is null',
        [reportId],
      );
    const report = reports[0];
    if (!report) throw ApiError.scopeForbidden('No such open report, or not yours.');
    await this.loadMessageForOversight(user, report.message_id);

    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update message_report
            set resolved_at = now(), resolved_by = $2, resolution = 'dismissed'
          where id = $1 and resolved_at is null`,
        [report.id, user.id],
      );
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'message_report.dismiss', 'message_report', $2, $3::jsonb)`,
        [user.id, report.id, JSON.stringify({ message_id: report.message_id })],
      );
    });
  }

  // --- Scope ----------------------------------------------------------------

  /**
   * Conversations with the group and branch they belong to, resolved from
   * the child's current main group or the staff channel's group.
   */
  private conversationCte(): string {
    return `with conv as (
              select cv.id, cv.type, cv.ref_child_id, cv.ref_group_id,
                     coalesce(gs.id, gc.id) as group_id,
                     coalesce(gs.name, gc.name) as group_name,
                     coalesce(gs.branch_id, gc.branch_id) as branch_id,
                     coalesce(c.full_name, gs.name) as title
                from conversation cv
                left join "group" gs on gs.id = cv.ref_group_id
                left join child c on c.id = cv.ref_child_id
                left join child_group cg on cg.child_id = cv.ref_child_id
                       and cg.valid_to is null and cg.is_main
                left join "group" gc on gc.id = cg.group_id
            )`;
  }

  private roleSubquery(userIdExpression: string): string {
    return `(select ra.role from role_assignment ra
              where ra.user_id = ${userIdExpression}
              order by case ra.role when 'admin' then 0 when 'executive' then 1
                                    when 'educator' then 2 else 3 end
              limit 1)`;
  }

  private async loadConversation(conversationId: string): Promise<ConversationRow> {
    const rows: ConversationRow[] = await this.dataSource.query(
      `${this.conversationCte()} select * from conv where id = $1`,
      [conversationId],
    );
    const row = rows[0];
    if (!row) throw ApiError.scopeForbidden('No such conversation, or not yours.');
    return row;
  }

  /**
   * Loads a conversation the caller may read: a member, or oversight within
   * branch scope, checked against the row's own relationships.
   *
   * Guardians' `read` on `Conversation` is granted here by membership
   * until Epic E adds it to the ability model.
   */
  private async loadReadable(
    user: AuthenticatedUser,
    conversationId: string,
  ): Promise<ConversationRow> {
    const row = await this.loadConversation(conversationId);
    if (this.isMember(user, row)) return row;

    const ability = defineAbilityFor(user);
    const resource = subject('Conversation', {
      id: row.id,
      type: row.type,
      groupId: row.group_id,
      branchId: row.branch_id,
    });
    if (!user.hasOversight || !ability.can('read', resource)) {
      throw ApiError.scopeForbidden();
    }
    return row;
  }

  private async loadMessageForOversight(
    user: AuthenticatedUser,
    messageId: string,
  ): Promise<{ id: string; conversation_id: string }> {
    const rows: Array<{ id: string; conversation_id: string }> =
      await this.dataSource.query(
        'select id, conversation_id from message where id = $1',
        [messageId],
      );
    const message = rows[0];
    if (!message) throw ApiError.scopeForbidden('No such message, or not yours.');
    const conversation = await this.loadConversation(message.conversation_id);

    // Hiding is an oversight power (`MSG-08`), never a member's.
    const ability = defineAbilityFor(user);
    const inScope = ability.can(
      'read',
      subject('Conversation', {
        id: conversation.id,
        type: conversation.type,
        groupId: conversation.group_id,
        branchId: conversation.branch_id,
      }),
    );
    if (!user.hasOversight || !inScope) throw ApiError.scopeForbidden();
    return message;
  }

  private isMember(user: AuthenticatedUser, row: ConversationRow): boolean {
    switch (row.type) {
      case 'child':
        return (
          (row.ref_child_id !== null && user.guards(row.ref_child_id)) ||
          (row.group_id !== null && user.leads(row.group_id))
        );
      case 'staff':
        // The group's educators and the executives who oversee them.
        return (row.ref_group_id !== null && user.leads(row.ref_group_id)) || user.hasOversight;
      case 'executive':
        // Management ↔ staff: every educator and every executive.
        return user.hasOversight || user.hasRole('educator');
    }
  }

  private async members(
    row: ConversationRow,
  ): Promise<
    Array<{ id: string; display_name: string; role: RoleName | null; relationship: string | null }>
  > {
    const name = displayNameOf('u.id');
    switch (row.type) {
      case 'child':
        return this.dataSource.query(
          `select u.id, ${name} as display_name, 'parent'::text as role,
                  pc.relationship_type as relationship
             from parent_child pc join app_user u on u.id = pc.guardian_user_id
            where pc.child_id = $1 and pc.unlinked_at is null
           union all
           select u.id, ${name}, 'educator', null
             from group_educator ge join app_user u on u.id = ge.educator_user_id
            where ge.group_id = $2 and ge.unassigned_at is null`,
          [row.ref_child_id, row.group_id],
        );
      case 'staff':
        return this.dataSource.query(
          `select u.id, ${name} as display_name, 'educator'::text as role, null::text as relationship
             from group_educator ge join app_user u on u.id = ge.educator_user_id
            where ge.group_id = $1 and ge.unassigned_at is null
           union
           select distinct u.id, ${name}, ra.role::text, null::text
             from role_assignment ra join app_user u on u.id = ra.user_id
            where ra.role in ('executive', 'admin')`,
          [row.ref_group_id],
        );
      case 'executive':
        return this.dataSource.query(
          `select distinct u.id, ${name} as display_name, ra.role::text as role, null::text as relationship
             from role_assignment ra join app_user u on u.id = ra.user_id
            where ra.role in ('executive', 'admin', 'educator')`,
        );
    }
  }

  private titleOf(row: ConversationRow, locale: Locale): string {
    if (row.title) return row.title;
    return pick(locale, {
      ar: 'المكتب المسيّر',
      fr: 'Bureau exécutif',
      en: 'Executive board',
    });
  }

  private roleLabel(
    locale: Locale,
    role: RoleName | null,
    relationship: string | null,
  ): string {
    if (role === 'parent') {
      switch (relationship) {
        case 'mother':
        case 'الأم':
          return pick(locale, { ar: 'الأم', fr: 'la mère', en: 'mother' });
        case 'father':
        case 'الأب':
          return pick(locale, { ar: 'الأب', fr: 'le père', en: 'father' });
        default:
          return pick(locale, { ar: 'ولي الأمر', fr: 'parent', en: 'guardian' });
      }
    }
    switch (role) {
      case 'educator':
        return pick(locale, { ar: 'مؤطر', fr: 'éducateur', en: 'educator' });
      case 'executive':
        return pick(locale, { ar: 'مشرف', fr: 'responsable', en: 'executive' });
      case 'admin':
        return pick(locale, { ar: 'مدير النظام', fr: 'administrateur', en: 'admin' });
      default:
        return pick(locale, { ar: 'عضو', fr: 'membre', en: 'member' });
    }
  }
}
