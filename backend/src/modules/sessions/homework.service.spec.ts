import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { HomeworkService } from './homework.service';

describe('HomeworkService', () => {
  const educator = new AuthenticatedUser('edu-1', new Set(['educator']), new Set(), new Set(['g1']), null);

  function buildService() {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('from child_group cg') && sql.includes('order by c.full_name')) {
        return [{ id: 'c1' }, { id: 'c2' }, { id: 'c3' }];
      }
      if (sql.includes('insert into homework (')) return [{ id: 'hw-1' }];
      if (sql.includes('select preferred_locale')) return [{ preferred_locale: 'ar' }];
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      manager,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    const sessions = {
      loadReadable: jest.fn().mockResolvedValue({ id: 's1', group_id: 'g1', group_name: 'الأشبال أ', branch_id: 'b1' }),
      homeworkOf: jest.fn().mockResolvedValue([{ id: 'hw-1', session_id: 's1' }]),
    };
    const notify = {
      notify: jest.fn().mockResolvedValue([]),
      guardiansOfChildren: jest.fn().mockResolvedValue(['p1']),
    };
    return { service: new HomeworkService(dataSource, sessions as never, notify as never), statements, notify };
  }

  it('whole-group homework gets a status row per enrolled child', async () => {
    const { service, statements, notify } = buildService();
    await service.create(educator, 's1', { instructions: 'مراجعة الآيات', due_at: '2026-10-02T18:00:00Z' });

    const insert = statements.find((s) => s.sql.includes('insert into homework ('))!;
    expect(insert.params[6]).toBeNull();
    const statuses = statements.find((s) => s.sql.includes('insert into homework_status'))!;
    expect(statuses.params[1]).toEqual(['c1', 'c2', 'c3']);
    expect(notify.guardiansOfChildren).toHaveBeenCalledWith(expect.anything(), ['c1', 'c2', 'c3']);
  });

  it('targeted homework reaches only the named children', async () => {
    const { service, statements } = buildService();
    await service.create(educator, 's1', {
      instructions: 'قراءة القصة',
      due_at: '2026-10-02T18:00:00Z',
      target_child_ids: ['c2'],
    });
    const statuses = statements.find((s) => s.sql.includes('insert into homework_status'))!;
    expect(statuses.params[1]).toEqual(['c2']);
  });

  it('a target outside the group is refused, not dropped', async () => {
    const { service } = buildService();
    await expect(
      service.create(educator, 's1', { instructions: 'x', due_at: '2026-10-02T18:00:00Z', target_child_ids: ['c2', 'zz'] }),
    ).rejects.toMatchObject({ code: ApiErrorCode.VALIDATION_FAILED });
    await expect(
      service.create(educator, 's1', { instructions: 'x', due_at: '2026-10-02T18:00:00Z', target_child_ids: [] }),
    ).rejects.toMatchObject({ code: ApiErrorCode.VALIDATION_FAILED });
  });
});
