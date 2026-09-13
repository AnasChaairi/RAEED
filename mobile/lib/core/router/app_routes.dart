/// Every route in the app, as named constants.
///
/// The paths mirror the routing table in `specs/06-mobile-app-spec.md`
/// one-for-one. They are constants rather than string literals at call sites
/// so a rename is a compile error instead of a dead deep link — and because a
/// push notification opens an exact conversation or session, a typo'd path is
/// a notification that lands nowhere.
library;

/// Route names and path builders.
abstract final class AppRoutes {
  // --- Unauthenticated -----------------------------------------------------

  /// Phone entry. No guard.
  static const String login = '/login';
  static const String loginName = 'login';

  /// OTP verification. Reachable only with a phone request pending.
  static const String otp = '/login/otp';
  static const String otpName = 'otp';

  // --- Consent gate --------------------------------------------------------

  /// Privacy policy + per-child image-rights consent (`ACC-06`).
  ///
  /// Authenticated users who have not consented can reach nothing else.
  static const String consent = '/consent';
  static const String consentName = 'consent';

  // --- Authenticated -------------------------------------------------------

  /// Role-scoped home.
  static const String home = '/home';
  static const String homeName = 'home';

  /// A child's profile.
  static const String child = '/children/:childId';
  static const String childName = 'child';

  /// Child sub-tabs.
  static const String childSchedule = 'schedule';
  static const String childScheduleName = 'childSchedule';
  static const String childAttendance = 'attendance';
  static const String childAttendanceName = 'childAttendance';
  static const String childHomework = 'homework';
  static const String childHomeworkName = 'childHomework';
  static const String childMaterials = 'materials';
  static const String childMaterialsName = 'childMaterials';

  /// An educator's group view.
  static const String group = '/groups/:groupId';
  static const String groupName = 'group';

  /// Attendance marking for one session of a group.
  static const String attendance =
      '/groups/:groupId/sessions/:sessionId/attendance';
  static const String attendanceName = 'attendance';

  /// A conversation.
  static const String conversation = '/messages/:conversationId';
  static const String conversationName = 'conversation';

  /// The Memories Wall.
  static const String memories = '/memories';
  static const String memoriesName = 'memories';

  /// Memories Wall post composer.
  static const String memoriesCompose = '/memories/compose';
  static const String memoriesComposeName = 'memoriesCompose';

  /// Announcement composer.
  static const String announcementCompose = '/announcements/compose';
  static const String announcementComposeName = 'announcementCompose';

  /// Executive mobile dashboard.
  static const String dashboard = '/dashboard';
  static const String dashboardName = 'dashboard';

  // --- Path builders -------------------------------------------------------
  // Used instead of string interpolation at call sites so a path and its
  // parameters cannot drift apart.

  /// Path to [childId]'s profile.
  static String childPath(String childId) => '/children/$childId';

  /// Path to a sub-tab of [childId]'s profile.
  static String childTabPath(String childId, String tab) =>
      '/children/$childId/$tab';

  /// Path to [groupId]'s view.
  static String groupPath(String groupId) => '/groups/$groupId';

  /// Path to the attendance sheet for [sessionId] within [groupId].
  static String attendancePath(String groupId, String sessionId) =>
      '/groups/$groupId/sessions/$sessionId/attendance';

  /// Path to [conversationId].
  static String conversationPath(String conversationId) =>
      '/messages/$conversationId';
}
