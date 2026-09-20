import 'package:meta/meta.dart';

import '../../children/domain/announcement.dart';

export '../../children/domain/announcement.dart' show AnnouncementPriority;

/// Who an announcement goes to — the first key of `audience_json`.
enum AudienceMode {
  all('all'),
  parents('parents'),
  educators('educators'),

  /// The guardians of the children in the chosen categories.
  categories('categories');

  const AudienceMode(this.wireValue);

  final String wireValue;
}

/// The audience of an announcement.
@immutable
class AnnouncementAudience {
  const AnnouncementAudience({required this.mode, this.categoryIds = const {}});

  /// Everyone in the caller's branch scope.
  const AnnouncementAudience.all()
    : mode = AudienceMode.all,
      categoryIds = const {};

  /// Every guardian.
  const AnnouncementAudience.parents()
    : mode = AudienceMode.parents,
      categoryIds = const {};

  /// Every educator.
  const AnnouncementAudience.educators()
    : mode = AudienceMode.educators,
      categoryIds = const {};

  final AudienceMode mode;

  /// Only read when [mode] is [AudienceMode.categories].
  final Set<String> categoryIds;

  /// A category audience with nobody in it reaches nobody — the composer
  /// refuses to send it rather than quietly publishing into the void.
  bool get isEmptySelection =>
      mode == AudienceMode.categories && categoryIds.isEmpty;

  AnnouncementAudience withCategoryToggled(String categoryId) {
    final next = Set<String>.of(categoryIds);
    if (!next.remove(categoryId)) next.add(categoryId);
    return AnnouncementAudience(
      mode: AudienceMode.categories,
      categoryIds: next,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementAudience &&
          other.mode == mode &&
          other.categoryIds.length == categoryIds.length &&
          other.categoryIds.containsAll(categoryIds);

  @override
  int get hashCode => Object.hash(mode, Object.hashAllUnordered(categoryIds));
}

/// One فئة as the audience picker offers it, with how many people it reaches.
@immutable
class AudienceCategory {
  const AudienceCategory({
    required this.id,
    required this.name,
    required this.guardianCount,
  });

  final String id;
  final String name;

  /// Guardians of the children currently enrolled in the category.
  final int guardianCount;
}

/// How many people each audience reaches, as the server counts them.
///
/// The counts are the server's: a client that summed its own idea of
/// "families" would drift from the number the send actually reaches.
@immutable
class AudienceReach {
  const AudienceReach({
    required this.allCount,
    required this.parentsCount,
    required this.educatorsCount,
    required this.categories,
  });

  final int allCount;
  final int parentsCount;
  final int educatorsCount;
  final List<AudienceCategory> categories;
}

/// What the composer sends.
@immutable
class AnnouncementDraft {
  const AnnouncementDraft({
    required this.title,
    required this.audience,
    this.body,
    this.priority = AnnouncementPriority.normal,
    this.expireAt,
  });

  final String title;
  final String? body;
  final AnnouncementAudience audience;
  final AnnouncementPriority priority;

  /// When it stops showing, in UTC.
  final DateTime? expireAt;

  bool get isUrgent => priority == AnnouncementPriority.urgent;

  /// Whether there is enough here to send.
  bool get isSendable => title.trim().isNotEmpty && !audience.isEmptySelection;
}

/// Where an announcement stands in its life, resolved against the clock.
enum AnnouncementState { published, scheduled, draft, expired }

/// An announcement as the executive's list needs it.
///
/// Wider than the parent-facing `Announcement`: the executive sees the
/// audience, the expiry and the read rate — none of which a guardian should.
@immutable
class ExecutiveAnnouncement {
  const ExecutiveAnnouncement({
    required this.id,
    required this.title,
    required this.priority,
    required this.pinned,
    required this.publishAt,
    required this.audience,
    this.body,
    this.expireAt,
    this.isDraft = false,
    this.readRate,
  });

  final String id;
  final String title;
  final String? body;
  final AnnouncementPriority priority;
  final bool pinned;

  /// UTC.
  final DateTime publishAt;
  final DateTime? expireAt;
  final AnnouncementAudience audience;
  final bool isDraft;

  /// Fraction of the audience that opened it, 0..1, when the server counted.
  final double? readRate;

  bool get isUrgent => priority == AnnouncementPriority.urgent;

  AnnouncementState stateAt(DateTime now) {
    final utc = now.toUtc();
    if (isDraft) return AnnouncementState.draft;
    if (publishAt.isAfter(utc)) return AnnouncementState.scheduled;
    final expiry = expireAt;
    if (expiry != null && !expiry.isAfter(utc)) {
      return AnnouncementState.expired;
    }
    return AnnouncementState.published;
  }
}
