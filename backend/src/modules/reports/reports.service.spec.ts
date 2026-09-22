import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ReportsService } from './reports.service';

describe('ReportsService export', () => {
  const executive = new AuthenticatedUser('exec-1', new Set(['executive']), new Set(), new Set(), null);

  function buildService(): { service: ReportsService; statements: Array<{ sql: string; params: unknown[] }> } {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('from child c')) {
        return [
          {
            full_name: 'آدم "الطاهري"',
            dob: '2018-05-02',
            category_name: 'الأشبال',
            group_name: 'الأشبال أ',
            guardian_names: ['سعاد'],
            guardian_phones: ['+212600000001'],
            image_rights: 'app_only',
            allergies: ['فول سوداني'],
            medications: [],
          },
        ];
      }
      return [];
    };
    return {
      service: new ReportsService({ query: runQuery } as unknown as DataSource),
      statements,
    };
  }

  it('includes only the requested fields and flags health', async () => {
    const { service, statements } = buildService();

    const file = await service.export(executive, { fields: ['name', 'allergies'] });

    expect(file.contains_health).toBe(true);
    expect(file.row_count).toBe(1);
    expect(file.content).toContain('﻿"الاسم الكامل","الحساسية"');
    expect(file.content).toContain('"آدم ""الطاهري""","فول سوداني"');
    expect(file.content).not.toContain('+212');
    const audit = statements.find((s) => s.sql.includes("'report.export'"))!;
    expect(JSON.parse(audit.params[1] as string)).toMatchObject({
      fields: ['name', 'allergies'],
      contains_health: true,
      row_count: 1,
    });
  });

  it('a phone-free, health-free export is not flagged', async () => {
    const { service } = buildService();

    const file = await service.export(executive, { fields: ['name', 'group', 'consent'] });

    expect(file.contains_health).toBe(false);
    expect(file.content).toContain('"الأشبال · الأشبال أ","app_only"');
  });
});
