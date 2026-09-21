import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { GroupsService } from './groups.service';

describe('GroupsService assign', () => {
  const executive = new AuthenticatedUser('exec-1', new Set(['executive']), new Set(), new Set(), null);
  const educator = new AuthenticatedUser('edu-1', new Set(['educator']), new Set(), new Set(['g1']), null);

  function buildService(): { service: GroupsService; statements: string[] } {
    const statements: string[] = [];
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
    return { service: new GroupsService(dataSource), statements };
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

  it('an educator cannot reassign children, even in their own group', async () => {
    const { service } = buildService();
    await expect(service.assign(educator, 'g1', { child_ids: ['c1'] })).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });
});
