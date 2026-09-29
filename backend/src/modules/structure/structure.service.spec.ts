import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { StructureService } from './structure.service';

describe('StructureService', () => {
  const admin = new AuthenticatedUser('adm-1', new Set(['executive', 'admin']), new Set(), new Set(), null);

  function buildService(): {
    service: StructureService;
    statements: Array<{ sql: string; params: unknown[] }>;
  } {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('insert into category')) return [{ id: 'cat-new' }];
      if (sql.includes('insert into season')) return [{ id: 'sea-new' }];
      if (sql.includes('from category cat')) {
        return [{ id: 'cat-new', name: params[0] ?? 'الأشبال', min_age: null, max_age: null, gender: null, child_count: 0, group_count: 0 }];
      }
      if (sql.includes('from season se')) {
        return [{ id: 'sea-new', label: '2026-2027', start_date: '2026-09-01', end_date: '2027-06-30', status: 'active', group_count: 0, child_count: 0 }];
      }
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      manager,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    return { service: new StructureService(dataSource), statements };
  }

  it('a category is created by name only, with no guess at its age range or gender', async () => {
    const { service, statements } = buildService();

    const category = await service.createCategory(admin, { name: ' الأشبال ' });

    const insert = statements.find((s) => s.sql.includes('insert into category'))!;
    expect(insert.sql).toContain('(name_ar)');
    expect(insert.params).toEqual(['الأشبال']);
    expect(insert.sql).not.toMatch(/min_age|max_age|gender/);
    expect(statements.some((s) => s.sql.includes("'category.create'"))).toBe(true);
    expect(category).toMatchObject({ id: 'cat-new', min_age: null, gender: null });
  });

  it('a season opens active and is recorded', async () => {
    const { service, statements } = buildService();

    const season = await service.createSeason(admin, {
      label: '2026-2027',
      start_date: '2026-09-01',
      end_date: '2027-06-30',
    });

    const insert = statements.find((s) => s.sql.includes('insert into season'))!;
    expect(insert.sql).toContain("'active'");
    expect(insert.params).toEqual(['2026-2027', '2026-09-01', '2027-06-30']);
    expect(statements.some((s) => s.sql.includes("'season.create'"))).toBe(true);
    expect(season.status).toBe('active');
  });

  it('a season that ends before it starts is refused', async () => {
    const { service, statements } = buildService();
    await expect(
      service.createSeason(admin, { label: 'x', start_date: '2027-01-01', end_date: '2026-01-01' }),
    ).rejects.toMatchObject({ code: ApiErrorCode.VALIDATION_FAILED });
    expect(statements.some((s) => s.sql.includes('insert into season'))).toBe(false);
  });
});
