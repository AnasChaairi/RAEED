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

    const notify = {
      notify: jest.fn().mockResolvedValue([]),
      guardiansOfChildren: jest.fn().mockResolvedValue([]),
      oversightUsers: jest.fn().mockResolvedValue([]),
    };
    return { service: new MemoriesService(dataSource, notify as never), updates, audits };
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

describe('MemoriesService.create', () => {
  const educator = new AuthenticatedUser('edu-1', new Set(['educator']), new Set(), new Set(['g1']), null);

  function buildService(children: Array<Record<string, unknown>>, mode = 'approve_before_publish') {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('from album a') && sql.includes('a.moderation_mode, a.title')) {
        return [{ id: 'al1', group_id: 'g1', branch_id: 'b1', moderation_mode: mode, title: 'ختم سورة الملك' }];
      }
      if (sql.includes('where c.id = any($1::uuid[]) and c.deleted_at is null')) return children;
      if (sql.includes('insert into post (')) return [{ id: 'post-9' }];
      if (sql.includes('select preferred_locale')) return [{ preferred_locale: 'ar' }];
      if (sql.includes('where p.author_id = $1')) {
        return [{ id: 'post-9', album_id: 'al1', album_title: 'x', group_name: null, caption: null, storage_key: 'k', media_json: [{}], tag_count: 1, created_at: new Date(), moderation_status: mode === 'approve_before_publish' ? 'pending' : 'published' }];
      }
      return [];
    };
    const manager = { query: runQuery } as unknown as EntityManager;
    const dataSource = {
      query: runQuery,
      transaction: async (work: (tx: EntityManager) => Promise<unknown>) => work(manager),
    } as unknown as DataSource;
    const notify = {
      notify: jest.fn().mockResolvedValue([]),
      guardiansOfChildren: jest.fn().mockResolvedValue(['p1']),
      oversightUsers: jest.fn().mockResolvedValue(['exec-1']),
    };
    return { service: new MemoriesService(dataSource, notify as never), statements, notify };
  }
  const media = [{ storage_key: 'edu/a.jpg', media_kind: 'photo' as const }];

  it('refuses a post tagging a not_allowed child, naming them', async () => {
    const { service, statements } = buildService([
      { id: 'c1', full_name: 'عمر', group_id: 'g1', level: 'not_allowed' },
      { id: 'c2', full_name: 'آدم', group_id: 'g1', level: 'app_only' },
    ]);
    await expect(
      service.create(educator, { album_id: 'al1', media, tagged_child_ids: ['c1', 'c2'] }),
    ).rejects.toMatchObject({ code: ApiErrorCode.MEMORIES_CONSENT_BLOCKED, details: { child_ids: ['c1'] } });
    expect(statements.some((s) => s.sql.includes('insert into post'))).toBe(false);
  });

  it('a child outside the educator’s groups is a scope refusal, not a consent one', async () => {
    const { service } = buildService([{ id: 'c1', full_name: 'x', group_id: 'g7', level: 'allowed' }]);
    await expect(
      service.create(educator, { album_id: 'al1', media, tagged_child_ids: ['c1'] }),
    ).rejects.toMatchObject({ code: ApiErrorCode.SCOPE_FORBIDDEN });
  });

  it('waits for approval or publishes, as the album’s moderation mode says', async () => {
    const child = { id: 'c2', full_name: 'آدم', group_id: 'g1', level: 'app_only' };
    const pending = buildService([child]);
    const post = await pending.service.create(educator, { album_id: 'al1', media, tagged_child_ids: ['c2'] });
    expect(post.state).toBe('pending');
    expect(pending.statements.find((s) => s.sql.includes('insert into post ('))!.params[4]).toBe('pending');
    expect(pending.notify.oversightUsers).toHaveBeenCalled();

    const live = buildService([child], 'publish_then_moderate');
    await live.service.create(educator, { album_id: 'al1', media, tagged_child_ids: ['c2'] });
    expect(live.statements.find((s) => s.sql.includes('insert into post ('))!.params[4]).toBe('published');
    expect(live.notify.guardiansOfChildren).toHaveBeenCalledWith(expect.anything(), ['c2']);
  });
});
