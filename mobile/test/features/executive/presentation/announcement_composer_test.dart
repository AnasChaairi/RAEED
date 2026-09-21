import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/features/executive/domain/announcement_draft.dart';
import 'package:raeed/features/executive/presentation/announcement_composer_screen.dart';
import 'package:raeed/features/executive/presentation/widgets/executive_confirm_sheet.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;

  const reach = AudienceReach(
    allCount: 264,
    parentsCount: 246,
    educatorsCount: 18,
    categories: [
      AudienceCategory(id: 'ashbal', name: 'الأشبال', guardianCount: 58),
      AudienceCategory(id: 'zahrat', name: 'الزهرات', guardianCount: 49),
    ],
  );

  setUp(() {
    mocks = ExecutiveMocks();
    when(() => mocks.announcements.fetchReach()).thenAnswer((_) async => reach);
    when(() => mocks.announcements.publish(any()))
        .thenAnswer((_) async => 'ann-9');
  });

  Future<void> pump(WidgetTester tester) async {
    final container = await executiveContainer(mocks);
    await pumpExecutive(
      tester,
      container,
      const AnnouncementComposerScreen(),
      routes: {'/dashboard': const Text('shell')},
    );
    await tester.pumpAndSettle();
  }

  Finder sendButton() => find.widgetWithText(FilledButton, 'نشر الإعلان');

  testWidgets('cannot send without a title', (tester) async {
    await pump(tester);

    expect(tester.widget<FilledButton>(sendButton()).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'يوم مفتوح');
    await tester.pump();

    expect(tester.widget<FilledButton>(sendButton()).onPressed, isNotNull);
  });

  testWidgets('defaults to guardians and shows the live reach', (tester) async {
    await pump(tester);

    expect(find.textContaining('أولياء الأمور فقط'), findsOneWidget);
    expect(find.textContaining('246'), findsOneWidget);
  });

  testWidgets('the audience sheet changes the reach and the summary', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('تغيير'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('فئات محددة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الأشبال'));
    await tester.pumpAndSettle();
    // 58 guardians, said as people.
    expect(find.textContaining('58'), findsWidgets);
    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();

    expect(find.textContaining('أولياء أطفال: الأشبال'), findsOneWidget);
  });

  testWidgets('a normal announcement publishes on one tap', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField).first, 'يوم مفتوح');
    await tester.pump();

    await tester.tap(sendButton());
    await tester.pumpAndSettle();

    final draft =
        verify(() => mocks.announcements.publish(captureAny())).captured.single
            as AnnouncementDraft;
    expect(draft.title, 'يوم مفتوح');
    expect(draft.priority, AnnouncementPriority.normal);
    expect(draft.audience, const AnnouncementAudience.parents());
    expect(find.byType(ExecutiveConfirmSheet), findsNothing);
    expect(find.text('shell'), findsOneWidget);
  });

  testWidgets('urgent sits behind the high-reach confirm naming the reach', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField).first, 'تغيير قاعة');
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('إرسال عاجل · 246'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'إرسال عاجل · 246'));
    await tester.pumpAndSettle();

    expect(find.byType(ExecutiveConfirmSheet), findsOneWidget);
    expect(find.text('إرسال عاجل إلى 246 شخصًا؟'), findsOneWidget);
    verifyNever(() => mocks.announcements.publish(any()));

    await tester.tap(find.text('نعم، إرسال عاجل'));
    await tester.pumpAndSettle();

    final draft =
        verify(() => mocks.announcements.publish(captureAny())).captured.single
            as AnnouncementDraft;
    expect(draft.priority, AnnouncementPriority.urgent);
  });

  testWidgets(
    'cancelling the urgent confirm sends nothing and keeps the draft',
    (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField).first, 'تغيير قاعة');
      await tester.pump();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'إرسال عاجل · 246'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      verifyNever(() => mocks.announcements.publish(any()));
      expect(find.text('تغيير قاعة'), findsOneWidget);
    },
  );
}
