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

  /// Change the signed-in user's password. Nested under `/more`.
  static const String changePassword = '/more/password';
  static const String changePasswordName = 'changePassword';

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
  static const String homeTabParam = 'tab';

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
  /// An activity the educator adds by hand (EDU-M-03). Registered before
  /// the session page, so "new" is never read as a session id.
  static const String sessionNew = '/sessions/new';
  static const String sessionNewName = 'sessionNew';

  /// The educator's session pages (EDU-M-02, 04, 05).
  static const String session = '/sessions/:sessionId';
  static const String sessionName = 'session';
  static const String sessionEdit = 'edit';
  static const String sessionEditName = 'sessionEdit';
  static const String sessionSummary = 'summary';
  static const String sessionSummaryName = 'sessionSummary';
  static const String sessionPresence = 'presence';
  static const String sessionPresenceName = 'sessionPresence';
  static const String sessionHomeworkNew = 'homework/new';
  static const String sessionHomeworkNewName = 'sessionHomeworkNew';

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

  /// One household (EXEC-M-10b). The id is the family's guardian set as the
  /// API returns it — uuids joined by commas, which is a legal path segment.
  static const String manageFamily = '/manage/families/:familyId';
  static const String manageFamilyName = 'manageFamily';

  /// `?action=add-child` opens the page with the add-child sheet already up.
  static const String manageFamilyActionParam = 'action';
  static const String manageFamilyAddChildAction = 'add-child';

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

  static String homeTabPath(String tab) => '/home?tab=$tab';

  static String sessionPath(String sessionId) => '/sessions/$sessionId';

  static String sessionEditPath(String sessionId) =>
      '/sessions/$sessionId/edit';

  static String sessionSummaryPath(String sessionId) =>
      '/sessions/$sessionId/summary';

  static String sessionPresencePath(String sessionId) =>
      '/sessions/$sessionId/presence';

  static String sessionHomeworkNewPath(String sessionId) =>
      '/sessions/$sessionId/homework/new';

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
  static String manageFamilyPath(String familyId, {bool addChild = false}) =>
      '/manage/families/$familyId'
      '${addChild ? '?$manageFamilyActionParam=$manageFamilyAddChildAction' : ''}';

  /// Path to the attendance review for [sessionId] within [groupId].
  static String attendanceReviewPath(String groupId, String sessionId) =>
      '/groups/$groupId/sessions/$sessionId/attendance/review';
}
