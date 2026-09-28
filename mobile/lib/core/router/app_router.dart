import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../session/app_session.dart';
import '../session/session_controller.dart';
import 'app_routes.dart';
import 'route_guard.dart';

part 'app_router.g.dart';

/// Screens are supplied by the features that own them.
///
/// The router lives in `core` because guards and deep links are cross-cutting,
/// but it must not import a dozen feature packages to do its job — that would
/// make `core` depend on every feature and turn any feature change into a core
/// change. Features register their screens through this table instead.
typedef ScreenBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

/// The set of screens the router renders.
///
/// Every field is required: a missing screen is a wiring mistake that should
/// fail at composition, not produce a blank route at runtime in front of a
/// parent looking for their child's attendance.
@immutable
class AppScreens {
  const AppScreens({
    required this.splash,
    required this.login,
    required this.changePassword,
    required this.consent,
    required this.home,
    required this.child,
    required this.group,
    required this.attendance,
    required this.conversation,
    required this.memories,
    required this.memoriesCompose,
    required this.announcementCompose,
    required this.dashboard,
    required this.notifications,
    required this.more,
    required this.attendanceReview,
    required this.childrenList,
    required this.manage,
    required this.manageNewGroup,
    required this.manageNewFamily,
    required this.reports,
    required this.structure,
    required this.logs,
    required this.session,
    required this.sessionEdit,
    required this.sessionSummary,
    required this.sessionPresence,
    required this.sessionHomeworkNew,
    required this.notFound,
  });

  /// Shown while the session is still being restored from secure storage.
  final ScreenBuilder splash;

  /// Phone entry.
  final ScreenBuilder login;

  /// Change password (`/more/password`).
  final ScreenBuilder changePassword;

  /// Privacy + image-rights consent.
  final ScreenBuilder consent;

  /// Role-scoped home.
  final ScreenBuilder home;

  /// A child's profile, with its sub-tabs.
  final ScreenBuilder child;

  /// An educator's group view.
  final ScreenBuilder group;

  /// Attendance marking.
  final ScreenBuilder attendance;

  /// A conversation.
  final ScreenBuilder conversation;

  /// The Memories Wall.
  final ScreenBuilder memories;

  /// Memories post composer.
  final ScreenBuilder memoriesCompose;

  /// Announcement composer.
  final ScreenBuilder announcementCompose;

  /// Executive mobile dashboard — the shell with its tabs.
  final ScreenBuilder dashboard;

  /// The notification centre.
  final ScreenBuilder notifications;

  /// Settings and the role switcher.
  final ScreenBuilder more;

  /// The executive's attendance review for one session.
  final ScreenBuilder attendanceReview;

  /// The executive's children list.
  final ScreenBuilder childrenList;

  /// Families and groups management, its new-group form and family wizard.
  final ScreenBuilder manage;
  final ScreenBuilder manageNewGroup;
  final ScreenBuilder manageNewFamily;

  /// Reports and export.
  final ScreenBuilder reports;

  /// Structure (admin).
  final ScreenBuilder structure;

  /// The audit log (admin).
  final ScreenBuilder logs;

  /// The educator's session (EDU-M-04).
  final ScreenBuilder session;

  /// Session content editor.
  final ScreenBuilder sessionEdit;

  /// "What we did today".
  final ScreenBuilder sessionSummary;

  /// Presence overview (EDU-M-02).
  final ScreenBuilder sessionPresence;

  /// New homework (EDU-M-05).
  final ScreenBuilder sessionHomeworkNew;

  /// Fallback for an unknown or stale deep link.
  final ScreenBuilder notFound;
}

/// The registered screens. Overridden at app composition in `lib/app.dart`.
@Riverpod(keepAlive: true)
AppScreens appScreens(Ref ref) => throw UnimplementedError(
  'appScreensProvider must be overridden at app composition. '
  'See lib/app.dart.',
);

