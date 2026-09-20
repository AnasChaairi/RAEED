import 'package:meta/meta.dart';

/// `image_rights_level` from `specs/03-domain-model/schema.sql`.
enum ImageRightsLevel {
  allowed('allowed'),

  /// May be shown inside the app only — never shared out.
  appOnly('app_only'),

  /// Must not appear in any post.
  notAllowed('not_allowed');

  const ImageRightsLevel(this.wireValue);

  final String wireValue;
}

/// `album.moderation_mode` — open product decision #3.
///
/// The app never defaults this: it renders whatever the album reports, and an
/// album that reports nothing renders "not yet set".
enum ModerationMode {
  publishThenModerate('publish_then_moderate'),
  approveBeforePublish('approve_before_publish');

  const ModerationMode(this.wireValue);

  final String wireValue;
}

/// A child tagged in a post, with the consent level that governs showing them.
@immutable
class TaggedChild {
  const TaggedChild({
    required this.id,
    required this.name,
    required this.imageRights,
  });

  final String id;
  final String name;
  final ImageRightsLevel imageRights;
}

/// A post waiting for review.
@immutable
class ReviewPost {
  const ReviewPost({
    required this.id,
    required this.albumTitle,
    required this.authorName,
    required this.postedAt,
    required this.mediaCount,
    required this.tags,
    this.groupName,
    this.thumbnailUrl,
    this.isBlocked = false,
  });

  final String id;
  final String albumTitle;
  final String? groupName;
  final String authorName;
  final DateTime postedAt;
  final int mediaCount;
  final String? thumbnailUrl;
  final List<TaggedChild> tags;

  /// Set when a tagged child's consent became `not_allowed` after publication
  /// and the server auto-hid the post (`WAL-06`, testing-strategy case 4).
  final bool isBlocked;

  /// The children whose consent currently forbids this post.
  List<TaggedChild> get notAllowedTags => tags
      .where((tag) => tag.imageRights == ImageRightsLevel.notAllowed)
      .toList(growable: false);
}

/// An album on the wall.
@immutable
class MemoriesAlbum {
  const MemoriesAlbum({
    required this.id,
    required this.title,
    required this.postCount,
    this.groupName,
    this.coverUrl,
    this.moderationMode,
  });

  final String id;
  final String title;
  final int postCount;
  final String? groupName;
  final String? coverUrl;

  /// Null until the association sets it.
  final ModerationMode? moderationMode;
}

/// The moderation queue and the mode it runs under.
@immutable
class ReviewQueue {
  const ReviewQueue({required this.posts, this.moderationMode});

  /// Oldest first — the post that has waited longest is reviewed first.
  final List<ReviewPost> posts;

  /// The branch-level mode, or null when it has not been decided.
  final ModerationMode? moderationMode;

  bool get isEmpty => posts.isEmpty;
  ReviewPost? get head => posts.isEmpty ? null : posts.first;

  ReviewQueue without(String postId) => ReviewQueue(
    posts: posts.where((post) => post.id != postId).toList(growable: false),
    moderationMode: moderationMode,
  );
}
