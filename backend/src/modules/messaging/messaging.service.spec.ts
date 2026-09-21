import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiErrorCode } from '../../common/http/api-error';
import { MessagingService } from './messaging.service';

/**
 * `MSG-08` from the server side: oversight reading is permitted, logged, and
 * hiding closes the report without deleting anything.
 */
describe('MessagingService', () => {
  const executive = new AuthenticatedUser(
    'exec-1',
    new Set(['executive']),
    new Set(),
    new Set(),
    null,
  );
  const guardian = new AuthenticatedUser(
    'parent-1',
    new Set(['parent']),
    new Set(['child-1']),
    new Set(),
    null,
  );
  const otherGuardian = new AuthenticatedUser(
    'parent-2',
    new Set(['parent']),
    new Set(['child-9']),
    new Set(),
    null,
  );

  const conversation = {
    id: 'conv-1',
    type: 'child',
    ref_child_id: 'child-1',
    ref_group_id: null,
    group_id: 'group-1',
    branch_id: 'branch-1',
    title: 'آدم',
  };

  function buildService(): {
    service: MessagingService;
    audits: string[];
    statements: string[];
  } {
    const audits: string[] = [];
    const statements: string[] = [];

    const runQuery = async (sql: string): Promise<unknown> => {
      statements.push(sql);
      if (sql.includes('from conv where id')) return [conversation];
      if (sql.includes('select preferred_locale')) return [{ preferred_locale: 'ar' }];
      if (sql.includes('insert into audit_log_entry')) {
        audits.push(/'([a-z_.]+)'/.exec(sql)?.[1] ?? '');
        return [];
      }
      if (sql.includes('select id, conversation_id from message')) {
        return [{ id: 'msg-1', conversation_id: 'conv-1' }];
      }
      if (sql.includes('select id, message_id from message_report')) {
        return [{ id: 'rep-1', message_id: 'msg-1' }];
      }
      if (sql.includes('from message m')) {
        return [
          {
            id: 'msg-1',
            sender_id: 'educator-1',
            sender_role: 'educator',
            kind: 'text',
            body: 'هل يمكن مشاركة رقم هاتف الأم؟',
            hidden_at: new Date('2026-09-20T11:32:00Z'),
            hidden_by: 'exec-1',
            created_at: new Date('2026-09-18T18:40:00Z'),
            report_id: 'rep-1',
            reported_by: 'parent-1',
            reason: 'طلب معلومات شخصية',
          },
        ];
      }
      return [];
    };

    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;

    return { service: new MessagingService(dataSource), audits, statements };
  }

  it('an executive reading a thread they are not in is audit-logged first', async () => {
    const { service, audits, statements } = buildService();

    await service.messages(executive, 'conv-1');

    expect(audits).toEqual(['conversation.oversight_read']);
    const auditIndex = statements.findIndex((s) => s.includes('oversight_read'));
    const readIndex = statements.findIndex((s) => s.includes('from message m'));
    expect(auditIndex).toBeLessThan(readIndex);
  });

  it('a member reading their own thread is not logged as oversight', async () => {
    const { service, audits } = buildService();

    await service.messages(guardian, 'conv-1');

    expect(audits).toEqual([]);
  });

  it('a guardian of another child cannot read the thread', async () => {
    const { service } = buildService();

    await expect(service.messages(otherGuardian, 'conv-1')).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });

  it('a hidden message keeps its text for oversight and loses it for members', async () => {
    const { service } = buildService();

    const [forExecutive] = await service.messages(executive, 'conv-1');
    const [forGuardian] = await service.messages(guardian, 'conv-1');

    expect(forExecutive.body).toContain('رقم هاتف');
    expect(forExecutive.hidden?.by_id).toBe('exec-1');
    expect(forExecutive.report?.id).toBe('rep-1');
    expect(forGuardian.body).toBeNull();
    expect(forGuardian.hidden).not.toBeNull();
    // The report is the executive's business, not the members'.
    expect(forGuardian.report).toBeNull();
  });

  it('hiding sets the tombstone, resolves the report and never deletes', async () => {
    const { service, audits, statements } = buildService();

    await service.hide(executive, 'msg-1');

    expect(statements.some((s) => s.includes('set hidden_at = now()'))).toBe(true);
    expect(statements.some((s) => s.includes("resolution = 'hidden'"))).toBe(true);
    expect(statements.some((s) => /^\s*delete/i.test(s))).toBe(false);
    expect(audits).toEqual(['message.hide']);
  });

  it('dismissing closes the report and leaves the message untouched', async () => {
    const { service, audits, statements } = buildService();

    await service.dismissReport(executive, 'rep-1');

    expect(statements.some((s) => s.includes("resolution = 'dismissed'"))).toBe(true);
    expect(statements.some((s) => s.includes('set hidden_at'))).toBe(false);
    expect(audits).toEqual(['message_report.dismiss']);
  });

  it('a member cannot hide a message', async () => {
    const { service } = buildService();

    await expect(service.hide(guardian, 'msg-1')).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });
});
