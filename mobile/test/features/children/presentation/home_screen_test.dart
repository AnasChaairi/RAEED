import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/error/api_error_code.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/network/api_envelope.dart';
import 'package:raeed/core/session/app_session.dart';
import 'package:raeed/core/session/session_controller.dart';
import 'package:raeed/core/session/token_store.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/children/domain/announcement.dart';
import 'package:raeed/features/children/domain/announcements_repository.dart';
import 'package:raeed/features/children/domain/child.dart';
import 'package:raeed/features/children/domain/child_day_status.dart';
import 'package:raeed/features/children/domain/children_repository.dart';
import 'package:raeed/features/children/presentation/home_providers.dart';
import 'package:raeed/features/children/presentation/home_screen.dart';
import 'package:raeed/features/children/presentation/widgets/child_card.dart';
import 'package:raeed/features/children/presentation/widgets/health_alert_badge.dart';
import 'package:raeed/features/children/presentation/widgets/home_skeleton.dart';
import 'package:raeed/shared/widgets/offline_banner.dart';
import 'package:raeed/shared/widgets/raeed_error_view.dart';
import 'package:raeed/shared/widgets/skeleton.dart';

class _MockChildrenRepository extends Mock implements ChildrenRepository {}

class _MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

class _NoSessionBootstrapper implements SessionBootstrapper {
  const _NoSessionBootstrapper();

  @override
  Future<SessionUser?> loadCurrentUser() async => null;

  @override
  Future<bool> hasCompletedConsent(SessionUser user) async => false;
}

