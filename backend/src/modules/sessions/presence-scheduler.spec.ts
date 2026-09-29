import { DataSource, EntityManager } from 'typeorm';

import { PresenceScheduler } from './presence-scheduler';

describe('PresenceScheduler tick (ATT-03)', () => {
  const now = new Date('2026-09-29T18:05:00Z');

  function build(options: {
    due?: Array<Record<string, unknown>>;
    reminders?: Array<Record<string, unknown>>;
    alreadyAsked?: boolean;
  }) {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('from "group" g') && sql.includes('join season se')) return [{ id: 'g1' }];
      if (sql.includes('not exists (select 1 from presence_confirmation pc')) return options.due ?? [];
      if (sql.includes('insert into presence_confirmation')) return options.alreadyAsked ? [] : [{ id: 'pc1' }];
      if (sql.includes('pc.reminder_sent_at is null') && sql.includes('from presence_confirmation pc')) {
        return options.reminders ?? [];
      }
      if (sql.includes('update presence_confirmation set reminder_sent_at')) return [{ id: params[0] }];
      if (sql.includes('select distinct pc.guardian_user_id as user_id, u.preferred_locale')) {
        return [
          { user_id: 'p-ar', preferred_locale: 'ar' },
          { user_id: 'p-fr', preferred_locale: 'fr' },
          { user_id: 'p-none', preferred_locale: null },
        ];
      }
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      manager,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    const sessions = { ensureGenerated: jest.fn().mockResolvedValue(undefined) };
    const notify = {
      notify: jest.fn(async (_tx: unknown, ids: string[], _content: { title: string }) => ids),
      pushTo: jest.fn().mockResolvedValue(undefined),
    };
    const scheduler = new PresenceScheduler(
      dataSource,
      {} as never,
      {} as never,
      sessions as never,
      notify as never,
    );
    return { scheduler, statements, sessions, notify };
  }

  const session = { id: 's1', group_id: 'g1', group_name: 'الأشبال', starts_at: new Date('2026-09-30T15:00:00Z') };

  it('generates the coming sessions, then asks each due one once, in every guardian\'s language', async () => {
    const { scheduler, statements, sessions, notify } = build({ due: [session] });

    const outcome = await scheduler.tick(now);

    expect(sessions.ensureGenerated).toHaveBeenCalledWith(expect.anything(), ['g1'], now, expect.any(Date));
    expect(outcome).toEqual({ asked: 1, reminded: 0 });
    const insert = statements.find((s) => s.sql.includes('insert into presence_confirmation'))!;
    expect(insert.sql).toContain('on conflict (session_id) do nothing');
    // Deadline: two hours before the session, which is later than "in 30 minutes".
    expect(insert.params[2]).toEqual(new Date('2026-09-30T13:00:00Z'));
    // Arabic for the guardian with no preference and the Arabic one, French for the other.
    expect(notify.notify).toHaveBeenCalledTimes(2);
    const recipients = notify.notify.mock.calls.map((call) => call[1]).sort();
    expect(recipients).toEqual([['p-ar', 'p-none'], ['p-fr']]);
    const titles = notify.notify.mock.calls.map((call) => call[2].title);
    expect(titles.some((t: string) => t.startsWith('هل سيحضر'))).toBe(true);
    expect(titles.some((t: string) => t.startsWith('Votre enfant'))).toBe(true);
    expect(notify.pushTo).toHaveBeenCalledTimes(2);
  });

  it('a session another instance asked first is not asked again', async () => {
    const { scheduler, notify } = build({ due: [session], alreadyAsked: true });
    const outcome = await scheduler.tick(now);
    expect(outcome.asked).toBe(0);
    expect(notify.notify).not.toHaveBeenCalled();
  });

  it('reminds the unanswered guardians once, before the deadline', async () => {
    const { scheduler, statements, notify } = build({
      reminders: [{ id: 'pc1', session_id: 's1', group_id: 'g1', group_name: 'الأشبال', starts_at: session.starts_at }],
    });

    const outcome = await scheduler.tick(now);

    expect(outcome.reminded).toBe(1);
    const claim = statements.find((s) => s.sql.includes('update presence_confirmation set reminder_sent_at'))!;
    expect(claim.sql).toContain('reminder_sent_at is null');
    const unanswered = statements.find((s) => s.sql.includes('not exists (select 1 from presence_answer pa'))!;
    expect(unanswered.params).toEqual(['pc1', 'g1']);
    const titles = notify.notify.mock.calls.map((call) => call[2].title);
    expect(titles.some((t: string) => t.startsWith('تذكير'))).toBe(true);
  });
});
