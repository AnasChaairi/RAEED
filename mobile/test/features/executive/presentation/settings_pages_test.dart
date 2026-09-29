import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/error/api_error_code.dart';
import 'package:raeed/core/error/raeed_exception.dart';
import 'package:raeed/core/session/session_controller.dart';
import 'package:raeed/features/executive/domain/executive_child.dart';
import 'package:raeed/features/executive/domain/executive_group.dart';
import 'package:raeed/features/executive/domain/family.dart';
import 'package:raeed/features/executive/domain/reports.dart';
import 'package:raeed/features/executive/domain/structure.dart';
import 'package:raeed/features/executive/presentation/children_screen.dart';
import 'package:raeed/features/executive/presentation/executive_child_screen.dart';
import 'package:raeed/features/executive/presentation/logs_screen.dart';
import 'package:raeed/features/executive/presentation/manage_screen.dart';
import 'package:raeed/features/executive/presentation/more_screen.dart';
import 'package:raeed/features/executive/presentation/new_family_screen.dart';
import 'package:raeed/features/executive/presentation/new_group_screen.dart';
import 'package:raeed/features/executive/presentation/reports_screen.dart';
import 'package:raeed/features/executive/presentation/structure_screen.dart';

import 'executive_test_support.dart';

const forbidden = ApiException(
  code: ApiErrorCode.scopeForbidden,
  message: 'forbidden',
  statusCode: 403,
);

