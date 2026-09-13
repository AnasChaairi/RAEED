import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/children/domain/child.dart';
import 'package:raeed/features/children/domain/child_detail.dart';
import 'package:raeed/features/children/domain/children_repository.dart';
import 'package:raeed/features/children/presentation/child_profile_screen.dart';
import 'package:raeed/features/children/presentation/home_providers.dart';

class _MockChildrenRepository extends Mock implements ChildrenRepository {}

/// `RAEED-12`: the profile is the tap-through target for the health badge, and
/// the only place in the app where health text is rendered at all.
void main() {
  late _MockChildrenRepository children;

  ChildDetail detail({HealthInfo health = const HealthInfo.empty()}) =>
      ChildDetail(
        summary: Child(
          id: 'child-1',
          fullName: 'آدم الإدريسي',
          healthAlert: health.isNotEmpty,
          group: const ChildGroupRef(id: 'group-1', name: 'الأشبال'),
          dateOfBirth: DateTime(2018, 5, 2),
        ),
        imageRightsLevel: ImageRightsLevel.notAllowed,
        health: health,
      );

  setUp(() {
    children = _MockChildrenRepository();
  });

  Future<void> pumpProfile(
    WidgetTester tester,
    ChildDetail child, {
    double textScale = 1,
  }) async {
    when(() => children.fetchChild('child-1')).thenAnswer((_) async => child);

    final container = ProviderContainer(
      overrides: [childrenRepositoryProvider.overrideWithValue(children)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: AppL10n.localizationsDelegates,
            theme: RaeedTheme.light(const Locale('ar')),
            home: const ChildProfileScreen(childId: 'child-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppL10n l10nOf(WidgetTester tester) =>
      AppL10n.of(tester.element(find.byType(ChildProfileScreen)));

  testWidgets('leads with who the child is', (tester) async {
    await pumpProfile(tester, detail());

    final l10n = l10nOf(tester);
    expect(find.text('آدم الإدريسي'), findsOneWidget);
    expect(
      find.text('${l10n.childProfileGroupLabel}: الأشبال'),
      findsOneWidget,
    );
  });

  testWidgets('labels health entries by category', (tester) async {
    // "peanuts" under allergies and "peanuts" under dietary notes mean
    // different things to an educator holding an epi-pen.
    await pumpProfile(
      tester,
      detail(
        health: const HealthInfo(
          allergies: ['الفول السوداني'],
          medications: ['بخاخ الربو'],
          dietaryNotes: 'بدون لاكتوز',
        ),
      ),
    );

    final l10n = l10nOf(tester);
    expect(find.text(l10n.childHealthAllergies), findsOneWidget);
    expect(find.text('الفول السوداني'), findsOneWidget);
    expect(find.text(l10n.childHealthMedications), findsOneWidget);
    expect(find.text(l10n.childHealthDiet), findsOneWidget);
    // Nothing is invented for the categories the record does not carry.
    expect(find.text(l10n.childHealthConditions), findsNothing);
  });

  testWidgets('keeps keys this build does not know about', (tester) async {
    // Losing an allergy because the backend renamed a key is not a failure
    // mode this app may have.
    await pumpProfile(
      tester,
      detail(
        health: const HealthInfo(otherNotes: {'mobility': 'يستعمل نظارات'}),
      ),
    );

    expect(find.text(l10nOf(tester).childHealthOther), findsOneWidget);
    expect(find.text('يستعمل نظارات'), findsOneWidget);
  });

  testWidgets('shows no health card when there is nothing to show', (
    tester,
  ) async {
    await pumpProfile(tester, detail());

    expect(find.text(l10nOf(tester).childProfileHealthTitle), findsNothing);
  });

  testWidgets('holds up at 130% text scaling', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpProfile(
      tester,
      detail(
        health: const HealthInfo(
          allergies: ['الفول السوداني'],
          conditions: ['الربو'],
        ),
      ),
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
  });
}
