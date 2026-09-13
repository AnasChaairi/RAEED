import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/authorization/ability.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/features/children/application/child_status_pill.dart';
import 'package:raeed/features/children/application/home_scope.dart';
import 'package:raeed/features/children/domain/child.dart';
import 'package:raeed/features/children/domain/child_day_status.dart';

/// `specs/05-authorization.md` forbids branching on a role string in the UI.
/// The home screen therefore asks the ability model which children it is
/// showing, and this is the test of that translation.
void main() {
  Ability abilityFor(
    Set<RaeedRole> roles, {
    Set<String> children = const {},
    Set<String> groups = const {},
  }) => defineAbilityFor(
    AbilityPrincipal(
      userId: 'user-1',
      roles: roles,
      reachableChildIds: children,
      reachableGroupIds: groups,
    ),
  );

  group('resolveHomeScope', () {
    test('a parent with children sees their own', () {
      expect(
        resolveHomeScope(abilityFor({RaeedRole.parent}, children: {'child-1'})),
        HomeScope.ownChildren,
      );
    });

    test('an educator with a group sees that group\'s children', () {
      expect(
        resolveHomeScope(abilityFor({RaeedRole.educator}, groups: {'group-1'})),
        HomeScope.groupChildren,
      );
    });

    test('an executive sees everything', () {
      expect(
        resolveHomeScope(abilityFor({RaeedRole.executive})),
        HomeScope.allChildren,
      );
    });

    test('an admin sees everything', () {
      expect(
        resolveHomeScope(abilityFor({RaeedRole.admin})),
        HomeScope.allChildren,
      );
    });

    test('oversight wins when a user is both executive and parent', () {
      // An executive who is also a parent opened the app for the oversight
      // view; the wider scope is the useful default.
      expect(
        resolveHomeScope(
          abilityFor(
            {RaeedRole.executive, RaeedRole.parent},
            children: {'child-1'},
          ),
        ),
        HomeScope.allChildren,
      );
    });

    test('a parent with no linked children reaches nothing', () {
      expect(resolveHomeScope(abilityFor({RaeedRole.parent})), HomeScope.none);
    });

    test('an educator with no group assignment reaches nothing', () {
      expect(
        resolveHomeScope(abilityFor({RaeedRole.educator})),
        HomeScope.none,
      );
    });

    test('an anonymous principal reaches nothing', () {
      expect(
        resolveHomeScope(defineAbilityFor(const AbilityPrincipal.anonymous())),
        HomeScope.none,
      );
    });
  });

  group('resolveStatusPill', () {
    final now = DateTime(2026, 9, 13, 10);

    Child childWith(ChildDayStatus status) => Child(
      id: 'child-1',
      fullName: 'آدم',
      healthAlert: false,
      todayStatus: status,
    );

    test('a fresh absence alert overrides everything into the alert state', () {
      final pill = resolveStatusPill(
        childWith(
          ChildDayStatus(
            kind: DayStatusKind.absent,
            alertRaisedAt: now.subtract(const Duration(minutes: 5)),
          ),
        ),
        now,
      );

      expect(pill.isAlert, isTrue);
      expect(pill.tone, StatusPillTone.critical);
    });

    test('a stale alert no longer shouts', () {
      // Yesterday's resolved alert must not dominate a morning when nothing is
      // wrong.
      final pill = resolveStatusPill(
        childWith(
          ChildDayStatus(
            kind: DayStatusKind.absent,
            alertRaisedAt: now.subtract(const Duration(days: 1)),
          ),
        ),
        now,
      );

      expect(pill.isAlert, isFalse);
    });

    test('an unanswered presence confirmation is actionable', () {
      // It has to survive a missed push by surfacing on the card itself.
      final pill = resolveStatusPill(
        childWith(
          const ChildDayStatus(kind: DayStatusKind.awaitingPresenceAnswer),
        ),
        now,
      );

      expect(pill.isActionable, isTrue);
    });

    test('no session today is muted and not actionable', () {
      final pill = resolveStatusPill(
        childWith(const ChildDayStatus.noSession()),
        now,
      );

      expect(pill.isAlert, isFalse);
      expect(pill.isActionable, isFalse);
    });

    test('every status kind resolves to a pill without throwing', () {
      for (final kind in DayStatusKind.values) {
        expect(
          () => resolveStatusPill(childWith(ChildDayStatus(kind: kind)), now),
          returnsNormally,
          reason: '$kind must render, including the unknown fallback',
        );
      }
    });
  });
}
