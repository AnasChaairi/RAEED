import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/features/executive/domain/memories_review.dart';
import 'package:raeed/features/executive/presentation/memories_tab.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 20, 11);

  ReviewPost post(String id, {bool blocked = false}) => ReviewPost(
    id: id,
    albumTitle: 'رحلة الغابة',
    groupName: 'الفراشات 1',
    authorName: 'خديجة بنجلون',
    postedAt: DateTime.utc(2026, 9, 12, 10),
    mediaCount: 10,
    isBlocked: blocked,
    tags: [
      const TaggedChild(
        id: 'c1',
        name: 'هشام',
        imageRights: ImageRightsLevel.allowed,
      ),
      if (blocked)
        const TaggedChild(
          id: 'c2',
          name: 'نور',
          imageRights: ImageRightsLevel.notAllowed,
        )
      else
        const TaggedChild(
          id: 'c2',
          name: 'يوسف',
          imageRights: ImageRightsLevel.appOnly,
        ),
    ],
  );

  setUp(() {
    mocks = ExecutiveMocks();
    when(() => mocks.memories.approve(any())).thenAnswer((_) async {});
    when(() => mocks.memories.hide(any())).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) async {
    final container = await executiveContainer(mocks);
    await pumpExecutive(tester, container, MemoriesTab(now: now));
    await tester.pumpAndSettle();
  }

  testWidgets('every tagged child carries their image-rights level', (
    tester,
  ) async {
    when(() => mocks.memories.fetchQueue()).thenAnswer(
      (_) async => ReviewQueue(
        posts: [post('p1')],
        moderationMode: ModerationMode.approveBeforePublish,
      ),
    );
    await pump(tester);

    expect(findSemanticsLabel('هشام — حقوق الصورة: مسموح'), findsOneWidget);
    expect(
      findSemanticsLabel('يوسف — حقوق الصورة: داخل التطبيق فقط'),
      findsOneWidget,
    );
    expect(find.textContaining('الاعتماد أولًا'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'اعتماد'), findsOneWidget);
  });

  testWidgets('an unset moderation mode is said, not defaulted', (
    tester,
  ) async {
    when(() => mocks.memories.fetchQueue())
        .thenAnswer((_) async => ReviewQueue(posts: [post('p1')]));
    await pump(tester);

    expect(find.textContaining('لم يُحدَّد بعد'), findsOneWidget);
  });

  testWidgets('a blocked post names the child and offers re-approval', (
    tester,
  ) async {
    when(
      () => mocks.memories.fetchQueue(),
    ).thenAnswer((_) async => ReviewQueue(posts: [post('p3', blocked: true)]));
    await pump(tester);

    expect(find.textContaining('محجوب'), findsOneWidget);
    expect(find.textContaining('نور صار «غير مسموح»'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'إعادة الاعتماد'), findsOneWidget);
  });

  testWidgets('approving advances the queue, then shows all reviewed', (
    tester,
  ) async {
    when(() => mocks.memories.fetchQueue()).thenAnswer(
      (_) async => ReviewQueue(
        posts: [post('p1'), post('p2')],
        moderationMode: ModerationMode.approveBeforePublish,
      ),
    );
    await pump(tester);
    expect(find.textContaining('منشوران بانتظارك'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'اعتماد'));
    await tester.pumpAndSettle();
    verify(() => mocks.memories.approve('p1')).called(1);
    expect(find.textContaining('منشور واحد بانتظارك'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'إخفاء'));
    await tester.pumpAndSettle();
    verify(() => mocks.memories.hide('p2')).called(1);
    expect(find.text('راجعت كل شيء'), findsOneWidget);
  });
}