/// The app's [GoRouter].
///
/// `keepAlive` because a router rebuilt mid-navigation loses the navigation
/// stack. It watches session state through a [Listenable] rather than
/// `ref.watch`, so a session change re-runs the *redirects* without disposing
/// and rebuilding the router itself.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final screens = ref.watch(appScreensProvider);
  final refresh = _SessionRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      session: ref.read(sessionControllerProvider),
      location: state.matchedLocation,
    ),
    errorBuilder: screens.notFound,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: screens.login,
      ),
      GoRoute(
        path: AppRoutes.consent,
        name: AppRoutes.consentName,
        builder: screens.consent,
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: screens.home,
      ),
      GoRoute(
        path: AppRoutes.childrenList,
        name: AppRoutes.childrenListName,
        builder: screens.childrenList,
      ),
      GoRoute(
        path: AppRoutes.child,
        name: AppRoutes.childName,
        builder: screens.child,
        routes: [
          GoRoute(
            path: AppRoutes.childSchedule,
            name: AppRoutes.childScheduleName,
            builder: screens.child,
          ),
          GoRoute(
            path: AppRoutes.childAttendance,
            name: AppRoutes.childAttendanceName,
            builder: screens.child,
          ),
          GoRoute(
            path: AppRoutes.childHomework,
            name: AppRoutes.childHomeworkName,
            builder: screens.child,
          ),
          GoRoute(
            path: AppRoutes.childMaterials,
            name: AppRoutes.childMaterialsName,
            builder: screens.child,
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.group,
        name: AppRoutes.groupName,
        builder: screens.group,
        routes: [
          GoRoute(
            path: 'sessions/:sessionId/attendance',
            name: AppRoutes.attendanceName,
            builder: screens.attendance,
            routes: [
              GoRoute(
                path: 'review',
                name: AppRoutes.attendanceReviewName,
                builder: screens.attendanceReview,
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.conversation,
        name: AppRoutes.conversationName,
        builder: screens.conversation,
      ),
      GoRoute(
        path: AppRoutes.session,
        name: AppRoutes.sessionName,
        builder: screens.session,
        routes: [
          GoRoute(
            path: AppRoutes.sessionEdit,
            name: AppRoutes.sessionEditName,
            builder: screens.sessionEdit,
          ),
          GoRoute(
            path: AppRoutes.sessionSummary,
            name: AppRoutes.sessionSummaryName,
            builder: screens.sessionSummary,
          ),
          GoRoute(
            path: AppRoutes.sessionPresence,
            name: AppRoutes.sessionPresenceName,
            builder: screens.sessionPresence,
          ),
          GoRoute(
            path: AppRoutes.sessionHomeworkNew,
            name: AppRoutes.sessionHomeworkNewName,
            builder: screens.sessionHomeworkNew,
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.memories,
        name: AppRoutes.memoriesName,
        builder: screens.memories,
        routes: [
          GoRoute(
            path: 'compose',
            name: AppRoutes.memoriesComposeName,
            builder: screens.memoriesCompose,
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.announcementCompose,
        name: AppRoutes.announcementComposeName,
        builder: screens.announcementCompose,
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        builder: screens.dashboard,
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        builder: screens.notifications,
      ),
      GoRoute(
        path: AppRoutes.more,
        name: AppRoutes.moreName,
        builder: screens.more,
        routes: [
          GoRoute(
            // Nested under /more, so the path is relative here.
            path: 'password',
            name: AppRoutes.changePasswordName,
            builder: screens.changePassword,
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.manage,
        name: AppRoutes.manageName,
        builder: screens.manage,
        routes: [
          GoRoute(
            path: 'groups/new',
            name: AppRoutes.manageNewGroupName,
            builder: screens.manageNewGroup,
          ),
          GoRoute(
            path: 'families/new',
            name: AppRoutes.manageNewFamilyName,
            builder: screens.manageNewFamily,
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: AppRoutes.reportsName,
        builder: screens.reports,
      ),
      GoRoute(
        path: AppRoutes.structure,
        name: AppRoutes.structureName,
        builder: screens.structure,
      ),
      GoRoute(
        path: AppRoutes.logs,
        name: AppRoutes.logsName,
        builder: screens.logs,
      ),
    ],
  );
}

/// Notifies the router when session state changes, so redirects re-run.
///
/// Only fires on a change that can alter a redirect decision — the status or
/// the user's identity. Notifying on every session emission would re-evaluate
/// redirects on things the guards do not read, such as a role switch, and
/// interrupt navigation for no reason.
class _SessionRefreshListenable extends ChangeNotifier {
  _SessionRefreshListenable(Ref ref) {
    _subscription = ref.listen<AppSession>(sessionControllerProvider, (
      previous,
      next,
    ) {
      if (previous?.status != next.status ||
          previous?.user?.id != next.user?.id) {
        notifyListeners();
      }
    });
  }

  late final ProviderSubscription<AppSession> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
