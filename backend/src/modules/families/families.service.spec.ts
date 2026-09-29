import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { IdentityService } from '../identity/identity.service';
import { PasswordService } from '../identity/password.service';
import { FamiliesService } from './families.service';

describe('FamiliesService', () => {
  const executive = new AuthenticatedUser('exec-1', new Set(['executive']), new Set(), new Set(), null);
  const educator = new AuthenticatedUser('edu-1', new Set(['educator']), new Set(), new Set(['g1']), null);

  /**
   * A fake data source that records every statement and keeps a mutable link
   * table, so a mutation's re-read of the household sees what it changed —
   * the way the real derivation would.
   */
  function buildService(links: Array<Record<string, unknown>>): {
    service: FamiliesService;
    statements: Array<{ sql: string; params: unknown[] }>;
    identity: { setPassword: jest.Mock; revokeAllDevices: jest.Mock };
  } {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    // Phones that already have an account, for the upsert path.
    const accounts: Record<string, string> = { '+212600000002': 'p2', '+212600000009': 'p9' };
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('join parent_child pc on pc.child_id = c.id')) return [...links];
      if (sql.includes('select id from app_user where phone = $1 and id <> $2')) {
        const owner = accounts[params[0] as string];
        return owner && owner !== params[1] ? [{ id: owner }] : [];
      }
      if (sql.includes('select id from app_user where phone')) {
        const owner = accounts[params[0] as string];
        return owner ? [{ id: owner }] : [];
      }
      if (sql.includes('select phone from app_user')) return [{ phone: '+212600000009' }];
      if (sql.includes('insert into app_user')) return [{ id: `user-${statements.length}` }];
      if (sql.includes('insert into child (')) return [{ id: `child-${statements.length}` }];
      if (sql.includes('select id, branch_id from "group"')) return [{ id: params[0], branch_id: 'b1' }];
      if (sql.includes('having count(*) filter')) {
        const [childIds, guardianId] = params as [string[], string];
        return childIds
          .filter((childId) => !links.some((l) => l.child_id === childId && l.guardian_id !== guardianId))
          .map((child_id) => ({ child_id }));
      }
      if (sql.includes('update parent_child set unlinked_at')) {
        const [childIds, guardianId] = params as [string[], string];
        for (let i = links.length - 1; i >= 0; i -= 1) {
          if (links[i].guardian_id === guardianId && childIds.includes(links[i].child_id as string)) {
            links.splice(i, 1);
          }
        }
        return [];
      }
      if (sql.includes('from unnest($2::uuid[])')) {
        const [guardianId, childIds, relationship] = params as [string, string[], string];
        for (const childId of childIds) {
          const sibling = links.find((l) => l.child_id === childId)!;
          links.push({
            ...sibling,
            guardian_id: guardianId,
            display_name: 'new',
            relationship,
            phone_hint: '•• 00',
            account: 'pending',
          });
        }
        return [];
      }
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      manager,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    const identity = {
      setPassword: jest.fn().mockResolvedValue(undefined),
      revokeAllDevices: jest.fn().mockResolvedValue(2),
    };
    const passwords = new PasswordService();
    return {
      service: new FamiliesService(dataSource, identity as unknown as IdentityService, passwords),
      statements,
      identity,
    };
  }

  const link = (child: string, name: string, guardian: string, gname: string, account: string, group: string | null) => ({
    child_id: child,
    full_name: name,
    dob: '2018-05-02',
    group_id: group,
    group_name: group ? `group ${group}` : null,
    guardian_id: guardian,
    display_name: gname,
    relationship: guardian === 'p1' ? 'mother' : 'father',
    phone_hint: `•• ${guardian.slice(-1)}${guardian.slice(-1)}`,
    account,
  });

  /** The Idrissi household: two guardians, two children; a third child elsewhere. */
  const household = () => [
    link('c1', 'يوسف الإدريسي', 'p1', 'سعاد', 'active', 'g1'),
    link('c1', 'يوسف الإدريسي', 'p2', 'كريم', 'pending', 'g1'),
    link('c2', 'مريم الإدريسي', 'p1', 'سعاد', 'active', null),
    link('c2', 'مريم الإدريسي', 'p2', 'كريم', 'pending', null),
    link('c3', 'إلياس التازي', 'p3', 'نعيمة', 'pending', null),
  ];

  it('groups children by their exact set of guardians', async () => {
    const { service } = buildService(household());

    const families = await service.list(executive);

    expect(families).toHaveLength(2);
    const idrissi = families.find((f) => f.label === 'الإدريسي')!;
    expect(idrissi.children.map((c) => c.full_name)).toEqual(['يوسف الإدريسي', 'مريم الإدريسي']);
    expect(idrissi.status).toBe('partial');
    expect(idrissi.guardians.map((g) => g.display_name)).toEqual(['سعاد', 'كريم']);
    const tazi = families.find((f) => f.label === 'التازي')!;
    expect(tazi.status).toBe('pending');
    expect(tazi.children[0].group).toBeNull();
    // What the family page edits: the relationship, the masked hint, the birth date.
    expect(idrissi.guardians[0]).toMatchObject({ relationship: 'mother', phone_hint: '•• 11' });
    expect(idrissi.children[0].dob).toBe('2018-05-02');
  });

  it('creating a family links guardians, children and a thread in one act', async () => {
    const { service, statements, identity } = buildService([]);

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
    // Each new account is handed a first password, returned once and never
    // stored in clear (ACC-02).
    expect(identity.setPassword).toHaveBeenCalledTimes(2);
    expect(result.guardians.map((g) => g.password)).toEqual([
      expect.stringMatching(/^[a-z0-9]{6}$/),
      expect.stringMatching(/^[a-z0-9]{6}$/),
    ]);
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
    await expect(service.updateChild(educator, ['p1', 'p2'], 'c1', { full_name: 'x' })).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });

  describe('editing a household', () => {
    const ids = ['p1', 'p2'];

    it('reads one household by its guardian set, and nothing outside it', async () => {
      const { service } = buildService(household());
      expect((await service.get(executive, ids)).label).toBe('الإدريسي');
      await expect(service.get(executive, ['p1'])).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
    });

    it('a phone change signs the guardian out everywhere and is logged without the number', async () => {
      const { service, statements, identity } = buildService(household());

      await service.updateGuardian(executive, ids, 'p1', { phone: '+212611223344' });

      const sql = statements.map((s) => s.sql);
      expect(sql.some((s) => s.includes('update app_user set phone'))).toBe(true);
      expect(identity.revokeAllDevices).toHaveBeenCalledWith(expect.anything(), 'p1');
      // The password is not touched: they sign in again with what they know.
      expect(identity.setPassword).not.toHaveBeenCalled();
      const audit = statements.find((s) => s.sql.includes("'guardian.update'"))!;
      const meta = JSON.parse(audit.params[3] as string);
      expect(meta).toMatchObject({ changed: ['phone'], child_ids: ['c1', 'c2'], devices_revoked: 2 });
      expect(JSON.stringify(audit.params)).not.toContain('611223344');
    });

    it('refuses a phone another account signs in with', async () => {
      const { service, statements } = buildService(household());
      await expect(
        service.updateGuardian(executive, ids, 'p1', { phone: '+212600000009' }),
      ).rejects.toMatchObject({ code: ApiErrorCode.GUARDIANS_PHONE_TAKEN });
      expect(statements.some((s) => s.sql.includes('update app_user set phone'))).toBe(false);
    });

    it('a relationship change applies to every child of the household', async () => {
      const { service, statements } = buildService(household());
      await service.updateGuardian(executive, ids, 'p2', { relationship: 'guardian', display_name: 'كريم ب.' });
      const update = statements.find((s) => s.sql.includes('update parent_child set relationship_type'))!;
      expect(update.params).toEqual(['p2', ['c1', 'c2'], 'guardian']);
      const audit = statements.find((s) => s.sql.includes("'guardian.update'"))!;
      expect(JSON.parse(audit.params[3] as string).changed).toEqual(['display_name', 'relationship']);
    });

    it('linking a guardian reaches every child and returns the household it now is', async () => {
      const { service, statements, identity } = buildService(household());

      const result = await service.addGuardian(executive, ids, {
        display_name: 'الجدة',
        phone: '+212655000000',
        relationship: 'grandmother',
      });

      expect(identity.setPassword).toHaveBeenCalledTimes(1);
      expect(result.credential.password).toMatch(/^[a-z0-9]{6}$/);
      const insert = statements.find((s) => s.sql.includes('from unnest($2::uuid[])'))!;
      expect(insert.params[1]).toEqual(['c1', 'c2']);
      expect(result.family.guardians).toHaveLength(3);
      expect(result.family.children.map((c) => c.id)).toEqual(['c1', 'c2']);
      expect(statements.some((s) => s.sql.includes("'guardian.link'"))).toBe(true);
    });

    it('linking a phone that already has an account hands over no password', async () => {
      const { service, identity } = buildService(household());
      const result = await service.addGuardian(executive, ids, {
        display_name: 'x',
        phone: '+212600000009',
        relationship: 'father',
      });
      expect(result.credential).toMatchObject({ id: 'p9', password: null });
      expect(identity.setPassword).not.toHaveBeenCalled();
    });

    it('refuses to link a guardian the household already has', async () => {
      const { service } = buildService(household());
      await expect(
        service.addGuardian(executive, ids, { display_name: 'كريم', phone: '+212600000002', relationship: 'father' }),
      ).rejects.toMatchObject({ code: ApiErrorCode.GUARDIANS_ALREADY_LINKED });
    });

    it('unlinking one of two guardians closes the links and shrinks the household', async () => {
      const { service, statements } = buildService(household());

      const family = await service.unlinkGuardian(executive, ids, 'p2');

      expect(family.id).toBe('p1');
      expect(family.children).toHaveLength(2);
      const close = statements.find((s) => s.sql.includes('update parent_child set unlinked_at'))!;
      expect(close.params).toEqual([['c1', 'c2'], 'p2']);
      expect(statements.some((s) => s.sql.includes("'guardian.unlink'"))).toBe(true);
      // Closed, never deleted.
      expect(statements.some((s) => s.sql.includes('delete from parent_child'))).toBe(false);
    });

    it("refuses to unlink a child's last guardian", async () => {
      const { service, statements } = buildService(household());
      await expect(service.unlinkGuardian(executive, ['p3'], 'p3')).rejects.toMatchObject({
        code: ApiErrorCode.CHILDREN_LAST_GUARDIAN,
        details: { child_ids: ['c3'] },
      });
      expect(statements.some((s) => s.sql.includes('update parent_child set unlinked_at'))).toBe(false);
    });

    it('adding a child links every current guardian and opens a thread', async () => {
      const { service, statements } = buildService(household());

      const result = await service.addChild(executive, ids, { full_name: 'آدم الإدريسي', dob: '2020-02-02', group_id: 'g1' });

      expect(result.child_id).toMatch(/^child-/);
      const parentLinks = statements.filter((s) => s.sql.includes('insert into parent_child'));
      expect(parentLinks.map((s) => s.params[0])).toEqual(['p1', 'p2']);
      expect(parentLinks.map((s) => s.params[2])).toEqual(['mother', 'father']);
      expect(statements.filter((s) => s.sql.includes('insert into child_group'))).toHaveLength(1);
      expect(statements.filter((s) => s.sql.includes("insert into conversation"))).toHaveLength(1);
      expect(statements.some((s) => s.sql.includes("'child.create'"))).toBe(true);
      expect(statements.some((s) => s.sql.includes('health_json'))).toBe(false);
    });

    it('correcting a child is recorded, and a child outside the household is refused', async () => {
      const { service, statements } = buildService(household());
      await service.updateChild(executive, ids, 'c1', { dob: '2018-06-01' });
      const update = statements.find((s) => s.sql.includes('update child'))!;
      expect(update.params).toEqual(['c1', null, '2018-06-01']);
      const audit = statements.find((s) => s.sql.includes("'child.update'"))!;
      expect(JSON.parse(audit.params[3] as string)).toEqual({ changed: ['dob'] });

      await expect(service.updateChild(executive, ids, 'c3', { full_name: 'x' })).rejects.toMatchObject({
        code: ApiErrorCode.SCOPE_FORBIDDEN,
      });
    });
  });
});
