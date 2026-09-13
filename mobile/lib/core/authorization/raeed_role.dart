/// The four roles in RAEED, matching the `role_name` enum in
/// `specs/03-domain-model/schema.sql`.
///
/// A user may hold more than one — an educator is often also a parent — so
/// these are always handled as a set, never as a single "the user's role".
enum RaeedRole {
  /// ولي الأمر — guardian of an enrolled child. Sees their own children only.
  parent('parent'),

  /// مؤطِّر — runs sessions for a group. Sees their own groups only.
  educator('educator'),

  /// مشرف — oversight across the association, optionally restricted to one
  /// branch. Every action is audit-logged.
  executive('executive'),

  /// Full oversight plus structure and user management, and audit-log access.
  admin('admin');

  const RaeedRole(this.wireValue);

  /// The exact string the API sends.
  final String wireValue;

  /// Resolves a wire value, returning null for a role this build predates.
  static RaeedRole? fromWire(String value) {
    for (final role in RaeedRole.values) {
      if (role.wireValue == value) return role;
    }
    return null;
  }

  /// Whether this role has association-wide oversight.
  bool get hasOversight =>
      this == RaeedRole.executive || this == RaeedRole.admin;
}
