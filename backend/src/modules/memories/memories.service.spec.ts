import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError, ApiErrorCode } from '../../common/http/api-error';
import { MemoriesService } from './memories.service';

/**
 * `specs/11-testing-strategy.md` cases 3 and 4, from the moderation side:
 * approval re-checks every tagged child's *current* consent, so a post whose
 * guardian withdrew image rights after it was queued cannot be approved by a
 * stale screen.
 */
describe('MemoriesService', () => {
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

  function buildService(tags: Array<{ child_id: string; image_rights_level: string }>): {
    service: MemoriesService;
    updates: string[];
    audits: Array<{ action: unknown }>;
  } {
    const updates: string[] = [];
    const audits: Array<{ action: unknown }> = [];

    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      if (sql.includes('from post p')) {
        return [
          {
            id: params[0],
            created_at: new Date('2026-09-12T10:00:00Z'),
            moderation_status: 'hidden',
            hidden_reason: 'consent_blocked',
            media_kind: 'photo',
            author_id: 'educator-1',
            album_id: 'album-1',
            album_title: 'رحلة الغابة',
            moderation_mode: 'approve_before_publish',
            group_name: 'الفراشات 1',
            branch_id: 'branch-1',
            tags: tags.map((tag) => ({ ...tag, full_name: tag.child_id })),
          },
        ];
      }
      if (sql.includes('update post')) {
        updates.push(sql);
        return [];
      }
      if (sql.includes('insert into audit_log_entry')) {
        audits.push({ action: /'([a-z_.]+)'/.exec(sql)?.[1] });
        return [];
      }
      return [];
    };

    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;

    return { service: new MemoriesService(dataSource), updates, audits };
  }

  it('refuses to approve while a tagged child is not_allowed, naming them', async () => {
    const { service, updates } = buildService([
      { child_id: 'child-nour', image_rights_level: 'not_allowed' },
      { child_id: 'child-hicham', image_rights_level: 'allowed' },
    ]);

    const attempt = service.approve(executive, 'post-1');

    await expect(attempt).rejects.toBeInstanceOf(ApiError);
    await expect(attempt).rejects.toMatchObject({
      code: ApiErrorCode.MEMORIES_CONSENT_BLOCKED,
      details: { child_ids: ['child-nour'] },
    });
    expect(updates).toHaveLength(0);
  });

  it('approves once every tag is allowed or app_only, and records it', async () => {
    const { service, updates, audits } = buildService([
      { child_id: 'child-nour', image_rights_level: 'app_only' },
      { child_id: 'child-hicham', image_rights_level: 'allowed' },
    ]);

    await service.approve(executive, 'post-1');

    expect(updates.some((sql) => sql.includes("moderation_status = 'published'"))).toBe(true);
    expect(audits).toEqual([{ action: 'post.approve' }]);
  });

  it('hides without deleting, and records it', async () => {
    const { service, updates, audits } = buildService([]);

    await service.hide(executive, 'post-1');

    expect(updates.some((sql) => sql.includes("moderation_status = 'hidden'"))).toBe(true);
    expect(updates.some((sql) => /delete/i.test(sql))).toBe(false);
    expect(audits).toEqual([{ action: 'post.hide' }]);
  });

  it('moderation is an oversight power, not an educator’s', async () => {
    const { service, updates } = buildService([]);

    await expect(service.approve(educator, 'post-1')).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
    await expect(service.reviewQueue(educator)).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
    expect(updates).toHaveLength(0);
  });

  it('a branch-restricted executive cannot moderate another branch’s post', async () => {
    const restricted = new AuthenticatedUser(
      'exec-2',
      new Set(['executive']),
      new Set(),
      new Set(),
      'branch-2',
    );
    const { service } = buildService([]);

    await expect(service.approve(restricted, 'post-1')).rejects.toMatchObject({
      code: ApiErrorCode.SCOPE_FORBIDDEN,
    });
  });
});
