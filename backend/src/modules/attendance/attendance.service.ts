import { Inject, Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { Queue } from 'bullmq';
import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';
import {
  AbsenceAlertJob,
  CriticalJob,
  QUEUE_CRITICAL,
} from '../../common/queue/queues';
import { AttendanceRecordInputDto } from './dto/attendance.dto';

export type AttendanceStatus = 'present' | 'absent' | 'late' | 'excused';

/** One row of the sheet: a child, their presence answer, and any mark. */
export interface AttendanceSheetRow {
  child_id: string;
  child: {
    id: string;
    full_name: string;
    photo_url: string | null;
    health_alert: boolean;
  };
  presence_answer: { answer: string; reason: string | null } | null;
  status: AttendanceStatus | null;
  recorded_by: string | null;
  recorded_at: string | null;
}

export interface AttendanceSheetView {
  data: AttendanceSheetRow[];
  session: {
    id: string;
    group_id: string;
    group_name: string;
    starts_at: string;
    ends_at: string | null;
  };
}

/** What a PATCH did, per child. */
export interface ApplyResult {
  applied: string[];
  alertsEnqueued: string[];
}

interface SessionRow {
  id: string;
  group_id: string;
  group_name: string;
  branch_id: string;
  starts_at: Date;
  ends_at: Date | null;
}

@Injectable()
export class AttendanceService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    @Inject(QUEUE_CRITICAL) private readonly criticalQueue: Queue,
  ) {}

  /**
   * The attendance sheet, pre-filled from presence answers (`ATT-06`).
   *
   * A sheet is a row per *enrolled child*, not per existing attendance record —
   * children with no mark yet are the whole point of opening it. So the query
   * is driven by `child_group` and left-joins the record, and a child with no
   * mark comes back with a null status rather than being absent from the list.
   *
   * This settles the contract gap the mobile DTO flagged: `AttendanceRecord`
   * alone cannot drive this screen, which needs each child's name, a
   * health-alert flag and the guardian's presence answer. Those arrive nested
   * under `child` and `presence_answer`, matching the names the rest of the
   * contract already uses.
   */
  async sheet(
    user: AuthenticatedUser,
    sessionId: string,
  ): Promise<AttendanceSheetView> {
    const session = await this.loadSession(sessionId);
    this.assertCanReadSession(user, session);

    const rows: Array<{
      child_id: string;
      full_name: string;
      photo_url: string | null;
      health_alert: boolean;
      answer: string | null;
      reason: string | null;
      status: AttendanceStatus | null;
      recorded_by: string | null;
      recorded_at: Date | null;
    }> = await this.dataSource.query(
      `select c.id as child_id,
              c.full_name,
              c.photo_url,
              (c.health_json is not null and c.health_json <> '{}'::jsonb) as health_alert,
              pa.answer,
              pa.reason,
              ar.status,
              ar.recorded_by,
              ar.recorded_at
         from child_group cg
         join child c on c.id = cg.child_id and c.deleted_at is null
         left join presence_confirmation pc on pc.session_id = $1
         left join presence_answer pa
                on pa.presence_confirmation_id = pc.id and pa.child_id = c.id
         left join attendance_record ar
                on ar.session_id = $1 and ar.child_id = c.id
               and ar.superseded_at is null
        where cg.group_id = $2
          and cg.valid_to is null
        order by c.full_name, c.id`,
      [sessionId, session.group_id],
    );

    return {
      data: rows.map((row) => ({
        child_id: row.child_id,
        child: {
          id: row.child_id,
          full_name: row.full_name,
          // The flag, never the text. An attendance list is read in a room
          // with parents at the door (`specs/13-roadmap-and-tickets.md`).
          photo_url: row.photo_url,
          health_alert: row.health_alert,
        },
        presence_answer: row.answer
          ? { answer: row.answer, reason: row.reason }
          : null,
        status: row.status,
        recorded_by: row.recorded_by,
        recorded_at: row.recorded_at ? row.recorded_at.toISOString() : null,
      })),
      session: {
        id: session.id,
        group_id: session.group_id,
        group_name: session.group_name,
        starts_at: session.starts_at.toISOString(),
        ends_at: session.ends_at ? session.ends_at.toISOString() : null,
      },
    };
  }

  /**
   * Applies marks, enforcing the conflict rule and firing absence alerts.
   *
   * Two rules from `specs/03-domain-model/entities.md` govern every write here,
   * and both exist because two educators can mark the same group from two
   * phones that were offline:
   *
   * 1. **The conflict rule.** A write whose `recorded_at_client` predates the
   *    stored row's `recorded_at` is rejected with `attendance.conflict`,
   *    carrying both sides — never silently overwritten. The device that lost
   *    has to be able to show its educator what happened.
   * 2. **Corrections are new rows.** A later mark does not update the old one;
   *    it inserts a fresh record with `corrected_from` pointing at what it
   *    supersedes, so the audit trail is queryable without joining the audit
   *    log at all.
   *
   * The whole batch runs in one transaction, and the alert jobs are enqueued
   * **before it returns** (`RAEED-18`) — an alert enqueued after the response
   * would be an alert that a crashed process silently drops.
   */
  async apply(
    user: AuthenticatedUser,
    sessionId: string,
    records: AttendanceRecordInputDto[],
  ): Promise<ApplyResult> {
    const session = await this.loadSession(sessionId);
    this.assertCanMarkSession(user, session);

    const enrolled = await this.enrolledChildIds(session.group_id);
    const applied: string[] = [];
    const alerts: AbsenceAlertJob[] = [];

    await this.dataSource.transaction(async (tx) => {
      for (const record of records) {
        if (!enrolled.has(record.child_id)) {
          // The child moved groups, very likely while the marking device was
          // offline. This can never succeed, so it is refused outright rather
          // than left to retry forever.
          throw ApiError.attendanceUnknownChild(record.child_id);
        }

        const alert = await this.applyOne(tx, user, session, record);
        applied.push(record.child_id);
        if (alert) alerts.push(alert);
      }
    });

    // Enqueued after the transaction commits but before the response is
    // written: a job referencing an attendance_record that was rolled back
    // would alert guardians about an absence that was never recorded.
    for (const alert of alerts) {
      await this.criticalQueue.add(CriticalJob.ABSENCE_ALERT, alert, {
        // Idempotent by attendance record: a retried PATCH for the same mark
        // must not produce a second alert. An absence alert firing twice is
        // two messages to a guardian about one absence.
        jobId: `absence-${alert.attendanceRecordId}`,
      });
    }

    return { applied, alertsEnqueued: alerts.map((alert) => alert.childId) };
  }

  /** Applies one mark inside the batch transaction. */
  private async applyOne(
    tx: EntityManager,
    user: AuthenticatedUser,
    session: SessionRow,
    record: AttendanceRecordInputDto,
  ): Promise<AbsenceAlertJob | null> {
    const recordedAtClient = new Date(record.recorded_at_client);

    // Locked for the length of the transaction, so two concurrent PATCHes for
    // the same child serialise rather than both reading "no record" and both
    // inserting.
    const existing: Array<{
      id: string;
      status: AttendanceStatus;
      recorded_at: Date;
      recorded_by: string;
    }> = await tx.query(
      `select id, status, recorded_at, recorded_by
         from attendance_record
        where session_id = $1 and child_id = $2 and superseded_at is null
        for update`,
      [session.id, record.child_id],
    );
    const current = existing[0];

    if (current) {
      // The conflict rule, stated once, here.
      if (recordedAtClient.getTime() < current.recorded_at.getTime()) {
        throw ApiError.attendanceConflict({
          child_id: record.child_id,
          current: {
            status: current.status,
            recorded_at: current.recorded_at.toISOString(),
          },
        });
      }

      // A correction. The superseded row is **kept** and pointed at: only its
      // `superseded_at` tombstone is set, so its status, who recorded it and
      // when all survive untouched. That is what makes the attendance trail
      // readable straight from this table, without joining the audit log.
      //
      // The uniqueness rule is partial (`superseded_at is null`) precisely so
      // both rows can coexist — see migration 1757700002000.
      await tx.query(
        `update attendance_record set superseded_at = now() where id = $1`,
        [current.id],
      );
      const inserted = await this.insertRecord(
        tx,
        session,
        record,
        user.id,
        current.id,
      );

      // The audit entry records the correction specifically: who changed an
      // attendance mark, and away from what (`AUD-02`).
      await this.writeAudit(tx, user.id, 'attendance.correct', inserted.id, {
        child_id: record.child_id,
        from: current.status,
        to: record.status,
      });

      return this.alertFor(tx, session, record, inserted);
    }

    const inserted = await this.insertRecord(tx, session, record, user.id, null);
    return this.alertFor(tx, session, record, inserted);
  }

  private async insertRecord(
    tx: EntityManager,
    session: SessionRow,
    record: AttendanceRecordInputDto,
    recordedBy: string,
    correctedFrom: string | null,
  ): Promise<{ id: string; recorded_at: Date }> {
    const rows: Array<{ id: string; recorded_at: Date }> = await tx.query(
      `insert into attendance_record
         (session_id, child_id, status, recorded_by, recorded_at_client, corrected_from)
       values ($1, $2, $3, $4, $5, $6)
       returning id, recorded_at`,
      [
        session.id,
        record.child_id,
        record.status,
        recordedBy,
        record.recorded_at_client,
        correctedFrom,
      ],
    );
    return rows[0];
  }

  /**
   * Decides whether this mark is an *unexplained* absence (`ATT-07`).
   *
   * Only `absent` with no prior declared absence qualifies. A guardian who
   * already answered "no" — or "late", which is also a warning — has told the
   * association where their child is, and alerting them about it would be the
   * app shouting a fact back at the person who reported it. That single
   * distinction is why the check is a query and not a status comparison, and
   * `specs/11-testing-strategy.md` makes it a non-negotiable test case.
   */
  private async alertFor(
    tx: EntityManager,
    session: SessionRow,
    record: AttendanceRecordInputDto,
    inserted: { id: string; recorded_at: Date },
  ): Promise<AbsenceAlertJob | null> {
    if (record.status !== 'absent') return null;

    const declared: Array<{ answer: string }> = await tx.query(
      `select pa.answer
         from presence_answer pa
         join presence_confirmation pc on pc.id = pa.presence_confirmation_id
        where pc.session_id = $1 and pa.child_id = $2`,
      [session.id, record.child_id],
    );

    const answer = declared[0]?.answer;
    if (answer === 'no' || answer === 'late') return null;

    return {
      attendanceRecordId: inserted.id,
      sessionId: session.id,
      childId: record.child_id,
      groupId: session.group_id,
      recordedAt: inserted.recorded_at.toISOString(),
    };
  }

  private async writeAudit(
    tx: EntityManager,
    actorUserId: string,
    action: string,
    resourceId: string,
    meta: Record<string, unknown>,
  ): Promise<void> {
    // Insert-only by grant, not by convention: the runtime role has no UPDATE
    // or DELETE on this table (`AUD-04`).
    await tx.query(
      `insert into audit_log_entry
         (actor_user_id, action, resource_type, resource_id, device_meta)
       values ($1, $2, 'attendance_record', $3, $4::jsonb)`,
      [actorUserId, action, resourceId, JSON.stringify(meta)],
    );
  }

  private async loadSession(sessionId: string): Promise<SessionRow> {
    const rows: SessionRow[] = await this.dataSource.query(
      `select s.id, s.group_id, g.name as group_name, g.branch_id,
              s.starts_at, s.ends_at
         from session s
         join "group" g on g.id = s.group_id
        where s.id = $1 and s.deleted_at is null`,
      [sessionId],
    );
    const session = rows[0];
    if (!session) {
      // Deliberately the same answer as "not yours". An unauthenticated
      // probe should not be able to tell a nonexistent session from one it
      // simply cannot reach.
      throw ApiError.scopeForbidden('No such session, or not yours.');
    }
    return session;
  }

  /** Reading the sheet needs read on the session's group. */
  private assertCanReadSession(user: AuthenticatedUser, session: SessionRow): void {
    const ability = defineAbilityFor(user);
    const resource = subject('Session', {
      id: session.id,
      groupId: session.group_id,
      branchId: session.branch_id,
    });
    if (!ability.can('read', resource)) throw ApiError.scopeForbidden();
  }

  /**
   * Marking needs update on an AttendanceRecord in that group.
   *
   * Checked against the session loaded from the database — its real group and
   * branch — never against anything the request supplied.
   */
  private assertCanMarkSession(user: AuthenticatedUser, session: SessionRow): void {
    const ability = defineAbilityFor(user);
    const resource = subject('AttendanceRecord', {
      groupId: session.group_id,
      branchId: session.branch_id,
    });
    if (!ability.can('update', resource)) throw ApiError.scopeForbidden();
  }

  private async enrolledChildIds(groupId: string): Promise<Set<string>> {
    const rows: Array<{ child_id: string }> = await this.dataSource.query(
      `select cg.child_id
         from child_group cg
         join child c on c.id = cg.child_id and c.deleted_at is null
        where cg.group_id = $1 and cg.valid_to is null`,
      [groupId],
    );
    return new Set(rows.map((row) => row.child_id));
  }
}