void main() {
  late ExecutiveMocks mocks;
  final now = DateTime.utc(2026, 9, 20, 11);

  const salma = Child(
    id: 'c1',
    fullName: 'سلمى القادري',
    healthAlert: true,
    group: ChildGroupRef(id: 'g1', name: 'الأشبال 1'),
  );
  const yassine = Child(id: 'c2', fullName: 'ياسين برادة', healthAlert: false);

  const ashbal = ExecutiveGroup(
    id: 'g1',
    name: 'الأشبال 1',
    categoryName: 'الأشبال',
    enrolledCount: 19,
    capacity: 20,
    educatorNames: ['عبد الله المرابط'],
  );

  final profile = ExecutiveChildProfile(
    id: 'c1',
    fullName: 'سلمى القادري',
    hasHealthAlert: true,
    imageRights: ImageRightsLevel.appOnly,
    dateOfBirth: DateTime(2018, 3, 4),
    mainGroup: const ChildGroupRef(id: 'g1', name: 'الأشبال 1'),
    seasonAttendance: const AttendanceRatio(present: 9, expected: 10),
    guardians: const [
      GuardianSummary(
        id: 'u-m',
        displayName: 'فاطمة القادري',
        relationship: 'mother',
        account: AccountStatus.active,
        phoneHint: '••••34',
      ),
    ],
    privacyConsents: [PrivacyConsent(guardianId: 'u-m', version: 1, at: now)],
    imageRightsConsents: const [],
    groups: const [
      ChildGroupMembership(
        id: 'g1',
        name: 'الأشبال 1',
        isMain: true,
        attendance: AttendanceRatio(present: 9, expected: 10),
      ),
    ],
    conversationId: 'conv-1',
  );

  setUp(() => mocks = ExecutiveMocks());

  group('More', () {
    testWidgets('lists the sections, tags admin ones and signs out', (
      tester,
    ) async {
      when(
        () => mocks.executiveChildren.fetchChildren(
          query: any(named: 'query'),
          categoryId: any(named: 'categoryId'),
          unassigned: true,
        ),
      ).thenAnswer(
        (_) async => const [
          ExecutiveChildSummary(
            child: yassine,
            imageRights: ImageRightsLevel.allowed,
          ),
        ],
      );
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const MoreScreen());
      await tester.pumpAndSettle();

      expect(find.text('الأطفال'), findsOneWidget);
      expect(find.text('الأسر والمجموعات'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // the unassigned badge
      expect(find.text('مدير النظام'), findsNWidgets(2));

      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      expect(
        container.read(sessionControllerProvider).isAuthenticated,
        isFalse,
      );
    });
  });

  group('children list', () {
    testWidgets('shows name, group, attendance and the image-rights dot', (
      tester,
    ) async {
      when(
        () => mocks.executiveChildren.fetchChildren(
          query: any(named: 'query'),
          categoryId: any(named: 'categoryId'),
          unassigned: any(named: 'unassigned'),
        ),
      ).thenAnswer(
        (_) async => const [
          ExecutiveChildSummary(
            child: salma,
            imageRights: ImageRightsLevel.notAllowed,
            attendance: AttendanceRatio(present: 9, expected: 10),
          ),
        ],
      );
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const ChildrenScreen());
      await tester.pumpAndSettle();

      expect(find.text('سلمى القادري'), findsOneWidget);
      expect(find.textContaining('الأشبال 1'), findsOneWidget);
      expect(find.textContaining('9/10'), findsOneWidget);
      expect(findSemanticsLabel('حقوق الصورة: غير مسموح'), findsOneWidget);
    });
  });

  group('executive child profile', () {
    testWidgets('health text needs a confirm, the request is logged', (
      tester,
    ) async {
      when(() => mocks.executiveChildren.fetchProfile('c1'))
          .thenAnswer((_) async => profile);
      when(() => mocks.executiveChildren.revealHealth('c1')).thenAnswer(
        (_) async => HealthReveal(
          health: const HealthInfo(allergies: ['الفول السوداني']),
          viewedAt: now,
        ),
      );
      final container = await executiveContainer(mocks);

      await pumpExecutive(
        tester,
        container,
        ExecutiveChildScreen(childId: 'c1', now: now),
      );
      await tester.pumpAndSettle();

      // Nothing sensitive is on screen before the confirm.
      expect(find.textContaining('الفول السوداني'), findsNothing);
      verifyNever(() => mocks.executiveChildren.revealHealth(any()));

      await tester.tap(find.text('عرض المعلومات الصحية'));
      await tester.pumpAndSettle();
      expect(find.textContaining('أنس'), findsOneWidget);
      verifyNever(() => mocks.executiveChildren.revealHealth(any()));

      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      verify(() => mocks.executiveChildren.revealHealth('c1')).called(1);
      expect(find.textContaining('الفول السوداني'), findsOneWidget);
    });

    testWidgets('a guardian phone is masked until the logged reveal', (
      tester,
    ) async {
      when(() => mocks.executiveChildren.fetchProfile('c1'))
          .thenAnswer((_) async => profile);
      when(
        () => mocks.executiveChildren.revealPhone(
          childId: 'c1',
          guardianId: 'u-m',
        ),
      ).thenAnswer(
        (_) async => PhoneReveal(phone: '+212600000034', revealedAt: now),
      );
      final container = await executiveContainer(mocks);

      await pumpExecutive(
        tester,
        container,
        ExecutiveChildScreen(childId: 'c1', now: now),
      );
      await tester.pumpAndSettle();

      expect(find.text('+212600000034'), findsNothing);
      expect(find.text('••••34'), findsOneWidget);

      await tester.tap(find.text('إظهار ⦿'));
      await tester.pumpAndSettle();
      expect(find.text('+212600000034'), findsOneWidget);
      expect(find.textContaining('سُجّل إظهار الرقم'), findsOneWidget);
    });
  });

  group('families and groups', () {
    testWidgets('assigning shows capacity after and records the move', (
      tester,
    ) async {
      when(
        () => mocks.executiveChildren.fetchChildren(
          query: any(named: 'query'),
          categoryId: any(named: 'categoryId'),
          unassigned: true,
        ),
      ).thenAnswer(
        (_) async => const [
          ExecutiveChildSummary(
            child: yassine,
            imageRights: ImageRightsLevel.allowed,
          ),
        ],
      );
      when(() => mocks.groups.fetchGroups())
          .thenAnswer((_) async => const [ashbal]);
      when(() => mocks.families.assignChildren(groupId: 'g1', childIds: ['c2']))
          .thenAnswer((_) async => (enrolledCount: 20, capacity: 20));
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const ManageScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('ياسين برادة'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // The sheet offers the group and, once chosen, the count after.
      await tester.tap(find.text('الأشبال 1'));
      await tester.pumpAndSettle();
      expect(find.text('19→20/20'), findsOneWidget);
      expect(find.textContaining('يُسجَّل الإسناد'), findsOneWidget);

      await tester.tap(find.textContaining('إسناد إلى'));
      await tester.pumpAndSettle();
      verify(
        () => mocks.families.assignChildren(groupId: 'g1', childIds: ['c2']),
      ).called(1);
    });

    testWidgets('a full group asks again before going over', (tester) async {
      const full = ExecutiveGroup(
        id: 'g1',
        name: 'الأشبال 1',
        categoryName: 'الأشبال',
        enrolledCount: 20,
        capacity: 20,
      );
      when(
        () => mocks.executiveChildren.fetchChildren(
          query: any(named: 'query'),
          categoryId: any(named: 'categoryId'),
          unassigned: true,
        ),
      ).thenAnswer(
        (_) async => const [
          ExecutiveChildSummary(
            child: yassine,
            imageRights: ImageRightsLevel.allowed,
          ),
        ],
      );
      when(() => mocks.groups.fetchGroups())
          .thenAnswer((_) async => const [full]);
      when(
        () => mocks.families.assignChildren(
          groupId: any(named: 'groupId'),
          childIds: any(named: 'childIds'),
        ),
      ).thenAnswer((_) async => (enrolledCount: 21, capacity: 20));
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const ManageScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('ياسين برادة'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الأشبال 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('إسناد إلى'));
      await tester.pumpAndSettle();

      // Not yet: the over-capacity confirm stands between.
      verifyNever(
        () => mocks.families.assignChildren(
          groupId: any(named: 'groupId'),
          childIds: any(named: 'childIds'),
        ),
      );
      await tester.tap(find.text('نعم، إسناد'));
      await tester.pumpAndSettle();
      verify(
        () => mocks.families.assignChildren(groupId: 'g1', childIds: ['c2']),
      ).called(1);
    });

    testWidgets('a pending family can have its invitation re-sent', (
      tester,
    ) async {
      when(() => mocks.families.fetchFamilies()).thenAnswer(
        (_) async => const [
          Family(
            id: 'f1',
            label: 'أسرة برادة',
            guardians: [
              FamilyGuardian(
                id: 'u-p',
                displayName: 'كريم برادة',
                account: AccountStatus.pending,
              ),
            ],
            children: [FamilyChild(id: 'c2', fullName: 'ياسين برادة')],
            status: FamilyStatus.pending,
          ),
        ],
      );
      when(() => mocks.families.resendInvitation('u-p'))
          .thenAnswer((_) async => 'k7m2x9');
      final container = await executiveContainer(mocks);

      await pumpExecutive(
        tester,
        container,
        const ManageScreen(initialTab: ManageTab.families),
      );
      await tester.pumpAndSettle();

      expect(find.text('أسرة برادة'), findsOneWidget);
      await tester.tap(find.text('إعادة الدعوة'));
      await tester.pumpAndSettle();
      verify(() => mocks.families.resendInvitation('u-p')).called(1);
      // The fresh password is shown once, for the executive to hand over.
      expect(find.text('k7m2x9'), findsOneWidget);
      await tester.tap(find.byKey(const Key('handover-done')));
      await tester.pumpAndSettle();
      expect(find.text('k7m2x9'), findsNothing);
    });
  });

  group('new group', () {
    testWidgets('the button waits for name, category and an educator', (
      tester,
    ) async {
      when(() => mocks.structure.fetchCategories()).thenAnswer(
        (_) async => const [
          Category(id: 'cat1', name: 'الأشبال', childCount: 0, groupCount: 0),
        ],
      );
      when(() => mocks.families.fetchEducators()).thenAnswer(
        (_) async => const [
          Educator(id: 'e1', displayName: 'عبد الله المرابط', groupCount: 1),
        ],
      );
      when(() => mocks.families.createGroup(any()))
          .thenAnswer((_) async => ashbal);
      final container = await executiveContainer(mocks);

      await pumpExecutive(
        tester,
        container,
        const NewGroupScreen(),
        routes: {'/manage': const Text('manage')},
      );
      await tester.pumpAndSettle();

      final button = find.byType(FilledButton);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'الأشبال 2');
      await tester.tap(find.text('الأشبال'));
      await tester.tap(find.text('عبد الله المرابط'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      await tester.pumpAndSettle();
      final draft =
          verify(() => mocks.families.createGroup(captureAny())).captured.single
              as GroupDraft;
      expect(draft.name, 'الأشبال 2');
      expect(draft.categoryId, 'cat1');
      expect(draft.educatorIds, {'e1'});
    });
  });

  group('new family', () {
    testWidgets('walks guardians → children → review and never asks health', (
      tester,
    ) async {
      when(() => mocks.families.createFamily(any())).thenAnswer(
        (_) async => const FamilyCreated(
          guardianIds: ['u9'],
          childIds: ['c9'],
          invitations: 1,
        ),
      );
      final container = await executiveContainer(mocks);

      await pumpExecutive(
        tester,
        container,
        const NewFamilyScreen(),
        routes: {'/manage': const Text('manage')},
      );
      await tester.pumpAndSettle();

      final next = find.byType(FilledButton);
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      await tester.enterText(find.byType(TextFormField).at(0), 'كريم برادة');
      await tester.enterText(find.byType(TextFormField).at(1), '612345678');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(next).onPressed, isNotNull);
      await tester.tap(next);
      await tester.pumpAndSettle();

      expect(find.text('الطفل 1'), findsOneWidget);
      expect(find.textContaining('الصحية'), findsOneWidget); // the notice
      expect(find.text('الحساسية'), findsNothing); // no health field
      await tester.enterText(find.byType(TextFormField), 'ياسين برادة');
      await tester.pumpAndSettle();
      expect(find.text('ياسين برادة'), findsOneWidget);
      await tester.tap(find.textContaining('اختر التاريخ'));
      await tester.pumpAndSettle();
      expect(find.text('ياسين برادة'), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();

      expect(find.textContaining('612345678'), findsOneWidget);
      await tester.tap(next);
      await tester.pumpAndSettle();
      final draft =
          verify(() => mocks.families.createFamily(captureAny()))
                  .captured
                  .single
              as FamilyDraft;
      expect(draft.guardians.single.e164, '+212612345678');
      expect(draft.children.single.fullName, 'ياسين برادة');
    });
  });

  group('reports', () {
    testWidgets('rates carry their raw pair', (tester) async {
      when(() => mocks.reports.fetchAttendance()).thenAnswer(
        (_) async => const AttendanceReport(
          byEducator: [
            RateRow(
              id: 'e1',
              name: 'عبد الله',
              ratio: AttendanceRatio(present: 9, expected: 10),
            ),
          ],
          byCategory: [],
        ),
      );
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const ReportsScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('90%', findRichText: true), findsOneWidget);
      expect(find.textContaining('(9/10)', findRichText: true), findsOneWidget);
    });

    testWidgets('export flags health fields and shares the recorded file', (
      tester,
    ) async {
      when(() => mocks.reports.export(any())).thenAnswer(
        (_) async => ExportFile(
          filename: 'raeed-export.csv',
          content: 'a,b',
          fields: const [ExportField.name, ExportField.allergies],
          containsHealth: true,
          rowCount: 3,
          createdAt: now,
        ),
      );
      final container = await executiveContainer(mocks);
      ExportFile? shared;

      await pumpExecutive(
        tester,
        container,
        ExportTab(share: (file) async => shared = file),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('يحتوي بيانات صحية'), findsNothing);
      await tester.tap(find.text('الحساسية'));
      await tester.pumpAndSettle();
      expect(find.textContaining('يحتوي بيانات صحية'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      final fields =
          verify(() => mocks.reports.export(captureAny())).captured.single
              as Set<ExportField>;
      expect(fields, contains(ExportField.allergies));
      expect(find.textContaining('الملف جاهز'), findsOneWidget);

      await tester.tap(find.text('مشاركة الملف'));
      await tester.pumpAndSettle();
      expect(shared?.filename, 'raeed-export.csv');
    });
  });

  group('admin-only sections', () {
    testWidgets('a refused executive sees the card, and the attempt was made', (
      tester,
    ) async {
      when(() => mocks.structure.fetchSeasons()).thenThrow(forbidden);
      when(() => mocks.structure.fetchAuditLog(action: any(named: 'action')))
          .thenThrow(forbidden);
      final container = await executiveContainer(mocks);

      await pumpExecutive(tester, container, const StructureScreen());
      await tester.pumpAndSettle();
      expect(find.text('هذا القسم لمدير النظام فقط'), findsOneWidget);
      expect(find.textContaining('إداري'), findsOneWidget);
      verify(() => mocks.structure.fetchSeasons()).called(1);

      await pumpExecutive(tester, container, LogsScreen(now: now));
      await tester.pumpAndSettle();
      expect(find.text('هذا القسم لمدير النظام فقط'), findsOneWidget);
    });

    testWidgets('an admin archives a season after a confirm', (tester) async {
      when(() => mocks.structure.fetchSeasons()).thenAnswer(
        (_) async => [
          Season(
            id: 's1',
            label: '2026–2027',
            startDate: DateTime(2026, 9),
            endDate: DateTime(2027, 6, 30),
            status: SeasonStatus.active,
            groupCount: 4,
            childCount: 80,
          ),
          Season(
            id: 's0',
            label: '2025–2026',
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 6, 30),
            status: SeasonStatus.archived,
            groupCount: 3,
            childCount: 70,
          ),
        ],
      );
      when(() => mocks.structure.archiveSeason('s1')).thenAnswer((_) async {});
      final container = await executiveContainer(
        mocks,
        roles: {RaeedRole.admin},
      );

      await pumpExecutive(tester, container, const StructureScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('أرشفة'));
      await tester.pumpAndSettle();
      verifyNever(() => mocks.structure.archiveSeason(any()));
      await tester.tap(find.text('أرشفة الموسم'));
      await tester.pumpAndSettle();
      verify(() => mocks.structure.archiveSeason('s1')).called(1);
    });

    testWidgets('an admin adds a category by name and nothing else', (
      tester,
    ) async {
      when(() => mocks.structure.fetchSeasons()).thenAnswer((_) async => []);
      when(() => mocks.structure.createCategory(name: 'الأشبال')).thenAnswer(
        (_) async => const Category(
          id: 'cat-new',
          name: 'الأشبال',
          childCount: 0,
          groupCount: 0,
        ),
      );
      final container = await executiveContainer(
        mocks,
        roles: {RaeedRole.admin},
      );

      await pumpExecutive(tester, container, const StructureScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('الفئات'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ فئة جديدة'));
      await tester.pumpAndSettle();

      // One field: the age range and gender are not asked (open decision #1).
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('category-name')),
        ' الأشبال ',
      );
      await tester.tap(find.byKey(const Key('structure-save')));
      await tester.pumpAndSettle();

      verify(() => mocks.structure.createCategory(name: 'الأشبال')).called(1);
      expect(find.textContaining('أُنشئت الفئة'), findsOneWidget);
    });

    testWidgets('an admin opens a season once its dates are in order', (
      tester,
    ) async {
      when(() => mocks.structure.fetchSeasons()).thenAnswer((_) async => []);
      when(
        () => mocks.structure.createSeason(
          label: any(named: 'label'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => Season(
          id: 's-new',
          label: '2026-2027',
          startDate: DateTime(2026, 9),
          endDate: DateTime(2027, 6, 30),
          status: SeasonStatus.active,
          groupCount: 0,
          childCount: 0,
        ),
      );
      final container = await executiveContainer(
        mocks,
        roles: {RaeedRole.admin},
      );

      await pumpExecutive(tester, container, const StructureScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ موسم جديد'));
      await tester.pumpAndSettle();

      final save = find.byKey(const Key('structure-save'));
      await tester.enterText(
        find.byKey(const Key('season-label')),
        '2026-2027',
      );
      await tester.pumpAndSettle();
      // No dates yet: nothing to save.
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      // Start today, end today too — not after, so still refused on the device.
      await tester.tap(find.byKey(const Key('season-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('season-end')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حسنًا'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      verifyNever(
        () => mocks.structure.createSeason(
          label: any(named: 'label'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      );
    });

    testWidgets('the health tab of the logs asks for health views only', (
      tester,
    ) async {
      when(() => mocks.structure.fetchAuditLog(action: 'child.health_view'))
          .thenAnswer(
            (_) async => [
              AuditEntry(
                id: 'a1',
                at: now.subtract(const Duration(minutes: 5)),
                action: 'child.health_view',
                resourceType: 'child',
                actorName: 'أنس',
                resourceLabel: 'سلمى القادري',
              ),
            ],
          );
      final container = await executiveContainer(
        mocks,
        roles: {RaeedRole.admin},
      );

      await pumpExecutive(tester, container, LogsScreen(now: now));
      await tester.pumpAndSettle();
      expect(find.text('لا سجلات بعد'), findsOneWidget);

      await tester.tap(find.text('الوصول الصحي'));
      await tester.pumpAndSettle();
      expect(find.textContaining('عرض بيانات صحية'), findsOneWidget);
      expect(find.text('سلمى القادري'), findsOneWidget);
    });
  });
}
