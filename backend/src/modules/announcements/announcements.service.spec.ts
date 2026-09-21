import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { CriticalJob } from '../../common/queue/queues';
import {
  AnnouncementsService,
  audienceCount,
  parseAudience,
} from './announcements.service';

describe('AnnouncementsService', () => {
  const executive = new AuthenticatedUser(
    'exec-1',
    new Set(['executive']),
    new Set(),
    new Set(),
    null,
  );
  const educator = new AuthenticatedUser(
    'educator-1',
    new Set(['educator']),
    new Set(['child-1']),
    new Set(['group-1']),
    null,
  );

  function buildService(): {
    service: AnnouncementsService;
    queueAdd: jest.Mock;
    inserted: unknown[][];
  } {
    const inserted: unknown[][] = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      if (sql.includes('insert into announcement')) {
        inserted.push(params);
        return [{ id: 'ann-1' }];
      }
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    const queueAdd = jest.fn().mockResolvedValue(undefined);
    const service = new AnnouncementsService(dataSource, { add: queueAdd } as never);
    return { service, queueAdd, inserted };
  }

  it('an urgent send goes on the critical lane, idempotent by announcement', async () => {
    const { service, queueAdd } = buildService();

    await service.publish(executive, {
      title: 'تغيير قاعة',
      audience: { type: 'parents' },
      priority: 'urgent',
    });

    expect(queueAdd).toHaveBeenCalledWith(
      CriticalJob.URGENT_ANNOUNCEMENT,
      { announcementId: 'ann-1' },
      { jobId: 'urgent-announcement-ann-1' },
    );
  });

  it('a normal announcement never touches the critical lane', async () => {
    const { service, queueAdd, inserted } = buildService();

    await service.publish(executive, {
      title: 'يوم مفتوح',
      audience: { type: 'categories', category_ids: ['cat-1'] },
    });

    expect(queueAdd).not.toHaveBeenCalled();
    expect(inserted[0][3]).toBe(
      JSON.stringify({ type: 'categories', category_ids: ['cat-1'], group_ids: [] }),
    );
  });

  it('an educator may address their own group only (ANN-03)', async () => {
    const { service, inserted } = buildService();

    await service.publish(educator, {
      title: 'x',
      audience: { type: 'groups', group_ids: ['group-1'] },
    });
    expect(inserted).toHaveLength(1);

    await expect(
      service.publish(educator, {
        title: 'x',
        audience: { type: 'groups', group_ids: ['group-1', 'group-2'] },
      }),
    ).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });

    await expect(
      service.publish(educator, { title: 'x', audience: { type: 'all' } }),
    ).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
    expect(inserted).toHaveLength(1);
  });

  it('parses the seed’s {"all": true} shorthand as an all audience', () => {
    expect(parseAudience({ all: true })).toEqual({
      type: 'all',
      category_ids: [],
      group_ids: [],
    });
    expect(parseAudience({ type: 'categories', category_ids: ['a', 3] })).toEqual({
      type: 'categories',
      category_ids: ['a'],
      group_ids: [],
    });
  });

  it('audience counts follow the reach', () => {
    const reach = {
      all: 264,
      parents: 246,
      educators: 18,
      categories: [
        { id: 'a', name: 'الأشبال', guardian_count: 58 },
        { id: 'b', name: 'الزهرات', guardian_count: 49 },
      ],
    };
    expect(audienceCount({ type: 'all', category_ids: [], group_ids: [] }, reach)).toBe(264);
    expect(
      audienceCount({ type: 'categories', category_ids: ['a', 'b'], group_ids: [] }, reach),
    ).toBe(107);
    expect(audienceCount({ type: 'groups', category_ids: [], group_ids: ['g'] }, reach)).toBeNull();
  });
});
