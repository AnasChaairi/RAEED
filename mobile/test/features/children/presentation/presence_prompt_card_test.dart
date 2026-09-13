import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/attendance/domain/attendance_repository.dart';
import 'package:raeed/features/attendance/domain/presence_answer.dart';
import 'package:raeed/features/attendance/presentation/attendance_providers.dart';
import 'package:raeed/features/attendance/presentation/presence_confirmation_sheet.dart';
import 'package:raeed/features/children/presentation/widgets/presence_prompt_card.dart';

class _MockPresenceRepository extends Mock implements PresenceRepository {}

/// The Home half of `RAEED-16`: "an unanswered confirmation also surfaces on
/// the Home card itself so it survives a missed push"
/// (`specs/06-mobile-app-spec.md`).
void main() {
  late _MockPresenceRepository repository;

  PendingPresenceConfirmation confirmationFor(String childId, String name) =>
      PendingPresenceConfirmation(
        confirmationId: 'confirmation-$childId',
        sessionId: 'session-1',
        childId: childId,
        childName: name,
        sessionStartsAt: DateTime.utc(2026, 9, 15, 16),
        groupName: 'الأشبال',
      );

  setUpAll(() {
    registerFallbackValue(
      const PresenceAnswerDraft(
        confirmationId: 'x',
        childId: 'y',
        answer: PresenceAnswerValue.yes,
      ),
    );
  });

  setUp(() {
    repository = _MockPresenceRepository();
    when(() => repository.answer(any())).thenAnswer((_) async {});
  });

  Future<void> pumpCard(
    WidgetTester tester,
    List<PendingPresenceConfirmation> pending,
  ) async {
    when(repository.watchUnanswered).thenAnswer((_) => Stream.value(pending));

    final container = ProviderContainer(
      overrides: [presenceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: AppL10n.localizationsDelegates,
          theme: RaeedTheme.light(const Locale('ar')),
          home: const Scaffold(body: PresencePromptCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppL10n l10nOf(WidgetTester tester) =>
      AppL10n.of(tester.element(find.byType(PresencePromptCard)));

  testWidgets('stays out of the way when nothing is owed', (tester) async {
    await pumpCard(tester, const []);

    expect(find.text(l10nOf(tester).presenceYes), findsNothing);
  });

  testWidgets('asks once per unanswered confirmation', (tester) async {
    // Two siblings, two questions: collapsing them into one prompt would make
    // an answer for one look like an answer for both.
    await pumpCard(tester, [
      confirmationFor('child-1', 'آدم'),
      confirmationFor('child-2', 'مريم'),
    ]);

    final l10n = l10nOf(tester);
    expect(find.text(l10n.homeNeedsYourReply), findsNWidgets(2));
    expect(find.textContaining('آدم'), findsOneWidget);
    expect(find.textContaining('مريم'), findsOneWidget);
  });

  testWidgets('"yes" answers straight from the card', (tester) async {
    await pumpCard(tester, [confirmationFor('child-1', 'آدم')]);

    await tester.tap(find.text(l10nOf(tester).presenceYes));
    await tester.pumpAndSettle();

    final draft =
        verify(() => repository.answer(captureAny())).captured.single
            as PresenceAnswerDraft;
    expect(draft.childId, 'child-1');
    expect(draft.answer, PresenceAnswerValue.yes);
    expect(draft.reason, isNull);
    expect(find.byType(PresenceConfirmationSheet), findsNothing);
  });

  testWidgets('"no" opens the sheet pre-answered rather than submitting', (
    tester,
  ) async {
    // The reason is optional but it is the reason the sheet exists, so "no"
    // must not be recorded behind the parent's back.
    await pumpCard(tester, [confirmationFor('child-1', 'آدم')]);

    await tester.tap(find.text(l10nOf(tester).presenceNo));
    await tester.pumpAndSettle();

    expect(find.byType(PresenceConfirmationSheet), findsOneWidget);
    verifyNever(() => repository.answer(any()));
    // Pre-answered: the reason chips are already showing, which they only do
    // once an answer of "no" or "late" is chosen.
    expect(find.text(l10nOf(tester).presenceReasonIllness), findsOneWidget);
  });

  testWidgets('survives 130% text scaling', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    when(repository.watchUnanswered).thenAnswer(
      (_) => Stream.value([confirmationFor('child-1', 'عبد الرحمن الإدريسي')]),
    );
    final container = ProviderContainer(
      overrides: [presenceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: AppL10n.localizationsDelegates,
            theme: RaeedTheme.light(const Locale('ar')),
            home: const Scaffold(body: PresencePromptCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
