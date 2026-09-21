import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/network/api_envelope.dart';
import 'package:raeed/core/session/app_session.dart';
import 'package:raeed/core/session/session_controller.dart';
import 'package:raeed/core/session/token_store.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/children/domain/children_repository.dart';
import 'package:raeed/features/children/presentation/home_providers.dart';
import 'package:raeed/features/executive/domain/announcement_draft.dart';
import 'package:raeed/features/executive/domain/attendance_review_repository.dart';
import 'package:raeed/features/executive/domain/dashboard_overview.dart';
import 'package:raeed/features/executive/domain/dashboard_repository.dart';
import 'package:raeed/features/executive/domain/executive_announcements_repository.dart';
import 'package:raeed/features/executive/domain/groups_repository.dart';
import 'package:raeed/features/executive/domain/memories_review.dart';
import 'package:raeed/features/executive/domain/memories_review_repository.dart';
import 'package:raeed/features/executive/domain/messages_repository.dart';
import 'package:raeed/features/executive/domain/notifications_repository.dart';
import 'package:raeed/features/executive/presentation/executive_providers.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockGroupsRepository extends Mock implements GroupsRepository {}

class MockAnnouncementsRepository extends Mock
    implements ExecutiveAnnouncementsRepository {}

class MockMessagesRepository extends Mock implements MessagesRepository {}

class MockMemoriesReviewRepository extends Mock
    implements MemoriesReviewRepository {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockAttendanceReviewRepository extends Mock
    implements AttendanceReviewRepository {}

class MockChildrenRepository extends Mock implements ChildrenRepository {}

class _NoSessionBootstrapper implements SessionBootstrapper {
  const _NoSessionBootstrapper();

  @override
  Future<SessionUser?> loadCurrentUser() async => null;

  @override
  Future<bool> hasCompletedConsent(SessionUser user) async => false;
}

/// Every executive repository, mocked and answering "nothing" by default so
/// a screen under test never trips over a tab it does not exercise.
class ExecutiveMocks {
  ExecutiveMocks() {
    registerFallbackValue(
      const AnnouncementDraft(title: '', audience: AnnouncementAudience.all()),
    );
    when(() => dashboard.fetchOverview()).thenAnswer(
      (_) async => DashboardOverview(
        alerts: const [],
        stats: const [],
        weeklyAttendance: null,
        todaySessions: const [],
        fetchedAt: DateTime.utc(2026, 9, 20, 10, 42),
      ),
    );
    when(() => groups.fetchGroups()).thenAnswer((_) async => const []);
    when(() => announcements.fetchAnnouncements(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => const Paginated.empty());
    when(() => messages.fetchConversations()).thenAnswer((_) async => const []);
    when(() => memories.fetchQueue())
        .thenAnswer((_) async => const ReviewQueue(posts: []));
    when(() => memories.fetchAlbums()).thenAnswer((_) async => const []);
    when(() => notifications.fetchNotifications())
        .thenAnswer((_) async => const []);
    when(
      () => children.fetchChildren(
        cursor: any(named: 'cursor'),
        groupId: any(named: 'groupId'),
      ),
    ).thenAnswer((_) async => const Paginated.empty());
  }

  final dashboard = MockDashboardRepository();
  final groups = MockGroupsRepository();
  final announcements = MockAnnouncementsRepository();
  final messages = MockMessagesRepository();
  final memories = MockMemoriesReviewRepository();
  final notifications = MockNotificationsRepository();
  final attendanceReview = MockAttendanceReviewRepository();
  final children = MockChildrenRepository();

  /// A fresh container wired to these mocks.
  ProviderContainer container() => ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      sessionBootstrapperProvider.overrideWithValue(
        const _NoSessionBootstrapper(),
      ),
      dashboardRepositoryProvider.overrideWithValue(dashboard),
      groupsRepositoryProvider.overrideWithValue(groups),
      executiveAnnouncementsRepositoryProvider.overrideWithValue(announcements),
      messagesRepositoryProvider.overrideWithValue(messages),
      memoriesReviewRepositoryProvider.overrideWithValue(memories),
      notificationsRepositoryProvider.overrideWithValue(notifications),
      attendanceReviewRepositoryProvider.overrideWithValue(attendanceReview),
      childrenRepositoryProvider.overrideWithValue(children),
    ],
  );
}

/// A container signed in as an executive (or whichever [roles]).
Future<ProviderContainer> executiveContainer(
  ExecutiveMocks mocks, {
  Set<RaeedRole> roles = const {RaeedRole.executive},
  String? branchId,
}) async {
  final container = mocks.container();
  addTearDown(container.dispose);
  await container
      .read(sessionControllerProvider.notifier)
      .onSignedIn(
        SessionUser(
          id: 'user-1',
          roles: roles,
          displayName: 'أنس',
          branchId: branchId,
        ),
      );
  container.read(sessionControllerProvider.notifier).onConsentCompleted();
  return container;
}

const testLocales = [Locale('ar'), Locale('fr'), Locale('en')];

/// Finds the [Semantics] widget carrying exactly [label].
///
/// Used instead of `find.bySemanticsLabel`, which depends on where the
/// merged semantics node ends up in the render tree and therefore matches
/// zero or several elements for the same widget.
Finder findSemanticsLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

/// Pumps [child] inside the app's theme and localisations, on a tall phone
/// viewport so a whole screen is built rather than only its first fold.
///
/// With [routes], the screen runs under a GoRouter at `/` so navigation
/// calls resolve; the extra routes render the given widgets. The child is
/// placed under a [Scaffold], as the shell places every tab, so snackbars
/// have somewhere to show.
Future<void> pumpExecutive(
  WidgetTester tester,
  ProviderContainer container,
  Widget child, {
  double textScale = 1,
  Map<String, Widget> routes = const {},
  Locale locale = const Locale('ar'),
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final theme = RaeedTheme.light(locale);
  final body = Scaffold(body: child);
  // Scaling is applied inside the app, on top of the real view metrics: a
  // MediaQuery wrapped *around* MaterialApp would report a zero-size screen
  // to every widget that sizes itself from it.
  Widget scaled(BuildContext context, Widget? inner) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: inner ?? const SizedBox.shrink(),
  );
  final Widget app = routes.isEmpty
      ? MaterialApp(
          locale: locale,
          supportedLocales: testLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          theme: theme,
          builder: scaled,
          home: body,
        )
      : MaterialApp.router(
          locale: locale,
          supportedLocales: testLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          theme: theme,
          builder: scaled,
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, _) => body),
              for (final entry in routes.entries)
                GoRoute(path: entry.key, builder: (_, _) => entry.value),
            ],
          ),
        );

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: app),
  );
}

DashboardAlert alertOf(
  String id,
  AlertSeverity severity, {
  AlertDestination destination = AlertDestination.groups,
  int minutesAgo = 5,
}) => DashboardAlert(
  id: id,
  severity: severity,
  text: 'alert $id',
  destination: destination,
  raisedAt: DateTime.utc(
    2026,
    9,
    20,
    11,
  ).subtract(Duration(minutes: minutesAgo)),
);
