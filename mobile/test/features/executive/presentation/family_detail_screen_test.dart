import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/error/api_error_code.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/features/executive/domain/executive_child.dart';
import 'package:raeed/features/executive/domain/family.dart';
import 'package:raeed/features/executive/presentation/family_detail_screen.dart';

import 'executive_test_support.dart';

/// EXEC-M-10b — the family page edits a household after it was created.
void main() {
  late ExecutiveMocks mocks;

  const souad = FamilyGuardian(
    id: 'p1',
    displayName: 'سعاد',
    relationship: 'mother',
    phoneHint: '•• 34',
    account: AccountStatus.active,
  );
  const karim = FamilyGuardian(
    id: 'p2',
    displayName: 'كريم',
    relationship: 'father',
    phoneHint: '•• 77',
    account: AccountStatus.pending,
  );
  final youssef = FamilyChild(
    id: 'c1',
    fullName: 'يوسف الإدريسي',
    dob: DateTime(2018, 5, 2),
    group: const ChildGroupRef(id: 'g1', name: 'الأشبال 1'),
  );
  const maryam = FamilyChild(id: 'c2', fullName: 'مريم الإدريسي');

  final idrissi = Family(
    id: 'p1,p2',
    label: 'الإدريسي',
    guardians: const [souad, karim],
    children: [youssef, maryam],
    status: FamilyStatus.partial,
  );

  setUp(() {
    mocks = ExecutiveMocks();
    when(() => mocks.families.fetchFamily(any()))
        .thenAnswer((_) async => idrissi);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Family? initial,
    bool openAddChild = false,
  }) async {
    final container = await executiveContainer(mocks);
    await pumpExecutive(
      tester,
      container,
      FamilyDetailScreen(
        familyId: 'p1,p2',
        initial: initial,
        openAddChild: openAddChild,
      ),
    );
  }

  testWidgets('shows each guardian with their relationship and masked number, '
      'and each child with their group', (tester) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('سعاد · الأم'), findsOneWidget);
    expect(find.text('كريم · الأب'), findsOneWidget);
    expect(find.text('•• 34'), findsOneWidget);
    expect(find.text('يوسف الإدريسي'), findsOneWidget);
    expect(find.text('الأشبال 1'), findsOneWidget);
    // Unassigned children say so, in the warning tone the tab uses.
    expect(find.text('بلا مجموعة'), findsOneWidget);
    // A pending guardian keeps the resend action.
    expect(find.text('إعادة الدعوة'), findsOneWidget);
  });

  testWidgets('renders the pushed family before the fetch answers', (
    tester,
  ) async {
    when(() => mocks.families.fetchFamily(any())).thenAnswer(
      (_) => Future.delayed(const Duration(seconds: 5), () => idrissi),
    );
    await pumpPage(tester, initial: idrissi);
    await tester.pump();

    expect(find.text('سعاد · الأم'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('editing a guardian sends only what changed, and a new number '
      'warns that every device is signed out', (tester) async {
    const renamed = Family(
      id: 'p1,p2',
      label: 'الإدريسي',
      guardians: [souad, karim],
      children: [maryam],
      status: FamilyStatus.partial,
    );
    when(
      () => mocks.families.updateGuardian(
        familyId: any(named: 'familyId'),
        guardianId: any(named: 'guardianId'),
        patch: any(named: 'patch'),
      ),
    ).thenAnswer((_) async => renamed);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-guardian-p1')));
    await tester.pumpAndSettle();
    // Nothing changed yet: save stays disabled.
    final save = find.byKey(const Key('sheet-save'));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    expect(find.byKey(const Key('phone-change-warning')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('guardian-phone')),
      '611223344',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('phone-change-warning')), findsOneWidget);
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

    await tester.tap(save);
    await tester.pumpAndSettle();

    final patch =
        verify(
              () => mocks.families.updateGuardian(
                familyId: 'p1,p2',
                guardianId: 'p1',
                patch: captureAny(named: 'patch'),
              ),
            ).captured.single
            as GuardianPatch;
    expect(patch.e164, '+212611223344');
    expect(patch.displayName, isNull);
    expect(patch.relationship, isNull);
    // The page now shows what the server returned, not what it had.
    expect(find.text('يوسف الإدريسي'), findsNothing);
    expect(find.text('حُفظ التعديل.'), findsOneWidget);
  });

  testWidgets('a refused edit stays in the sheet with the values kept', (
    tester,
  ) async {
    when(
      () => mocks.families.updateGuardian(
        familyId: any(named: 'familyId'),
        guardianId: any(named: 'guardianId'),
        patch: any(named: 'patch'),
      ),
    ).thenThrow(
      const ApiException(
        code: ApiErrorCode.guardiansPhoneTaken,
        message: 'taken',
        statusCode: 409,
      ),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-guardian-p1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('guardian-phone')),
      '611223344',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sheet-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sheet-error')), findsOneWidget);
    expect(find.text('هذا الرقم مستعمل في حساب آخر.'), findsOneWidget);
    expect(find.byKey(const Key('guardian-phone')), findsOneWidget);
  });

  testWidgets('unlinking asks first, then shows the household it now is', (
    tester,
  ) async {
    final alone = Family(
      id: 'p1',
      label: 'الإدريسي',
      guardians: const [souad],
      children: [youssef, maryam],
      status: FamilyStatus.active,
    );
    when(
      () => mocks.families.unlinkGuardian(familyId: 'p1,p2', guardianId: 'p2'),
    ).thenAnswer((_) async => alone);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('unlink-guardian-p2')));
    await tester.pumpAndSettle();
    expect(find.text('فصل كريم عن الأسرة؟'), findsOneWidget);
    verifyNever(
      () => mocks.families.unlinkGuardian(
        familyId: any(named: 'familyId'),
        guardianId: any(named: 'guardianId'),
      ),
    );

    await tester.tap(find.text('فصل'));
    await tester.pumpAndSettle();

    expect(find.text('كريم · الأب'), findsNothing);
    expect(find.text('فُصل الوليّ عن الأسرة.'), findsOneWidget);
    // The last guardian cannot be unlinked, so the action is not offered.
    expect(find.byKey(const Key('unlink-guardian-p1')), findsNothing);
  });

  testWidgets('the last-guardian refusal is explained', (tester) async {
    when(
      () => mocks.families.unlinkGuardian(
        familyId: any(named: 'familyId'),
        guardianId: any(named: 'guardianId'),
      ),
    ).thenThrow(
      const ApiException(
        code: ApiErrorCode.childrenLastGuardian,
        message: 'last',
        statusCode: 409,
        details: {
          'child_ids': ['c2'],
        },
      ),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('unlink-guardian-p2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('فصل'));
    await tester.pumpAndSettle();

    expect(find.textContaining('بلا وليّ'), findsOneWidget);
    expect(find.text('كريم · الأب'), findsOneWidget);
  });

  testWidgets('linking a new guardian hands over the first password once', (
    tester,
  ) async {
    const grandmother = FamilyGuardian(
      id: 'p3',
      displayName: 'الجدة',
      account: AccountStatus.pending,
    );
    when(
      () => mocks.families.addGuardian(
        familyId: any(named: 'familyId'),
        guardian: any(named: 'guardian'),
      ),
    ).thenAnswer(
      (_) async => GuardianAdded(
        family: Family(
          id: 'p1,p2,p3',
          label: 'الإدريسي',
          guardians: const [souad, karim, grandmother],
          children: [youssef, maryam],
          status: FamilyStatus.partial,
        ),
        credential: const GuardianCredential(
          id: 'p3',
          displayName: 'الجدة',
          password: 'v7bh9w',
        ),
      ),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('family-add-guardian')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('guardian-name')), 'الجدة');
    await tester.enterText(
      find.byKey(const Key('guardian-phone')),
      '655000000',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sheet-save')));
    await tester.pumpAndSettle();

    final draft =
        verify(
              () => mocks.families.addGuardian(
                familyId: 'p1,p2',
                guardian: captureAny(named: 'guardian'),
              ),
            ).captured.single
            as GuardianDraft;
    expect(draft.e164, '+212655000000');
    expect(find.text('v7bh9w'), findsOneWidget);
    await tester.tap(find.byKey(const Key('handover-done')));
    await tester.pumpAndSettle();
    expect(find.text('الجدة · ولي الأمر'), findsOneWidget);
  });

  testWidgets('linking an existing account says its password is unchanged', (
    tester,
  ) async {
    when(
      () => mocks.families.addGuardian(
        familyId: any(named: 'familyId'),
        guardian: any(named: 'guardian'),
      ),
    ).thenAnswer(
      (_) async => GuardianAdded(
        family: idrissi,
        credential: const GuardianCredential(
          id: 'p9',
          displayName: 'x',
          password: null,
        ),
      ),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('family-add-guardian')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('guardian-name')), 'حسن');
    await tester.enterText(
      find.byKey(const Key('guardian-phone')),
      '600000009',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sheet-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('handover-done')), findsNothing);
    expect(find.textContaining('كلمة مروره لم تتغيّر'), findsOneWidget);
  });

  testWidgets('adding a child from the card opens the sheet on arrival and '
      'never asks for health', (tester) async {
    when(
      () => mocks.families.addChild(
        familyId: any(named: 'familyId'),
        child: any(named: 'child'),
      ),
    ).thenAnswer((_) async => ChildAdded(family: idrissi, childId: 'c9'));
    await pumpPage(tester, initial: idrissi, openAddChild: true);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('child-name')), findsOneWidget);
    expect(find.textContaining('الصحية'), findsOneWidget);
    expect(find.text('الحساسية'), findsNothing);

    await tester.enterText(find.byKey(const Key('child-name')), 'آدم الإدريسي');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('اختر التاريخ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حسنًا'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sheet-save')));
    await tester.pumpAndSettle();

    final draft =
        verify(
              () => mocks.families.addChild(
                familyId: 'p1,p2',
                child: captureAny(named: 'child'),
              ),
            ).captured.single
            as ChildDraft;
    expect(draft.fullName, 'آدم الإدريسي');
    expect(draft.dateOfBirth, isNotNull);
    expect(draft.groupId, isNull);
    expect(find.text('أُضيف الطفل إلى الأسرة.'), findsOneWidget);
  });

  testWidgets('correcting a child sends only the changed field', (
    tester,
  ) async {
    when(
      () => mocks.families.updateChild(
        familyId: any(named: 'familyId'),
        childId: any(named: 'childId'),
        patch: any(named: 'patch'),
      ),
    ).thenAnswer((_) async => idrissi);
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-child-c1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('child-name')),
      'يوسف الإدريسي ',
    );
    await tester.pumpAndSettle();
    // Same name once trimmed: nothing to save.
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('sheet-save')))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const Key('child-name')),
      'يوسف الإدريسي الصغير',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sheet-save')));
    await tester.pumpAndSettle();

    final patch =
        verify(
              () => mocks.families.updateChild(
                familyId: 'p1,p2',
                childId: 'c1',
                patch: captureAny(named: 'patch'),
              ),
            ).captured.single
            as ChildPatch;
    expect(patch.fullName, 'يوسف الإدريسي الصغير');
    expect(patch.dateOfBirth, isNull);
  });

  testWidgets(
    'a family that is no longer visible offers the list, not a retry',
    (tester) async {
      when(() => mocks.families.fetchFamily(any())).thenThrow(
        const ApiException(
          code: ApiErrorCode.scopeForbidden,
          message: 'gone',
          statusCode: 403,
        ),
      );
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('هذه الأسرة لم تعد متاحة'), findsOneWidget);
      expect(find.text('إلى الأسر'), findsOneWidget);
    },
  );
}
