import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/application/announcement_filter.dart';
import 'package:raeed/features/executive/domain/announcement_draft.dart';

void main() {
  final now = DateTime.utc(2026, 9, 20, 11);

  ExecutiveAnnouncement announcement(
    String id, {
    required DateTime publishAt,
    DateTime? expireAt,
    bool isDraft = false,
  }) => ExecutiveAnnouncement(
    id: id,
    title: id,
    priority: AnnouncementPriority.normal,
    pinned: false,
    publishAt: publishAt,
    expireAt: expireAt,
    isDraft: isDraft,
    audience: const AnnouncementAudience.all(),
  );

  final published = announcement(
    'published',
    publishAt: now.subtract(const Duration(days: 1)),
  );
  final scheduled = announcement(
    'scheduled',
    publishAt: now.add(const Duration(days: 7)),
  );
  final expired = announcement(
    'expired',
    publishAt: now.subtract(const Duration(days: 10)),
    expireAt: now.subtract(const Duration(days: 1)),
  );
  final draft = announcement('draft', publishAt: now, isDraft: true);

  test('each announcement lands in exactly one state', () {
    expect(published.stateAt(now), AnnouncementState.published);
    expect(scheduled.stateAt(now), AnnouncementState.scheduled);
    expect(expired.stateAt(now), AnnouncementState.expired);
    expect(draft.stateAt(now), AnnouncementState.draft);
  });

  test('an expiry exactly now is expired, not still live', () {
    final onTheDot = announcement(
      'edge',
      publishAt: now.subtract(const Duration(days: 1)),
      expireAt: now,
    );
    expect(onTheDot.stateAt(now), AnnouncementState.expired);
  });

  test('a draft is a draft even with a past publish date', () {
    final stale = announcement(
      'stale-draft',
      publishAt: now.subtract(const Duration(days: 3)),
      isDraft: true,
    );
    expect(stale.stateAt(now), AnnouncementState.draft);
  });

  test('filter and counts agree', () {
    final all = [published, scheduled, expired, draft, published];
    expect(
      announcementsInState(all, AnnouncementState.published, now).length,
      2,
    );
    expect(announcementStateCounts(all, now), {
      AnnouncementState.published: 2,
      AnnouncementState.scheduled: 1,
      AnnouncementState.draft: 1,
      AnnouncementState.expired: 1,
    });
  });
}
