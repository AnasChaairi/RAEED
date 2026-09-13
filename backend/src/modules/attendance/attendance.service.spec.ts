import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError, ApiErrorCode } from '../../common/http/api-error';
import { AttendanceService } from './attendance.service';

/**
 * The server side of `specs/11-testing-strategy.md`'s first two non-negotiable
 * cases.
 *
 * The mobile suite covers the client's half — what a device does with a
 * conflict, and that it submits a mark exactly once. These cover the half that
 * actually decides: the server is the only thing that can reject a stale write
 * or fire an alert, so the rules are tested here against the real SQL the
 * service issues rather than through a stubbed repository that would let a
 * wrong query pass.
 */
describe('AttendanceService', () => {
  const educator = new AuthenticatedUser(
    'educator-1',
    new Set(['educator']),
    new Set(['child-1', 'child-2']),
    new Set(['group-1']),
    null,
  );

  const session = {
    id: 'session-1',
    group_id: 'group-1',
    group_name: 'الأشبال أ',
    branch_id: 'branch-1',
    starts_at: new Date('2026-09-13T16:00:00Z'),
    ends_at: new Date('2026-09-13T18:00:00Z'),
  };

  /**
   * A fake query layer that answers by matching the SQL's shape.
   *
   * Matching on the query text keeps the test honest about *which* statement
   * runs: a service that stopped locking the row, or stopped checking presence
   * answers, would no longer match and the test would fail rather than quietly
   * pass on a stub.
   */
  function buildService(options: {
    existing?: {
      id: string;
      status: string;
      recorded_at: Date;
      recorded_by: string;
    } | null;
    presenceAnswer?: string | null;
    enrolled?: string[];
  }): {
    service: AttendanceService;
    queueAdd: jest.Mock;
    inserted: Array<Record<string, unknown>>;
    audits: Array<Record<string, unknown>>;
  } {
    const inserted: Array<Record<string, unknown>> = [];
    const audits: Array<Record<string, unknown>> = [];
    const enrolled = options.enrolled ?? ['child-1', 'child-2'];

    const runQuery = async (
      sql: string,
      params: unknown[] = [],
    ): Promise<unknown> => {
      if (sql.includes('from session s')) return [session];
      if (sql.includes('from child_group cg') && sql.includes('select cg.child_id')) {
        return enrolled.map((child_id) => ({ child_id }));
      }
      if (sql.includes('for update')) {
        return options.existing ? [options.existing] : [];
      }
      if (sql.includes('set superseded_at')) return [];
      if (sql.includes('insert into attendance_record')) {
        inserted.push({ sql, params });
        return [
          {
            id: `record-${inserted.length}`,
            recorded_at: new Date('2026-09-13T16:20:00Z'),
          },
        ];
      }
      if (sql.includes('from presence_answer pa')) {
        return options.presenceAnswer
          ? [{ answer: options.presenceAnswer }]
          : [];
      }
      if (sql.includes('insert into audit_log_entry')) {
        audits.push({ sql, params });
        return [];
      }
      return [];
    };

    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) =>
        work(manager),
    } as unknown as DataSource;

    const queueAdd = jest.fn().mockResolvedValue(undefined);
    const service = new AttendanceService(dataSource, {
      add: queueAdd,
    } as never);

    return { service, queueAdd, inserted, audits };
  }

  describe('case 1 — the conflict rule', () => {
    it('rejects a mark whose recorded_at_client predates the stored record', async () => {
      // Two devices marked the same child offline. This one's tap was earlier,
      // so the server already holds a newer truth.
      const { service, queueAdd } = buildService({
        existing: {
          id: 'record-existing',
          status: 'present',
          recorded_at: new Date('2026-09-13T16:07:00Z'),
          recorded_by: 'educator-2',
        },
      });

      const attempt = service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'absent',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      await expect(attempt).rejects.toBeInstanceOf(ApiError);
      await expect(attempt).rejects.toMatchObject({
        code: ApiErrorCode.ATTENDANCE_CONFLICT,
      });

      // And no alert: a refused mark must not notify anyone.
      expect(queueAdd).not.toHaveBeenCalled();
    });

    it('carries both sides, so the device can show what it lost to', async () => {
      const { service } = buildService({
        existing: {
          id: 'record-existing',
          status: 'present',
          recorded_at: new Date('2026-09-13T16:07:00Z'),
          recorded_by: 'educator-2',
        },
      });

      try {
        await service.apply(educator, 'session-1', [
          {
            child_id: 'child-1',
            status: 'absent',
            recorded_at_client: '2026-09-13T16:05:00Z',
          },
        ]);
        throw new Error('expected a conflict');
      } catch (error) {
        const details = (error as ApiError).details as {
          child_id: string;
          current: { status: string; recorded_at: string };
        };
        expect(details.child_id).toBe('child-1');
        expect(details.current.status).toBe('present');
        expect(details.current.recorded_at).toBe('2026-09-13T16:07:00.000Z');
      }
    });

    it('accepts a later mark as a correction, keeping the superseded row '
      + 'via corrected_from', async () => {
      // The same educator fixing a mis-tap, or a genuinely newer device.
      const { service, inserted, audits } = buildService({
        existing: {
          id: 'record-existing',
          status: 'present',
          recorded_at: new Date('2026-09-13T16:05:00Z'),
          recorded_by: 'educator-1',
        },
      });

      await service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'late',
          recorded_at_client: '2026-09-13T16:09:00Z',
        },
      ]);

      // A new row pointing at what it replaced. The old row is superseded,
      // not deleted, so the chain has something to point at — see migration
      // 1757700002000, which resolves the spec's own contradiction here.
      expect(inserted).toHaveLength(1);
      expect(inserted[0].params).toContain('record-existing');

      // And the correction is audited, with what it moved away from.
      expect(audits).toHaveLength(1);
      expect(JSON.stringify(audits[0].params)).toContain('attendance.correct');
      expect(JSON.stringify(audits[0].params)).toContain('present');
    });
  });

  describe('case 2 — an absence alert fires exactly once, and only when '
    + 'unexplained', () => {
    it('fires for an absence with no prior answer', async () => {
      const { service, queueAdd } = buildService({ presenceAnswer: null });

      const result = await service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'absent',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      expect(result.alertsEnqueued).toEqual(['child-1']);
      expect(queueAdd).toHaveBeenCalledTimes(1);
    });

    it('does NOT fire when the guardian already declared the absence', async () => {
      // The guardian told the association where their child is. Alerting them
      // would be the app shouting a fact back at the person who reported it.
      const { service, queueAdd } = buildService({ presenceAnswer: 'no' });

      const result = await service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'absent',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      expect(result.alertsEnqueued).toEqual([]);
      expect(queueAdd).not.toHaveBeenCalled();
    });

    it('does NOT fire when the guardian warned the child would be late', async () => {
      const { service, queueAdd } = buildService({ presenceAnswer: 'late' });

      await service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'absent',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      expect(queueAdd).not.toHaveBeenCalled();
    });

    it('does not fire for present, late or excused', async () => {
      for (const status of ['present', 'late', 'excused'] as const) {
        const { service, queueAdd } = buildService({ presenceAnswer: null });
        await service.apply(educator, 'session-1', [
          {
            child_id: 'child-1',
            status,
            recorded_at_client: '2026-09-13T16:05:00Z',
          },
        ]);
        expect(queueAdd).not.toHaveBeenCalled();
      }
    });

    it('deduplicates by attendance record, so a retried PATCH cannot alert '
      + 'twice', async () => {
      // Two messages to a guardian about one absence is the failure this
      // guards against.
      const { service, queueAdd } = buildService({ presenceAnswer: null });

      await service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'absent',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      const [, , options] = queueAdd.mock.calls[0] as [
        string,
        unknown,
        { jobId: string },
      ];
      expect(options.jobId).toBe('absence-record-1');
    });

    it('enqueues one alert per unexplained absence in a batch', async () => {
      const { service, queueAdd } = buildService({ presenceAnswer: null });

      const result = await service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'absent',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
        {
          child_id: 'child-2',
          status: 'present',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      expect(result.applied).toEqual(['child-1', 'child-2']);
      expect(result.alertsEnqueued).toEqual(['child-1']);
      expect(queueAdd).toHaveBeenCalledTimes(1);
    });
  });

  describe('enrolment', () => {
    it('refuses a child who is not in this session\'s group', async () => {
      // Almost always a group move that happened while the device was offline.
      const { service } = buildService({ enrolled: ['child-2'] });

      const attempt = service.apply(educator, 'session-1', [
        {
          child_id: 'child-1',
          status: 'absent',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      await expect(attempt).rejects.toMatchObject({
        code: ApiErrorCode.ATTENDANCE_UNKNOWN_CHILD,
      });
    });
  });

  describe('scope', () => {
    it('refuses an educator marking a group they do not lead', async () => {
      const outsider = new AuthenticatedUser(
        'educator-9',
        new Set(['educator']),
        new Set(),
        new Set(['group-other']),
        null,
      );
      const { service } = buildService({});

      await expect(
        service.apply(outsider, 'session-1', [
          {
            child_id: 'child-1',
            status: 'present',
            recorded_at_client: '2026-09-13T16:05:00Z',
          },
        ]),
      ).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
    });

    it('refuses a parent marking attendance at all', async () => {
      // Attendance is recorded by educators and corrected by executives. A
      // guardian marking their own child present would defeat the point.
      const parent = new AuthenticatedUser(
        'parent-1',
        new Set(['parent']),
        new Set(['child-1']),
        new Set(),
        null,
      );
      const { service } = buildService({});

      await expect(
        service.apply(parent, 'session-1', [
          {
            child_id: 'child-1',
            status: 'present',
            recorded_at_client: '2026-09-13T16:05:00Z',
          },
        ]),
      ).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
    });

    it('allows an executive to correct any group', async () => {
      const executive = new AuthenticatedUser(
        'exec-1',
        new Set(['executive']),
        new Set(),
        new Set(),
        null,
      );
      const { service } = buildService({ presenceAnswer: null });

      const result = await service.apply(executive, 'session-1', [
        {
          child_id: 'child-1',
          status: 'present',
          recorded_at_client: '2026-09-13T16:05:00Z',
        },
      ]);

      expect(result.applied).toEqual(['child-1']);
    });
  });
});
