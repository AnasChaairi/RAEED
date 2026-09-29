import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { SessionsService } from '../sessions/sessions.service';
import { GroupsService } from './groups.service';

describe('GroupsService assign', () => {
  const executive = new AuthenticatedUser('exec-1', new Set(['executive']), new Set(), new Set(), null);
  const educator = new AuthenticatedUser('edu-1', new Set(['educator']), new Set(), new Set(['g1']), null);

  function buildService(): { service: GroupsService; statements: string[]; generated: jest.Mock } {
    const statements: string[] = [];
    const generated = jest.fn().mockResolvedValue(undefined);
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push(sql);
      if (sql.includes('from "group" g') && sql.includes('join category cat')) {
        return [
          {
            id: params[0],
            name: 'الأشبال أ',
            capacity: 20,
            branch_id: 'b1',
            category_id: 'cat',
            category_name: 'الأشبال',
            enrolled_count: 3,
            educators: [],
            weekly_schedule_json: [],
            place: null,
          },
        ];
      }
      if (sql.includes('select id from child where')) return [{ id: params[0] }];
      if (sql.includes('select preferred_locale')) return [{ preferred_locale: 'ar' }];
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    const sessions = { ensureGenerated: generated } as unknown as SessionsService;
    return { service: new GroupsService(dataSource, sessions), statements, generated };
  }

  it('moving a child closes the previous main row before inserting the new one', async () => {
    const { service, statements } = buildService();

    await service.assign(executive, 'g1', { child_ids: ['c1'] });

    const close = statements.findIndex((s) => s.includes('set valid_to = now()'));
    const insert = statements.findIndex((s) => s.includes('insert into child_group'));
    expect(close).toBeGreaterThan(-1);
    expect(close).toBeLessThan(insert);
    expect(statements.some((s) => /update child_group set group_id/.test(s))).toBe(false);
    expect(statements.some((s) => s.includes("'group.assign'"))).toBe(true);
  });

  it('creating a group names the missing prerequisite, not a field', async () => {
    const { service } = buildService();
    const draft = { name: 'الأشبال', category_id: 'cat', educator_ids: ['e1'] };
    // No branch at all: the first thing a fresh installation lacks.
    await expect(service.create(executive, draft)).rejects.toMatchObject({
      code: ApiErrorCode.GROUPS_NO_BRANCH,
    });
  });

  it('replacing the schedule is recorded and materialises the coming sessions', async () => {
    const { service, statements, generated } = buildService();
    const slots = [{ weekday: 6, starts_at: '10:00', ends_at: '12:00' }];

    const view = await service.updateSchedule(executive, 'g1', { weekly_schedule: slots });

    expect(statements.some((s) => s.includes('set weekly_schedule_json'))).toBe(true);
    expect(statements.some((s) => s.includes("'group.update'"))).toBe(true);
    expect(generated).toHaveBeenCalledWith(expect.anything(), ['g1'], expect.any(Date), expect.any(Date));
    expect(view.id).toBe('g1');
  });

  it('a slot that ends before it starts is refused', async () => {
    const { service, statements } = buildService();
    await expect(
      service.updateSchedule(executive, 'g1', { weekly_schedule: [{ weekday: 1, starts_at: '18:00', ends_at: '16:00' }] }),
    ).rejects.toMatchObject({ code: ApiErrorCode.VALIDATION_FAILED });
    expect(statements.some((s) => s.includes('set weekly_schedule_json'))).toBe(false);
  });

  it('an educator cannot change a schedule, even of their own group', async () => {
    const { service } = buildService();
    await expect(
      service.updateSchedule(educator, 'g1', { weekly_schedule: [] }),
    ).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
  });

  it('an educator cannot reassign children, even in their own group', async () => {
    const { service } = buildService();
    await expect(service.assign(educator, 'g1', { child_ids: ['c1'] })).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });
});
