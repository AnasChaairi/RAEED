import 'package:meta/meta.dart';

import 'child.dart';

/// What may be published of a child's image (`ACC-06`).
///
/// The default is the most restrictive level, here as everywhere: a missing or
/// unrecognised value must never widen what can be published.
enum ImageRightsLevel {
  /// Publishable inside the app and on the association's own channels.
  allowed('allowed'),

  /// Visible inside the app only.
  appOnly('app_only'),

  /// Never publishable anywhere. The default.
  notAllowed('not_allowed');

  const ImageRightsLevel(this.wireValue);

  /// The value as it travels in `specs/04-api/openapi.yaml`.
  final String wireValue;
}

/// A child's health information — `child.health_json`.
///
/// The keys are the working draft from `specs/03-domain-model/entities.md`;
/// the exact set is **open decision #2**, pending the CNDP filing. So every
/// field is optional, and [otherNotes] keeps any key this build does not know
/// about visible rather than silently dropping it — losing an allergy because
/// the backend renamed a key is not a failure mode this app may have.
@immutable
class HealthInfo {
  const HealthInfo({
    this.allergies = const [],
    this.conditions = const [],
    this.medications = const [],
    this.dietaryNotes,
    this.otherNotes = const {},
  });

  /// No recorded health information.
  const HealthInfo.empty()
    : allergies = const [],
      conditions = const [],
      medications = const [],
      dietaryNotes = null,
      otherNotes = const {};

  /// `health_json.allergies`.
  final List<String> allergies;

  /// `health_json.conditions`.
  final List<String> conditions;

  /// `health_json.medications`.
  final List<String> medications;

  /// `health_json.dietary_notes`.
  final String? dietaryNotes;

  /// Any other key present in `health_json`, kept as text.
  final Map<String, String> otherNotes;

  /// Whether there is anything at all to show.
  bool get isEmpty =>
      allergies.isEmpty &&
      conditions.isEmpty &&
      medications.isEmpty &&
      (dietaryNotes == null || dietaryNotes!.trim().isEmpty) &&
      otherNotes.isEmpty;

  /// Whether there is something to show.
  bool get isNotEmpty => !isEmpty;
}

/// A child's full profile — the `ChildDetail` schema in
/// `specs/04-api/openapi.yaml`.
///
/// Composes [Child] rather than extending it, so a `ChildDetail` can never be
/// passed where a list model is expected and quietly carry health information
/// into a list view.
@immutable
class ChildDetail {
  const ChildDetail({
    required this.summary,
    required this.imageRightsLevel,
    this.schoolLevel,
    this.health = const HealthInfo.empty(),
  });

  /// Everything the list view also knows.
  final Child summary;

  /// What may be published of this child's image.
  final ImageRightsLevel imageRightsLevel;

  /// `child.school_level`.
  final String? schoolLevel;

  /// `child.health_json`, parsed.
  ///
  /// Empty when the caller's scope does not include health information — the
  /// server omits the field rather than sending an empty object, and either
  /// way the UI must ask the ability model before rendering it.
  final HealthInfo health;

  /// `child.id`.
  String get id => summary.id;

  /// The child's full name.
  String get fullName => summary.fullName;
}
