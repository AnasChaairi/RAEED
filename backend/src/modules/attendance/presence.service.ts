import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError } from '../../common/http/api-error';
import { PresenceAnswerInputDto } from './dto/attendance.dto';

/** One outstanding confirmation, for one child. */
export interface PendingConfirmationView {
  id: string;
  session_id: string;
  child_id: string;
  child_name: string;
  session_starts_at: string;
  group_name: string | null;
  deadline_at: string | null;
}

@Injectable()
export class PresenceService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  /**
   * Confirmations this guardian has not answered (`ATT-04`).
   *
   * One row **per child**, not per confirmation. A confirmation belongs to a
   * session and so covers a whole group; a guardian with two children in the
   * same group owes two answers, and collapsing them would silently drop one.
   *
   * Only future or same-day sessions are returned: an unanswered confirmation
   * for last Tuesday is not a question anyone can still usefully answer, and
   * leaving it on the Home card trains people to ignore the card.
   */
  async pending(user: AuthenticatedUser): Promise<PendingConfirmationView[]> {
    return this.dataSource.query(
      `select pc.id,
              pc.session_id,
              c.id as child_id,
              c.full_name as child_name,
              to_char(s.starts_at at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as session_starts_at,
              g.name as group_name,
              to_char(pc.deadline_at at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as deadline_at
         from presence_confirmation pc
         join session s on s.id = pc.session_id and s.deleted_at is null
         join "group" g on g.id = s.group_id
         join child_group cg on cg.group_id = s.group_id and cg.valid_to is null
         join child c on c.id = cg.child_id and c.deleted_at is null
         join parent_child pion on pion.child_id = c.id
                               and pion.guardian_user_id = $1
                               and pion.unlinked_at is null
        where pc.sent_at is not null
          and s.starts_at >= date_trunc('day', now())
          and s.status <> 'cancelled'
          and not exists (
                select 1 from presence_answer pa
                 where pa.presence_confirmation_id = pc.id
                   and pa.child_id = c.id
              )
        order by s.starts_at, c.full_name`,
      [user.id],
    );
  }

  /**
   * Records a guardian's answer (`ATT-02`).
   *
   * Upserts on `(confirmation, child)`: a parent who changes their mind before
   * the session is giving a better answer, not creating a second one. The
   * schema's unique constraint makes that explicit.
   */
  async answer(
    user: AuthenticatedUser,
    confirmationId: string,
    input: PresenceAnswerInputDto,
  ): Promise<void> {
    // The ability model says a parent may answer for their own children; this
    // is that check, against the live guardianship rows rather than anything
    // the request claimed.
    if (!user.guards(input.child_id)) {
      throw ApiError.scopeForbidden(
        'You can only answer for your own children.',
      );
    }

    const rows: Array<{ session_id: string; deadline_at: Date | null }> =
      await this.dataSource.query(
        `select pc.session_id, pc.deadline_at
           from presence_confirmation pc
           join session s on s.id = pc.session_id and s.deleted_at is null
           join child_group cg on cg.group_id = s.group_id
                              and cg.child_id = $2
                              and cg.valid_to is null
          where pc.id = $1`,
        [confirmationId, input.child_id],
      );
    const confirmation = rows[0];
    if (!confirmation) {
      // Either no such confirmation, or this child is not in that session's
      // group. Same answer for both, for the same reason as everywhere else.
      throw ApiError.scopeForbidden('No such confirmation for that child.');
    }

    // A note is meaningful only with `other`; the reason set is closed
    // precisely so answering needs no typing.
    const note = input.reason === 'other' ? (input.note ?? null) : null;

    await this.dataSource.query(
      `insert into presence_answer
         (presence_confirmation_id, child_id, answer, reason, answered_by)
       values ($1, $2, $3, $4, $5)
       on conflict (presence_confirmation_id, child_id)
       do update set answer = excluded.answer,
                     reason = excluded.reason,
                     answered_by = excluded.answered_by,
                     answered_at = now()`,
      [confirmationId, input.child_id, input.answer, input.reason ?? null, user.id],
    );

    if (note !== null) {
      // `presence_answer` has no note column in schema.sql — the reason enum
      // is the recorded value. Rather than invent a column here, the free text
      // is dropped and this is flagged: adding it is a schema change with a
      // migration, not something to smuggle into a jsonb field.
      void note;
    }
  }
}
