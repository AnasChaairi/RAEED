/// Wire ↔ domain mapping for the auth and consent endpoints.
///
/// Written by hand rather than generated. The payloads here are four small
/// objects, and every one of them needs a decision a generator cannot make:
/// an unknown role is dropped rather than failing the login, an unknown
/// image-rights level falls back to the *most restrictive* value rather than
/// to null, and no decoder ever produces a field this app has no business
/// holding. A generated `fromJson` would either crash on a value a newer
/// backend sends or silently accept it — both worse than the explicit
/// mapping below.
library;

import '../../../core/authorization/raeed_role.dart';
import '../../../core/network/api_envelope.dart';
import '../../../core/session/app_session.dart';
import '../../../core/session/token_store.dart';
import '../domain/consent.dart';

/// Decodes `GET /auth/me`.
///
/// Note what is not read: `phone`. `MSG-06` forbids rendering `app_user.phone`
/// to a non-executive role, and [SessionUser] holds no field for it — the
/// surest way to honour the rule on the client is for the number never to
/// enter session state at all.
SessionUser sessionUserFromJson(Map<String, Object?> json) {
  final roles = <RaeedRole>{};
  final rawRoles = json['roles'];
  if (rawRoles is List) {
    for (final raw in rawRoles) {
      if (raw is! String) continue;
      // A role this build predates is ignored rather than fatal: a backend
      // that adds a fifth role must not lock every older app out of signing
      // in. The user simply sees no surface for it until they update.
      final role = RaeedRole.fromWire(raw);
      if (role != null) roles.add(role);
    }
  }

  return SessionUser(
    id: requireField<String>(json, 'id'),
    roles: roles,
    displayName: requireField<String>(json, 'display_name'),
    preferredLocale: json['preferred_locale'] as String? ?? 'ar',
    reachableChildIds: _stringSet(json['reachable_child_ids']),
    reachableGroupIds: _stringSet(json['reachable_group_ids']),
    branchId: json['branch_id'] as String?,
  );
}

/// Decodes the token pair returned by `/auth/otp/verify` and `/auth/refresh`.
AuthTokens authTokensFromJson(Map<String, Object?> json) => AuthTokens(
  accessToken: requireField<String>(json, 'access_token'),
  refreshToken: requireField<String>(json, 'refresh_token'),
);

/// Decodes `GET /consent`.
ConsentRequirement consentRequirementFromJson(Map<String, Object?> json) {
  final rawChildren = json['children'];
  final children = <ConsentChild>[];
  if (rawChildren is List) {
    for (final raw in rawChildren) {
      final child = asJsonObject(raw, context: 'children[]');
      final level = child['image_rights_level'];
      children.add(
        ConsentChild(
          id: requireField<String>(child, 'id'),
          fullName: requireField<String>(child, 'full_name'),
          // Absent means "no consent_record yet" and must stay null — it is
          // the difference between a guardian who has not been asked and one
          // who answered "not allowed".
          currentLevel: level == null
              ? null
              : ImageRightsLevel.fromWire(level as String?),
        ),
      );
    }
  }

  return ConsentRequirement(
    privacyPolicyAccepted: json['privacy_policy_accepted'] as bool? ?? false,
    children: List.unmodifiable(children),
  );
}

/// Encodes the body of `POST /consent`.
Map<String, Object?> consentSubmissionToJson(ConsentSubmission submission) => {
  'privacy_policy_accepted': submission.privacyPolicyAccepted,
  'image_rights': [
    for (final entry in submission.imageRights.entries)
      {'child_id': entry.key, 'level': entry.value.wireValue},
  ],
};

Set<String> _stringSet(Object? value) {
  if (value is! List) return const {};
  return {
    for (final element in value)
      if (element is String) element,
  };
}
