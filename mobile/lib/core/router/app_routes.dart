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

  /// Executive mobile dashboard — the executive shell with its five tabs.
  ///
  /// `?tab=` selects a tab (`dashboard`, `announcements`, `messages`,
  /// `memories`, `groups`), so an alert or a push can open the right one.
  static const String dashboard = '/dashboard';
  static const String dashboardName = 'dashboard';
  static const String dashboardTabParam = 'tab';

  /// The notification centre (EXEC-M-06).
  static const String notifications = '/notifications';
  static const String notificationsName = 'notifications';

  /// Settings and the role switcher (EXEC-M-07).
  static const String more = '/more';
  static const String moreName = 'more';

  /// The executive's children list (EXEC-M-08).
  static const String childrenList = '/children';
  static const String childrenListName = 'childrenList';

  /// Families and groups management (EXEC-M-10).
  static const String manage = '/manage';
  static const String manageName = 'manage';
  static const String manageNewGroup = '/manage/groups/new';
  static const String manageNewGroupName = 'manageNewGroup';
  static const String manageNewFamily = '/manage/families/new';
  static const String manageNewFamilyName = 'manageNewFamily';
  static const String manageTabParam = 'tab';

  /// Reports and export (EXEC-M-11).
  static const String reports = '/reports';
  static const String reportsName = 'reports';

  /// Structure — seasons, categories, branches (EXEC-M-12, admin).
  static const String structure = '/structure';
  static const String structureName = 'structure';

  /// The audit log (EXEC-M-13, admin).
  static const String logs = '/logs';
  static const String logsName = 'logs';

  /// The executive's after-the-fact attendance review for one session, with
  /// the correction flow and its visible history (EXEC-M-05).
  static const String attendanceReview =
      '/groups/:groupId/sessions/:sessionId/attendance/review';
  static const String attendanceReviewName = 'attendanceReview';

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

  /// Path to the executive shell opened on [tab].
  static String dashboardTabPath(String tab) => '/dashboard?tab=$tab';

  /// Path to the families & groups hub opened on [tab].
  static String manageTabPath(String tab) => '/manage?tab=$tab';

  /// Path to the attendance review for [sessionId] within [groupId].
  static String attendanceReviewPath(String groupId, String sessionId) =>
      '/groups/$groupId/sessions/$sessionId/attendance/review';
}
