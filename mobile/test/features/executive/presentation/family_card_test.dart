import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raeed/features/executive/domain/family.dart';
import 'package:raeed/features/executive/presentation/manage_screen.dart';

import 'executive_test_support.dart';

/// The family card on the Families tab is a summary that opens the household.
void main() {
  late ExecutiveMocks mocks;

  const idrissi = Family(
    id: 'p1,p2',
    label: 'الإدريسي',
    guardians: [
      FamilyGuardian(
        id: 'p1',
        displayName: 'سعاد',
        account: AccountStatus.active,
      ),
      FamilyGuardian(
        id: 'p2',
        displayName: 'كريم',
        account: AccountStatus.active,
      ),
    ],
    children: [FamilyChild(id: 'c1', fullName: 'يوسف الإدريسي')],
    status: FamilyStatus.active,
  );

  setUp(() {
    mocks = ExecutiveMocks();
    when(() => mocks.families.fetchFamilies())
        .thenAnswer((_) async => const [idrissi]);
  });

  /// Renders the tab under a router whose family route echoes what it got.
  Future<void> pumpTab(WidgetTester tester) async {
    final container = await executiveContainer(mocks);
    await pumpExecutive(
      tester,
      container,
      const ManageScreen(initialTab: ManageTab.families),
      routes: {
        '/manage/families/:familyId': Builder(
          builder: (context) {
            final state = GoRouterState.of(context);
            final family = state.extra;
            return Text(
              'family ${state.pathParameters['familyId']} '
              'action=${state.uri.queryParameters['action']} '
              'extra=${family is Family ? family.label : 'none'}',
            );
          },
        ),
      },
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the card opens the household with the family in hand', (
    tester,
  ) async {
    await pumpTab(tester);

    await tester.tap(find.text('الإدريسي'));
    await tester.pumpAndSettle();

    expect(
      find.text('family p1,p2 action=null extra=الإدريسي'),
      findsOneWidget,
    );
  });

  testWidgets('"+ طفل" opens the same household with the add-child sheet', (
    tester,
  ) async {
    await pumpTab(tester);

    await tester.tap(find.text('+ طفل'));
    await tester.pumpAndSettle();

    expect(
      find.text('family p1,p2 action=add-child extra=الإدريسي'),
      findsOneWidget,
    );
  });
}
