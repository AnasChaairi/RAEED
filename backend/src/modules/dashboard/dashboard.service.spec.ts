import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { DashboardService } from './dashboard.service';

describe('DashboardService', () => {
  const executive = new AuthenticatedUser(
    'exec-1',
    new Set(['executive']),
    new Set(),
    new Set(),
    null,
  );
  const restricted = new AuthenticatedUser(
    'exec-2',
    new Set(['executive']),
    new Set(),
    new Set(),
    'branch-1',
  );

  function buildService(answers: {
    unrecorded?: number;
    absences?: number;
    overCapacity?: Array<{ id: string; name: string; capacity: number; enrolled: number }>;
    pending?: number;
    reports?: number;
    weeks?: Array<{ expected: number; present: number }>;
  }): { service: DashboardService; statements: Array<{ sql: string; params: unknown[] }> } {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const at = new Date('2026-09-20T08:00:00Z');
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('select preferred_locale')) return [{ preferred_locale: 'ar' }];
      if (sql.includes('and s.ends_at < now()')) return [{ n: answers.unrecorded ?? 0, at }];
      if (sql.includes("ar.status = 'absent'")) return [{ n: answers.absences ?? 0, at }];
      if (sql.includes('having count(c.id) > g.capacity')) {
        return (answers.overCapacity ?? []).map((g) => ({ ...g, since: at }));
      }
      if (sql.includes('from post p')) return [{ n: answers.pending ?? 0, at }];
      if (sql.includes('from message_report r')) return [{ n: answers.reports ?? 0, at }];
      if (sql.includes('with scoped_groups')) {
        return [{ children: 246, families: 163, groups: 14, educators: 18 }];
      }
      if (sql.includes('generate_series')) {
        return (answers.weeks ?? []).map((week, index) => ({
          week_start: new Date(2026, 6, 6 + index * 7),
          ...week,
        }));
      }
      return [];
    };
    const dataSource = { query: runQuery } as unknown as DataSource;
    return { service: new DashboardService(dataSource), statements };
  }

  it('raises danger for unrecorded sessions and absences, warning for capacity, info for decisions', async () => {
    const { service } = buildService({
      unrecorded: 3,
      absences: 2,
      overCapacity: [{ id: 'g1', name: 'الزهرات 1', capacity: 24, enrolled: 26 }],
      pending: 2,
      reports: 1,
    });

    const overview = await service.overview(executive);

    expect(overview.alerts.map((a) => [a.severity, a.destination])).toEqual([
      ['danger', 'groups'],
      ['danger', 'groups'],
      ['warning', 'groups'],
      ['info', 'memories'],
      ['info', 'messages'],
    ]);
    expect(overview.alerts[2].group_id).toBe('g1');
    expect(overview.alerts[2].text).toContain('26');
  });

  it('a quiet week has no alerts and honest null deltas', async () => {
    const { service } = buildService({});

    const overview = await service.overview(executive);

    expect(overview.alerts).toEqual([]);
    expect(overview.stats.children).toEqual({ value: 246, delta: null });
  });

  it('weekly attendance skips weeks with nothing expected and compares to last week', async () => {
    const { service } = buildService({
      weeks: [
        { expected: 0, present: 0 },
        { expected: 100, present: 82 },
        { expected: 100, present: 88 },
        { expected: 453, present: 412 },
      ],
    });

    const overview = await service.overview(executive);

    expect(overview.weekly_attendance).toEqual({
      present_count: 412,
      expected_count: 453,
      weekly_rates: [82, 88, 91],
      delta_points: 3,
    });
  });

  it('a branch-restricted executive gets every query narrowed to their branch', async () => {
    const { service, statements } = buildService({});

    await service.overview(restricted);

    const dataQueries = statements.filter((s) => !s.sql.includes('preferred_locale'));
    expect(dataQueries.length).toBeGreaterThan(0);
    for (const statement of dataQueries) {
      expect(statement.sql).toContain('g.branch_id');
      expect(statement.params).toContain('branch-1');
    }
  });
});
