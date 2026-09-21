import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { FamiliesService } from './families.service';

describe('FamiliesService', () => {
  const executive = new AuthenticatedUser('exec-1', new Set(['executive']), new Set(), new Set(), null);
  const educator = new AuthenticatedUser('edu-1', new Set(['educator']), new Set(), new Set(['g1']), null);

  function buildService(links: Array<Record<string, unknown>>): {
    service: FamiliesService;
    statements: Array<{ sql: string; params: unknown[] }>;
  } {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('join parent_child pc on pc.child_id = c.id')) return links;
      if (sql.includes('select id from app_user where phone')) return [];
      if (sql.includes('insert into app_user')) return [{ id: `user-${statements.length}` }];
      if (sql.includes('insert into child (')) return [{ id: `child-${statements.length}` }];
      if (sql.includes('select id, branch_id from "group"')) return [{ id: params[0], branch_id: 'b1' }];
      if (sql.includes('select phone from app_user')) return [{ phone: '+212600000009' }];
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      manager,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    return { service: new FamiliesService(dataSource), statements };
  }

  const link = (child: string, name: string, guardian: string, gname: string, account: string, group: string | null) => ({
    child_id: child,
    full_name: name,
    group_id: group,
    group_name: group ? `group ${group}` : null,
    guardian_id: guardian,
    display_name: gname,
    account,
  });

  it('groups children by their exact set of guardians', async () => {
    const { service } = buildService([
      link('c1', 'يوسف الإدريسي', 'p1', 'سعاد', 'active', 'g1'),
      link('c1', 'يوسف الإدريسي', 'p2', 'كريم', 'pending', 'g1'),
      link('c2', 'مريم الإدريسي', 'p1', 'سعاد', 'active', null),
      link('c2', 'مريم الإدريسي', 'p2', 'كريم', 'pending', null),
      link('c3', 'إلياس التازي', 'p3', 'نعيمة', 'pending', null),
    ]);

    const families = await service.list(executive);

    expect(families).toHaveLength(2);
    const idrissi = families.find((f) => f.label === 'الإدريسي')!;
    expect(idrissi.children.map((c) => c.full_name)).toEqual(['يوسف الإدريسي', 'مريم الإدريسي']);
    expect(idrissi.status).toBe('partial');
    expect(idrissi.guardians.map((g) => g.display_name)).toEqual(['سعاد', 'كريم']);
    const tazi = families.find((f) => f.label === 'التازي')!;
    expect(tazi.status).toBe('pending');
    expect(tazi.children[0].group).toBeNull();
  });

  it('creating a family links guardians, children and a thread in one act', async () => {
    const { service, statements } = buildService([]);

    const result = await service.create(executive, {
      guardians: [
        { display_name: 'خالد بوعزة', phone: '+212655214018', relationship: 'father' },
        { display_name: 'حنان بوعزة', phone: '+212666901277', relationship: 'mother' },
      ],
      children: [
        { full_name: 'أميرة بوعزة', dob: '2018-05-03', group_id: 'g1' },
        { full_name: 'ياسين بوعزة', dob: '2021-01-19' },
      ],
    });

    expect(result.guardian_ids).toHaveLength(2);
    expect(result.child_ids).toHaveLength(2);
    expect(result.invitations).toBe(2);
    const sql = statements.map((s) => s.sql);
    expect(sql.filter((s) => s.includes('insert into parent_child'))).toHaveLength(4);
    expect(sql.filter((s) => s.includes('insert into child_group'))).toHaveLength(1);
    expect(sql.filter((s) => s.includes("insert into conversation (type, ref_child_id)"))).toHaveLength(2);
    expect(sql.filter((s) => s.includes("'family.create'"))).toHaveLength(1);
    // No health information is ever written here — the guardian enters it.
    expect(sql.some((s) => s.includes('health_json'))).toBe(false);
  });

  it('is an oversight power', async () => {
    const { service } = buildService([]);
    await expect(service.list(educator)).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
  });
});
