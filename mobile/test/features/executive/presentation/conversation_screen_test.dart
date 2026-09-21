import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/features/executive/domain/conversation.dart';
import 'package:raeed/features/executive/presentation/conversation_screen.dart';
import 'package:raeed/features/executive/presentation/widgets/executive_confirm_sheet.dart';

import 'executive_test_support.dart';

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 20, 11);

  final reported = ChatMessage(
    id: 'm1',
    senderId: 'u-hamza',
    senderName: 'حمزة الزياني',
    senderRole: RaeedRole.educator,
    kind: MessageKind.text,
    sentAt: DateTime.utc(2026, 9, 18, 18, 40),
    body: 'هل يمكن مشاركة رقم هاتف الأم؟',
    report: const MessageReport(
      id: 'rep-1',
      reporterName: 'سعاد الإدريسي',
      reason: 'طلب معلومات شخصية',
    ),
  );

  final voice = ChatMessage(
    id: 'm2',
    senderId: 'u-souad',
    senderName: 'سعاد الإدريسي',
    senderRole: RaeedRole.parent,
    kind: MessageKind.voice,
    sentAt: DateTime.utc(2026, 9, 18, 19, 2),
    durationSeconds: 23,
  );

  ConversationDetail detail({required bool isMember}) => ConversationDetail(
    id: 'c1',
    kind: ConversationKind.child,
    title: 'محادثة يوسف الإدريسي',
    isMember: isMember,
    memberNames: const ['سعاد (الأم)', 'عبد الله المرابط'],
  );

  setUp(() {
    mocks = ExecutiveMocks();
    when(() => mocks.messages.fetchMessages('c1'))
        .thenAnswer((_) async => [reported, voice]);
    when(() => mocks.messages.hideMessage(any())).thenAnswer((_) async {});
    when(() => mocks.messages.dismissReport(any())).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, {required bool isMember}) async {
    when(() => mocks.messages.fetchConversation('c1'))
        .thenAnswer((_) async => detail(isMember: isMember));
    final container = await executiveContainer(mocks);
    await pumpExecutive(
      tester,
      container,
      ConversationScreen(conversationId: 'c1', now: now),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a non-member sees the oversight notice above the thread', (
    tester,
  ) async {
    await pump(tester, isMember: false);

    expect(find.textContaining('إشرافٌ مُسجَّل'), findsOneWidget);
    expect(find.text('محادثة يوسف الإدريسي'), findsOneWidget);
    expect(find.textContaining('سعاد (الأم)'), findsOneWidget);
  });

  testWidgets('a member sees no oversight notice', (tester) async {
    await pump(tester, isMember: true);

    expect(find.textContaining('إشرافٌ مُسجَّل'), findsNothing);
  });

  testWidgets('a reported message shows who reported it and why', (
    tester,
  ) async {
    await pump(tester, isMember: false);

    expect(
      find.text('بلاغ من سعاد الإدريسي: طلب معلومات شخصية'),
      findsOneWidget,
    );
    expect(find.text('حمزة الزياني · مؤطِّر'), findsOneWidget);
    expect(find.text('0:23'), findsOneWidget);
  });

  testWidgets('hiding goes through the reversible confirm and leaves a stub', (
    tester,
  ) async {
    await pump(tester, isMember: false);

    await tester.tap(find.text('إخفاء'));
    await tester.pumpAndSettle();
    expect(find.byType(ExecutiveConfirmSheet), findsOneWidget);
    expect(find.text('إخفاء رسالة حمزة الزياني؟'), findsOneWidget);
    verifyNever(() => mocks.messages.hideMessage(any()));

    await tester.tap(find.text('إخفاء الرسالة'));
    await tester.pumpAndSettle();

    verify(() => mocks.messages.hideMessage('m1')).called(1);
    expect(find.textContaining('مخفية · أخفاها أنس'), findsOneWidget);
    expect(find.textContaining('يراها المشرفون فقط'), findsOneWidget);
    // The report actions are gone with the message.
    expect(find.text('رفض البلاغ'), findsNothing);
  });

  testWidgets('dismissing a report keeps the message and closes the report', (
    tester,
  ) async {
    await pump(tester, isMember: false);

    await tester.tap(find.text('رفض البلاغ'));
    await tester.pumpAndSettle();

    verify(() => mocks.messages.dismissReport('rep-1')).called(1);
    verifyNever(() => mocks.messages.hideMessage(any()));
    expect(find.text('هل يمكن مشاركة رقم هاتف الأم؟'), findsOneWidget);
    expect(find.textContaining('بلاغ من'), findsNothing);
  });
}
