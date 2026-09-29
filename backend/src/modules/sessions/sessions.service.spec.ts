import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { SessionsService } from './sessions.service';

describe('SessionsService', () => {
  const educator = new AuthenticatedUser('edu-1', new Set(['educator']), new Set(), new Set(['g1']), null);
  const stranger = new AuthenticatedUser('edu-2', new Set(['educator']), new Set(), new Set(['g9']), null);

  function sessionRow(overrides: Record<string, unknown> = {}): Record<string, unknown> {
    return {
      id: 's1',
      group_id: 'g1',
      group_name: 'الأشبال أ',
      branch_id: 'b1',
      title: 'حلقة القرآن',
      theme: null,
      objectives: null,
      starts_at: new Date(Date.now() + 2 * 3600 * 1000),
      ends_at: new Date(Date.now() + 4 * 3600 * 1000),
      place: 'القاعة 2',
      status: 'planned',
      is_customized: true,
      summary: null,
      summary_sent_at: null,
      cancel_reason: null,
      rescheduled_from: null,
      changed_by: null,
      changed_by_name: null,
      material_count: 0,
      homework_count: 0,
      attendance_recorded: false,
      co_educator_names: [],
      ...overrides,
    };
  }

  function buildService(row: Record<string, unknown>, confirmation?: Record<string, unknown>) {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('from session s') && sql.includes('join "group" g on g.id = s.group_id')) return [row];
      if (sql.includes('select g.id, g.branch_id, g.name from "group" g')) return [{ id: 'g1', branch_id: 'b1', name: 'الأشبال 1' }];
      if (sql.includes('insert into session (group_id, kind')) return [{ id: 's1' }];
      if (sql.includes('select preferred_locale')) return [{ preferred_locale: 'ar' }];
      if (sql.includes('from presence_confirmation where session_id')) return confirmation ? [confirmation] : [];
      if (sql.includes('update presence_confirmation set reminder_sent_at')) return [{ reminder_sent_at: new Date() }];
      if (sql.includes('returning summary_sent_at')) return [{ summary_sent_at: new Date() }];
      if (sql.includes('with kids as')) return [{ enrolled: 20, guardians: 32, families: 18 }];
      if (sql.includes('not exists (select 1 from presence_answer pa')) return [{ id: 'c1' }, { id: 'c2' }];
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      manager,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    const queueAdd = jest.fn().mockResolvedValue(undefined);
    const notify = {
      notify: jest.fn(async (_tx: unknown, ids: Iterable<string>, _content: { kind: string }) => [...new Set(ids)]),
      pushTo: jest.fn().mockResolvedValue(undefined),
      guardiansOfGroup: jest.fn().mockResolvedValue(['p1', 'p2', 'p3']),
      guardiansOfChildren: jest.fn().mockResolvedValue(['p1', 'p2']),
      educatorsOfGroup: jest.fn().mockResolvedValue(['edu-1', 'edu-3']),
      oversightUsers: jest.fn().mockResolvedValue(['exec-1']),
    };
    const service = new SessionsService(dataSource, { add: queueAdd } as never, notify as never);
    return { service, statements, queueAdd, notify };
  }

  it('an educator adds a workshop for their group: customised, guardians told, recorded', async () => {
    const { service, statements, notify } = buildService(sessionRow({ kind: 'workshop', title: 'ورشة الخط' }));

    const view = await service.create(educator, {
      group_id: 'g1',
      kind: 'workshop',
      starts_at: '2026-10-03T09:00:00Z',
      ends_at: '2026-10-03T11:00:00Z',
      title: 'ورشة الخط',
      place: 'القاعة الكبرى',
    });

    const insert = statements.find((s) => s.sql.includes('insert into session (group_id, kind'))!;
    expect(insert.sql).toContain("'planned', true");
    expect(insert.params.slice(0, 2)).toEqual(['g1', 'workshop']);
    expect(notify.notify).toHaveBeenCalledWith(
      expect.anything(),
      ['p1', 'p2', 'p3'],
      expect.objectContaining({ kind: 'other', data: { type: 'session-created', session_id: 's1' } }),
    );
    expect(statements.some((s) => s.sql.includes('audit_log_entry') && s.params.includes('session.create'))).toBe(true);
    expect(view.kind).toBe('workshop');
  });

  it('an activity that ends before it starts, or for another group, is refused', async () => {
    const { service, statements } = buildService(sessionRow());
    await expect(
      service.create(educator, { group_id: 'g1', kind: 'sport', starts_at: '2026-10-03T11:00:00Z', ends_at: '2026-10-03T09:00:00Z' }),
    ).rejects.toMatchObject({ code: ApiErrorCode.VALIDATION_FAILED });
    await expect(
      service.create(stranger, { group_id: 'g1', kind: 'sport', starts_at: '2026-10-03T09:00:00Z', ends_at: '2026-10-03T11:00:00Z' }),
    ).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
    expect(statements.some((s) => s.sql.includes('insert into session'))).toBe(false);
  });

  it('refuses a session outside the educator’s groups', async () => {
    const { service } = buildService(sessionRow());
    await expect(service.detail(stranger, 's1')).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });

  it('a cancellation within 24h tells everyone on the critical lane, recorded', async () => {
    const { service, statements, queueAdd, notify } = buildService(sessionRow());

    const result = await service.change(educator, 's1', { mode: 'cancel', reason: 'غياب اضطراري' });

    // Guardians, the co-educator and the executive — never the caller.
    const [, recipients, content] = notify.notify.mock.calls[0]!;
    expect([...recipients]).toEqual(['p1', 'p2', 'p3', 'edu-3', 'exec-1']);
    expect(content!.kind).toBe('critical');
    expect(result).toEqual({ notified_count: 5, guardian_count: 3 });
    expect(queueAdd).toHaveBeenCalledWith('session-change', expect.objectContaining({ sessionId: 's1', mode: 'cancel' }), expect.anything());
    const audit = statements.find((s) => s.sql.includes('insert into audit_log_entry'));
    expect(audit?.params[1]).toBe('session.cancel');
    expect(statements.some((s) => s.sql.includes("set status = 'cancelled'"))).toBe(true);
  });

  it('a change more than a day out is a normal notice, not a critical one', async () => {
    const { service, queueAdd, notify } = buildService(
      sessionRow({ starts_at: new Date(Date.now() + 3 * 24 * 3600 * 1000) }),
    );
    await service.change(educator, 's1', {
      mode: 'reschedule',
      reason: 'صيانة القاعة',
      starts_at: new Date(Date.now() + 4 * 24 * 3600 * 1000).toISOString(),
      ends_at: new Date(Date.now() + 4 * 24 * 3600 * 1000 + 7_200_000).toISOString(),
    });
    expect(notify.notify.mock.calls[0]![2]!.kind).toBe('other');
    expect(queueAdd).not.toHaveBeenCalled();
  });

  it('rescheduling needs the new slot', async () => {
    const { service } = buildService(sessionRow());
    await expect(service.change(educator, 's1', { mode: 'reschedule', reason: 'x' })).rejects.toMatchObject({
      code: ApiErrorCode.VALIDATION_FAILED,
    });
  });

  it('the presence reminder goes out once', async () => {
    const sent = { id: 'pc1', sent_at: new Date(), deadline_at: null, reminder_sent_at: null };
    const { service, notify } = buildService(sessionRow(), sent);
    const first = await service.remind(educator, 's1');
    expect(first.reminded_count).toBe(2);
    expect(notify.guardiansOfChildren).toHaveBeenCalledWith(expect.anything(), ['c1', 'c2']);

    const { service: again } = buildService(sessionRow(), { ...sent, reminder_sent_at: new Date() });
    await expect(again.remind(educator, 's1')).rejects.toMatchObject({
      code: ApiErrorCode.PRESENCE_REMINDER_ALREADY_SENT,
    });
  });

  it('the summary is sent to the group’s guardians once', async () => {
    const { service, notify } = buildService(sessionRow());
    const result = await service.sendSummary(educator, 's1', { body: 'حفظنا الآيات 6–10.' });
    expect(result.family_count).toBe(18);
    expect(notify.notify.mock.calls[0]![2]!.kind).toBe('other');

    const { service: again } = buildService(sessionRow({ summary_sent_at: new Date() }));
    await expect(again.sendSummary(educator, 's1', { body: 'x' })).rejects.toMatchObject({
      code: ApiErrorCode.SESSION_SUMMARY_ALREADY_SENT,
    });
  });
});
