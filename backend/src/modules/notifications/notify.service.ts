import { Injectable } from '@nestjs/common';
import { EntityManager } from 'typeorm';

import { PushDispatcher } from './push.dispatcher';

export type NotificationKind = 'critical' | 'request' | 'memories' | 'security' | 'other';
export type NotificationDestination =
  | 'groups'
  | 'memories'
  | 'messages'
  | 'announcements'
  | 'notifications';

export interface NotificationContent {
  readonly kind: NotificationKind;
  readonly title: string;
  readonly body?: string | null;
  readonly destination?: NotificationDestination | null;
  /** Free-form data carried in the push payload for deep-linking. */
  readonly data?: Record<string, string>;
}

/**
 * Writes one notification per recipient and hands the push to the
 * dispatcher.
 *
 * The rows are written inside the caller's transaction so a cancelled
 * session and the notices about it land or roll back together; the push
 * goes out afterwards, from the same list, because a push about a change
 * that did not commit would be a lie. Recipients are de-duplicated: a
 * guardian who is also the group's educator is told once.
 */
@Injectable()
export class NotifyService {
  constructor(private readonly push: PushDispatcher) {}

  async notify(
    tx: EntityManager,
    userIds: Iterable<string>,
    content: NotificationContent,
  ): Promise<string[]> {
    const recipients = [...new Set(userIds)];
    if (recipients.length === 0) return [];

    await tx.query(
      `insert into notification (user_id, kind, title, body, destination)
       select u, $2, $3, $4, $5 from unnest($1::uuid[]) as u`,
      [recipients, content.kind, content.title, content.body ?? null, content.destination ?? null],
    );
    return recipients;
  }

  /** Pushes to every live device of [userIds]; safe to call after commit. */
  async pushTo(
    tx: EntityManager,
    userIds: string[],
    content: NotificationContent,
  ): Promise<void> {
    if (userIds.length === 0) return;
    const rows: Array<{ push_token: string }> = await tx.query(
      `select ud.push_token
         from user_device ud
        where ud.user_id = any($1::uuid[]) and ud.revoked_at is null
          and ud.push_token is not null`,
      [userIds],
    );
    if (rows.length === 0) return;
    await this.push.send({
      tokens: rows.map((row) => row.push_token),
      data: { title: content.title, body: content.body ?? '', ...(content.data ?? {}) },
    });
  }

  /** The active guardians of every child currently in [groupId]. */
  async guardiansOfGroup(tx: EntityManager, groupId: string): Promise<string[]> {
    const rows: Array<{ user_id: string }> = await tx.query(
      `select distinct pc.guardian_user_id as user_id
         from child_group cg
         join child c on c.id = cg.child_id and c.deleted_at is null
         join parent_child pc on pc.child_id = c.id and pc.unlinked_at is null
         join app_user u on u.id = pc.guardian_user_id and u.is_active
        where cg.group_id = $1 and cg.valid_to is null`,
      [groupId],
    );
    return rows.map((row) => row.user_id);
  }

  /** The active guardians of exactly [childIds]. */
  async guardiansOfChildren(tx: EntityManager, childIds: string[]): Promise<string[]> {
    if (childIds.length === 0) return [];
    const rows: Array<{ user_id: string }> = await tx.query(
      `select distinct pc.guardian_user_id as user_id
         from parent_child pc
         join app_user u on u.id = pc.guardian_user_id and u.is_active
        where pc.child_id = any($1::uuid[]) and pc.unlinked_at is null`,
      [childIds],
    );
    return rows.map((row) => row.user_id);
  }

  /** The group's current educators. */
  async educatorsOfGroup(tx: EntityManager, groupId: string): Promise<string[]> {
    const rows: Array<{ user_id: string }> = await tx.query(
      `select ge.educator_user_id as user_id
         from group_educator ge
        where ge.group_id = $1 and ge.unassigned_at is null`,
      [groupId],
    );
    return rows.map((row) => row.user_id);
  }

  /** Every executive and admin. */
  async oversightUsers(tx: EntityManager): Promise<string[]> {
    const rows: Array<{ user_id: string }> = await tx.query(
      `select distinct ra.user_id from role_assignment ra
        where ra.role in ('executive', 'admin')`,
    );
    return rows.map((row) => row.user_id);
  }
}
