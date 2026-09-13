/// The consent model behind `ACC-06` and the `consent_record` table.
///
/// Two consents are captured before the app opens, and both are blocking
/// (`specs/13-roadmap-and-tickets.md`, RAEED-5):
///
/// * the privacy policy, at account level (`consent_record.child_id` is null);
/// * an image-rights level per child the user guards.
///
/// The defaulting rule is the important part and is expressed in the type
/// itself: [ImageRightsLevel.mostRestrictive] is what an unanswered child
/// carries. `specs/README.md` requires the most private option to be the
/// default for anything touching children's media, and the Memories Wall
/// refuses to publish a photo of a `not_allowed` child (`WAL-06`). A default
/// of "allowed" would mean a guardian who taps through this screen has
/// silently published their child; a default of "not allowed" means they have
/// silently protected them.
library;

import 'package:meta/meta.dart';

/// `image_rights_level` from `specs/03-domain-model/schema.sql`.
enum ImageRightsLevel {
  /// Photos may be published inside the app and on the academy's official
  /// channels.
  allowed('allowed'),

  /// Photos are visible inside the app only, never published outside it.
  appOnly('app_only'),

  /// No photo of the child is published anywhere. The default.
  notAllowed('not_allowed');

  const ImageRightsLevel(this.wireValue);

  /// The exact string the API sends and accepts.
  final String wireValue;

  /// The level an unanswered child carries, and the level the consent screen
  /// pre-selects.
  static const ImageRightsLevel mostRestrictive = ImageRightsLevel.notAllowed;

  /// Resolves a wire value, falling back to [mostRestrictive].
  ///
  /// The fallback direction is deliberate: a level this build does not
  /// recognise must never widen what may be published. An unknown value is
  /// treated as the strictest one until the app is updated.
  static ImageRightsLevel fromWire(String? value) {
    if (value == null) return mostRestrictive;
    for (final level in ImageRightsLevel.values) {
      if (level.wireValue == value) return level;
    }
    return mostRestrictive;
  }

  /// Whether this level permits publishing outside the app.
  bool get allowsExternalPublication => this == ImageRightsLevel.allowed;
}

/// One child the signed-in user guards, as the consent screen needs them.
///
/// Deliberately thin: a name and an id. The consent screen has no business
/// holding a health record or a group, and not loading them means they cannot
/// leak into a screenshot of this screen.
@immutable
class ConsentChild {
  const ConsentChild({
    required this.id,
    required this.fullName,
    this.currentLevel,
  });

  /// `child.id`.
  final String id;

  /// The child's name, for the per-child heading.
  final String fullName;

  /// The level already recorded by this guardian, if any.
  ///
  /// Null means no `consent_record` exists yet for this guardian and child —
  /// which is the case this whole screen exists to resolve.
  final ImageRightsLevel? currentLevel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentChild &&
          other.id == id &&
          other.fullName == fullName &&
          other.currentLevel == currentLevel;

  @override
  int get hashCode => Object.hash(id, fullName, currentLevel);
}

/// What the server says is still outstanding for this user.
///
/// Resolved server-side, never inferred on the client: consent is append-only
/// and two guardians can disagree, and the most-restrictive-wins resolution
/// lives in the backend's `children` service
/// (`specs/03-domain-model/entities.md`).
@immutable
class ConsentRequirement {
  const ConsentRequirement({
    required this.privacyPolicyAccepted,
    required this.children,
  });

  /// Nobody guards a child and nothing is outstanding — used as the initial
  /// state before the first load.
  const ConsentRequirement.none()
    : privacyPolicyAccepted = true,
      children = const [];

  /// Whether this user has already accepted the privacy policy.
  final bool privacyPolicyAccepted;

  /// Every child this user guards, with any level already recorded.
  ///
  /// Empty for a user who guards nobody — an educator or executive who is not
  /// also a parent. They still accept the privacy policy.
  final List<ConsentChild> children;

  /// Children with no recorded level yet.
  Iterable<ConsentChild> get childrenAwaitingLevel =>
      children.where((child) => child.currentLevel == null);

  /// Whether everything `ACC-06` blocks on has been recorded.
  bool get isSatisfied =>
      privacyPolicyAccepted && childrenAwaitingLevel.isEmpty;
}

/// What the consent screen sends back.
@immutable
class ConsentSubmission {
  const ConsentSubmission({
    required this.privacyPolicyAccepted,
    required this.imageRights,
  });

  /// Whether the user ticked the privacy-policy box.
  final bool privacyPolicyAccepted;

  /// The chosen level per `child.id`.
  ///
  /// Every child the screen displayed appears here — including the ones left
  /// at the default, because "the guardian looked at this and left it at
  /// not-allowed" and "the guardian was never asked" must be distinguishable
  /// rows in `consent_record`.
  final Map<String, ImageRightsLevel> imageRights;

  /// Whether this submission is complete enough to send.
  bool get isComplete => privacyPolicyAccepted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentSubmission &&
          other.privacyPolicyAccepted == privacyPolicyAccepted &&
          _mapEquals(other.imageRights, imageRights);

  @override
  int get hashCode => Object.hash(
    privacyPolicyAccepted,
    Object.hashAllUnordered(
      imageRights.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
  }
  return true;
}
