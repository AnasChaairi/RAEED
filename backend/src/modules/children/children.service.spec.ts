import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { SessionsService } from '../sessions/sessions.service';
import { ChildrenService } from './children.service';

describe('ChildrenService list — the guardian\'s Home card', () => {
  const parent = new AuthenticatedUser('p1', new Set(['parent']), new Set(['c1', 'c2']), new Set(), null);

  function buildService(today: Array<Record<string, unknown>>): {
    service: ChildrenService;
    generated: jest.Mock;
  } {
    const generated = jest.fn().mockResolvedValue(undefined);
    const runQuery = async (sql: string): Promise<unknown> => {
      if (sql.includes('from child c')) {
        return [
          { id: 'c1', full_name: 'أحمد', photo_url: null, dob: '2018-05-02', group_id: 'g1', group_name: 'الأشبال', health_alert: false },
          { id: 'c2', full_name: 'مريم', photo_url: null, dob: '2016-01-01', group_id: null, group_name: null, health_alert: false },
        ];
      }
      if (sql.includes('select distinct on (s.group_id)')) {
        return [{ id: 's1', group_id: 'g1', starts_at: new Date('2026-09-29T15:00:00Z'), title: null }];
      }
      if (sql.includes('from child_group cg') && sql.includes('join session s')) return today;
      return [];
    };
    const dataSource = { query: runQuery } as unknown as DataSource;
    const sessions = { ensureGenerated: generated } as unknown as SessionsService;
    return { service: new ChildrenService(dataSource, sessions), generated };
  }

  it('carries the next session and a scheduled status, generating the sessions first', async () => {
    const { service, generated } = buildService([
      { child_id: 'c1', attendance: null, recorded_at: null, answer: null, confirmation_open: false },
    ]);

    const page = await service.list(parent, { limit: 20 });

    expect(generated).toHaveBeenCalledWith(expect.anything(), ['g1'], expect.any(Date), expect.any(Date));
    expect(page.items[0].next_session).toMatchObject({ id: 's1', starts_at: '2026-09-29T15:00:00.000Z' });
    expect(page.items[0].today_status).toEqual({ status: 'scheduled' });
    // No group: nothing scheduled, and no lookup to fail on.
    expect(page.items[1].next_session).toBeNull();
    expect(page.items[1].today_status).toEqual({ status: 'no_session' });
  });

  it('the mark wins over the answer, and an unexplained absence carries when it was raised', async () => {
    const at = new Date('2026-09-29T15:20:00Z');
    const { service } = buildService([
      { child_id: 'c1', attendance: 'absent', recorded_at: at, answer: 'yes', confirmation_open: true },
    ]);
    const page = await service.list(parent, { limit: 20 });
    expect(page.items[0].today_status).toEqual({ status: 'absent', alert_raised_at: at.toISOString() });
  });

  it('an open question shows as awaiting, an answer as what was answered', async () => {
    const { service } = buildService([
      { child_id: 'c1', attendance: null, recorded_at: null, answer: null, confirmation_open: true },
    ]);
    expect((await service.list(parent, { limit: 20 })).items[0].today_status).toEqual({
      status: 'awaiting_presence_answer',
    });
    const answered = buildService([
      { child_id: 'c1', attendance: null, recorded_at: null, answer: 'no', confirmation_open: true },
    ]);
    expect((await answered.service.list(parent, { limit: 20 })).items[0].today_status).toEqual({
      status: 'presence_declined',
    });
  });
});
