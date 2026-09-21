import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { ChildrenService } from './children.service';
import { ExecutiveChildrenService } from './executive-children.service';

/**
 * `AUD-03` from the server side: the health text and a guardian's phone are
 * each read through a route that logs first, and never appear in the
 * profile payload.
 */
describe('ExecutiveChildrenService', () => {
  const executive = new AuthenticatedUser('exec-1', new Set(['executive']), new Set(), new Set(), null);
  const guardian = new AuthenticatedUser('p1', new Set(['parent']), new Set(['c1']), new Set(), null);

  function buildService(): { service: ExecutiveChildrenService; statements: string[] } {
    const statements: string[] = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      // The action travels as a parameter; recorded with the SQL so the
      // assertions below can name it.
      statements.push(`${sql} -- ${params.map(String).join(' ')}`);
      if (sql.includes('from child c') && sql.includes('c.health_json_version')) {
        return [
          {
            id: 'c1',
            full_name: 'عمر',
            photo_url: null,
            dob: '2017-07-09',
            school_level: null,
            health_json: { conditions: ['ربو خفيف'] },
            health_json_version: 1,
            special_needs_notes: null,
            group_id: 'g1',
            group_name: 'الأشبال أ',
            branch_id: 'b1',
          },
        ];
      }
      if (sql.includes('insert into audit_log_entry')) return [{ at: new Date('2026-09-21T11:52:00Z') }];
      if (sql.includes('select preferred_locale')) return [{ preferred_locale: 'ar' }];
      if (sql.includes('select u.phone')) return [{ phone: '+212600000001' }];
      if (sql.includes('from consent_record cr') && sql.includes('distinct on (guardian_id) level')) return [];
      return [];
    };
    const dataSource = { query: runQuery } as unknown as DataSource;
    const service = new ExecutiveChildrenService(dataSource, new ChildrenService(dataSource));
    return { service, statements };
  }

  it('the profile carries no health text, only the flag', async () => {
    const { service, statements } = buildService();

    const view = await service.detail(executive, 'c1');

    expect(view.health_alert).toBe(true);
    expect(view.health_json).toEqual({});
    expect(statements.some((s) => s.includes('audit_log_entry'))).toBe(false);
  });

  it('reading health writes the audit entry before reading the text', async () => {
    const { service, statements } = buildService();

    const view = await service.health(executive, 'c1');

    expect(view.health_json).toEqual({ conditions: ['ربو خفيف'] });
    expect(view.viewed_at).toBe('2026-09-21T11:52:00.000Z');
    const audit = statements.findIndex((s) => s.includes('child.health_view'));
    const read = statements.findIndex((s) => s.includes('c.health_json_version'));
    expect(audit).toBeGreaterThan(-1);
    // Scope is checked (the child is loaded) first, then the entry is
    // written, then the text is returned — never the text without the entry.
    expect(read).toBeLessThan(audit);
  });

  it('revealing a phone is logged and scoped to the child’s guardians', async () => {
    const { service, statements } = buildService();

    const view = await service.guardianPhone(executive, 'c1', 'p1');

    expect(view.phone).toBe('+212600000001');
    expect(statements.some((s) => s.includes('guardian.phone_reveal'))).toBe(true);
  });

  it('a guardian does not use the oversight routes', async () => {
    const { service } = buildService();
    await expect(service.health(guardian, 'c1')).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });
});