void main() {
  late _MockChildrenRepository children;
  late _MockAnnouncementsRepository announcements;

  Child childNamed(
    String id,
    String name, {
    bool healthAlert = false,
    ChildDayStatus status = const ChildDayStatus.noSession(),
  }) => Child(
    id: id,
    fullName: name,
    healthAlert: healthAlert,
    group: const ChildGroupRef(id: 'group-1', name: 'الأشبال'),
    dateOfBirth: DateTime(2018, 5, 2),
    todayStatus: status,
  );

  setUp(() {
    children = _MockChildrenRepository();
    announcements = _MockAnnouncementsRepository();
    when(() => announcements.fetchAnnouncements(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => const Paginated<Announcement>.empty());
  });

  /// Builds a container whose ability model reaches one child, so
  /// `resolveHomeScope` returns a parent scope rather than `none`.
  Future<ProviderContainer> containerAsParent() async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        sessionBootstrapperProvider.overrideWithValue(
          const _NoSessionBootstrapper(),
        ),
        childrenRepositoryProvider.overrideWithValue(children),
        announcementsRepositoryProvider.overrideWithValue(announcements),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(sessionControllerProvider.notifier)
        .onSignedIn(
          const SessionUser(
            id: 'user-1',
            roles: {RaeedRole.parent},
            displayName: 'Parent',
            reachableChildIds: {'child-1'},
          ),
        );
    container.read(sessionControllerProvider.notifier).onConsentCompleted();
    return container;
  }

  Future<void> pumpHome(
    WidgetTester tester,
    ProviderContainer container, {
    Locale locale = const Locale('ar'),
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
          localizationsDelegates: AppL10n.localizationsDelegates,
          theme: RaeedTheme.light(locale),
          home: const HomeScreen(),
        ),
      ),
    );
  }

  group('loading', () {
    testWidgets('shows skeleton cards, never a bare spinner', (tester) async {
      // The screen spec is explicit: "Skeleton child cards — never a bare
      // spinner."
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => const Paginated<Child>.empty(),
        ),
      );

      await pumpHome(tester, container);
      await tester.pump();

      expect(find.byType(HomeSkeleton), findsOneWidget);
      expect(find.byType(SkeletonBox), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();
    });
  });

  group('success', () {
    testWidgets('renders one card per child', (tester) async {
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) async => Paginated<Child>(
          items: [childNamed('child-1', 'آدم'), childNamed('child-2', 'مريم')],
          page: const PageInfo.end(),
        ),
      );

      await pumpHome(tester, container);
      await tester.pumpAndSettle();

      expect(find.byType(ChildCard), findsNWidgets(2));
      expect(find.text('آدم'), findsOneWidget);
      expect(find.text('مريم'), findsOneWidget);
    });

    testWidgets('a fresh absence alert overrides the status pill', (
      tester,
    ) async {
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) async => Paginated<Child>(
          items: [
            childNamed(
              'child-1',
              'آدم',
              status: ChildDayStatus(
                kind: DayStatusKind.absent,
                alertRaisedAt: DateTime.now(),
              ),
            ),
          ],
          page: const PageInfo.end(),
        ),
      );

      await pumpHome(tester, container);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(HomeScreen)));
      expect(
        find.text(l10n.absenceAlertTitle),
        findsOneWidget,
        reason: 'ATT-07 is the one safety-critical event; it must be scannable',
      );
    });
  });

  group('health alert', () {
    testWidgets('shows the badge but no health text in the list', (
      tester,
    ) async {
      // The safeguarding rule: a home screen is read in public, and a child's
      // health information is not the child's choice to share.
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) async => Paginated<Child>(
          items: [childNamed('child-1', 'آدم', healthAlert: true)],
          page: const PageInfo.end(),
        ),
      );

      await pumpHome(tester, container);
      await tester.pumpAndSettle();

      expect(find.byType(HealthAlertBadge), findsOneWidget);

      // No rendered Text anywhere on the card carries health content. The
      // badge contributes an icon and a semantics label, never a health string.
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join(' ');
      for (final leak in ['حساسية', 'allergy', 'Allergy', 'دواء']) {
        expect(
          texts,
          isNot(contains(leak)),
          reason: 'health text must never reach a list view',
        );
      }
    });

    testWidgets('omits the badge when there is no alert', (tester) async {
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) async => Paginated<Child>(
          items: [childNamed('child-1', 'آدم')],
          page: const PageInfo.end(),
        ),
      );

      await pumpHome(tester, container);
      await tester.pumpAndSettle();

      expect(find.byType(HealthAlertBadge), findsNothing);
    });
  });

  group('empty', () {
    testWidgets('points at the association, not at the user', (tester) async {
      // An empty home post-onboarding signals a data problem, and a parent
      // cannot enrol a child themselves (ACC-02).
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer((_) async => const Paginated<Child>.empty());

      await pumpHome(tester, container);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(HomeScreen)));
      expect(find.text(l10n.homeEmptyTitle), findsOneWidget);
      expect(find.text(l10n.homeEmptyBody), findsOneWidget);
      expect(find.byType(ChildCard), findsNothing);
    });
  });

  group('error and offline degrade', () {
    testWidgets('keeps cached cards and shows a banner when offline', (
      tester,
    ) async {
      // "Cached last-known cards + a subtle 'couldn't refresh' banner —
      // degrades gracefully offline."
      final container = await containerAsParent();

      var callCount = 0;
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return Paginated<Child>(
            items: [childNamed('child-1', 'آدم')],
            page: const PageInfo.end(),
          );
        }
        throw const NetworkException(message: 'offline');
      });

      await pumpHome(tester, container);
      await tester.pumpAndSettle();
      expect(find.byType(ChildCard), findsOneWidget);

      await container.read(homeControllerProvider.notifier).refresh();
      await tester.pumpAndSettle();

      expect(
        find.byType(ChildCard),
        findsOneWidget,
        reason: 'the cached card survives a failed refresh',
      );
      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.byType(RaeedErrorView), findsNothing);
    });

    testWidgets('shows a true error only when there is no cache', (
      tester,
    ) async {
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenThrow(const NetworkException(message: 'offline'));

      await pumpHome(tester, container);
      await tester.pumpAndSettle();

      expect(find.byType(RaeedErrorView), findsOneWidget);
      expect(find.byType(ChildCard), findsNothing);
    });

    testWidgets('a scope failure is not offered a retry', (tester) async {
      // scope.forbidden is terminal — retrying the identical request cannot
      // succeed, and a retry button that never works teaches distrust.
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenThrow(
        const ApiException(
          code: ApiErrorCode.scopeForbidden,
          message: 'nope',
          statusCode: 403,
        ),
      );

      await pumpHome(tester, container);
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(HomeScreen)));
      expect(find.text(l10n.errorForbiddenTitle), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, l10n.commonRetry),
        findsNothing,
      );
    });
  });

  group('RTL', () {
    testWidgets('lays out right-to-left in Arabic and mirrors in French', (
      tester,
    ) async {
      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) async => Paginated<Child>(
          items: [childNamed('child-1', 'آدم')],
          page: const PageInfo.end(),
        ),
      );

      await pumpHome(tester, container);
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.byType(ChildCard))),
        TextDirection.rtl,
      );

      await pumpHome(tester, container, locale: const Locale('fr'));
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.byType(ChildCard))),
        TextDirection.ltr,
      );
    });
  });

  group('text scaling', () {
    testWidgets('a child card survives 130% scaling without overflowing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final container = await containerAsParent();
      when(
        () => children.fetchChildren(
          cursor: any(named: 'cursor'),
          groupId: any(named: 'groupId'),
        ),
      ).thenAnswer(
        (_) async => Paginated<Child>(
          items: [
            childNamed(
              'child-1',
              'عبد الرحمن بن محمد الإدريسي',
              healthAlert: true,
              status: ChildDayStatus(
                kind: DayStatusKind.absent,
                alertRaisedAt: DateTime.now(),
              ),
            ),
          ],
          page: const PageInfo.end(),
        ),
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              localizationsDelegates: AppL10n.localizationsDelegates,
              theme: RaeedTheme.light(const Locale('ar')),
              home: const HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
