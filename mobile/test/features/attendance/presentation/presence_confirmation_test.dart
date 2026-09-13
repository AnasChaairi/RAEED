import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/l10n/generated/app_localizations.dart';
import 'package:raeed/core/theme/design_tokens.gen.dart';
import 'package:raeed/core/theme/raeed_theme.dart';
import 'package:raeed/features/attendance/domain/attendance_repository.dart';
import 'package:raeed/features/attendance/domain/presence_answer.dart';
import 'package:raeed/features/attendance/presentation/attendance_providers.dart';
import 'package:raeed/features/attendance/presentation/presence_confirmation_sheet.dart';

class _MockPresenceRepository extends Mock implements PresenceRepository {}

/// `RAEED-16`: "one-tap Yes/No/Late with an optional reason chip set → done, no
/// typing required unless 'other'."
///
/// A parent answers this one-handed, often with seconds of signal left. Every
/// extra tap is a confirmation that does not get answered.
void main() {
  late _MockPresenceRepository repository;

  final confirmation = PendingPresenceConfirmation(
    confirmationId: 'confirmation-1',
    sessionId: 'session-1',
    childId: 'child-1',
    childName: 'آدم',
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

  Future<void> pumpSheet(WidgetTester tester) async {
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
          home: Scaffold(
            body: PresenceConfirmationSheet(confirmation: confirmation),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppL10n l10nOf(WidgetTester tester) =>
      AppL10n.of(tester.element(find.byType(PresenceConfirmationSheet)));

  testWidgets('offers exactly the three answers', (tester) async {
    await pumpSheet(tester);
    final l10n = l10nOf(tester);

    expect(find.text(l10n.presenceYes), findsOneWidget);
    expect(find.text(l10n.presenceNo), findsOneWidget);
    expect(find.text(l10n.presenceLate), findsOneWidget);
  });

  testWidgets('"yes" submits on the first tap, with no reason', (tester) async {
    // There is nothing further to collect, so a confirm button would be a tap
    // for nothing.
    await pumpSheet(tester);
    await tester.tap(find.text(l10nOf(tester).presenceYes));
    await tester.pumpAndSettle();

    final draft =
        verify(() => repository.answer(captureAny())).captured.single
            as PresenceAnswerDraft;
    expect(draft.answer, PresenceAnswerValue.yes);
    expect(draft.reason, isNull);
    expect(draft.childId, 'child-1');
    expect(draft.confirmationId, 'confirmation-1');
  });

  testWidgets('shows no reason chips until an absence is chosen', (
    tester,
  ) async {
    await pumpSheet(tester);
    final l10n = l10nOf(tester);

    expect(find.text(l10n.presenceReasonIllness), findsNothing);

    await tester.tap(find.text(l10n.presenceNo));
    await tester.pumpAndSettle();

    expect(find.text(l10n.presenceReasonIllness), findsOneWidget);
    expect(find.text(l10n.presenceReasonTravel), findsOneWidget);
    expect(find.text(l10n.presenceReasonExam), findsOneWidget);
    expect(find.text(l10n.presenceReasonOther), findsOneWidget);
  });

  testWidgets('the reason is genuinely optional', (tester) async {
    await pumpSheet(tester);
    final l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.presenceNo));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonConfirm));
    await tester.pumpAndSettle();

    final draft =
        verify(() => repository.answer(captureAny())).captured.single
            as PresenceAnswerDraft;
    expect(draft.answer, PresenceAnswerValue.no);
    expect(draft.reason, isNull);
  });

  testWidgets('records a chosen reason', (tester) async {
    await pumpSheet(tester);
    final l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.presenceNo));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.presenceReasonIllness));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonConfirm));
    await tester.pumpAndSettle();

    final draft =
        verify(() => repository.answer(captureAny())).captured.single
            as PresenceAnswerDraft;
    expect(draft.reason, AbsenceReason.illness);
  });

  testWidgets('no keyboard appears unless "other" is chosen', (tester) async {
    // "No typing required unless 'other'" — the text field is the only thing
    // that would raise a keyboard, so its absence is the assertion.
    await pumpSheet(tester);
    final l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.presenceNo));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text(l10n.presenceReasonIllness));
    await tester.pumpAndSettle();
    expect(
      find.byType(TextField),
      findsNothing,
      reason: 'a named reason needs no free text',
    );

    await tester.tap(find.text(l10n.presenceReasonOther));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('sends the free-text note only with "other"', (tester) async {
    await pumpSheet(tester);
    final l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.presenceLate));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.presenceReasonOther));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'موعد طبيب');
    await tester.tap(find.text(l10n.commonConfirm));
    await tester.pumpAndSettle();

    final draft =
        verify(() => repository.answer(captureAny())).captured.single
            as PresenceAnswerDraft;
    expect(draft.answer, PresenceAnswerValue.late);
    expect(draft.reason, AbsenceReason.other);
    expect(draft.note, 'موعد طبيب');
  });

  testWidgets('answer buttons meet the primary-action touch target', (
    tester,
  ) async {
    await pumpSheet(tester);

    final buttons = find.descendant(
      of: find.byType(PresenceConfirmationSheet),
      matching: find.byType(OutlinedButton),
    );
    for (var index = 0; index < tester.widgetList(buttons).length; index++) {
      expect(
        tester.getSize(buttons.at(index)).height,
        greaterThanOrEqualTo(RaeedTouchTarget.primaryActionsPx),
      );
    }
  });

  testWidgets('holds up at 130% text scaling', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 720 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [presenceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

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
            home: Scaffold(
              body: PresenceConfirmationSheet(confirmation: confirmation),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10nOf(tester).presenceNo));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
