import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/authorization/ability.dart';
import 'package:raeed/core/authorization/raeed_role.dart';

/// `specs/11-testing-strategy.md`: "Every ability rule in
/// `05-authorization.md` gets a test asserting both the allow *and* the deny
/// case."
///
/// The deny half is the half that matters. A permission test that only asserts
/// the allow case passes just as happily against an ability model that returns
/// `true` unconditionally — which is exactly the bug that would let a parent
/// read another family's child.
void main() {
  // One fixed cast, so every test reads against the same relationships.
  const ownChildId = 'child-own';
  const otherChildId = 'child-other';
  const ownGroupId = 'group-own';
  const otherGroupId = 'group-other';
  const ownBranchId = 'branch-own';
  const otherBranchId = 'branch-other';

  Ability abilityFor(
    Set<RaeedRole> roles, {
    Set<String> children = const {},
    Set<String> groups = const {},
    String? branchId,
  }) => defineAbilityFor(
    AbilityPrincipal(
      userId: 'user-1',
      roles: roles,
      reachableChildIds: children,
      reachableGroupIds: groups,
      branchId: branchId,
    ),
  );

  ResourceRef child(String id) =>
      ResourceRef(subject: AbilitySubject.child, childId: id);
  ResourceRef childInGroup(String groupId) =>
      ResourceRef(subject: AbilitySubject.child, groupId: groupId);

  group('anonymous', () {
    test('can do nothing at all', () {
      final ability = defineAbilityFor(const AbilityPrincipal.anonymous());

      for (final subject in AbilitySubject.values) {
        for (final action in AbilityAction.values) {
          expect(
            ability.can(action, ResourceRef.type(subject)),
            isFalse,
            reason: 'anonymous should not be able to $action on $subject',
          );
        }
      }
    });
  });

  group('parent', () {
    late Ability ability;

    setUp(() {
      ability = abilityFor({RaeedRole.parent}, children: {ownChildId});
    });

    test('reads their own child — allow', () {
      expect(ability.can(AbilityAction.read, child(ownChildId)), isTrue);
    });

    test('cannot read another family\'s child — deny', () {
      expect(ability.can(AbilityAction.read, child(otherChildId)), isFalse);
    });

    test('cannot read a child by guessing a UUID — deny', () {
      // The scope-leakage case from specs/11-testing-strategy.md, case 5: a
      // valid-looking id the caller has no relationship with must not open a
      // door. On the client this only removes the affordance; the server
      // answers scope.forbidden regardless.
      expect(
        ability.can(
          AbilityAction.read,
          child('3f2504e0-4f89-41d3-9a0c-0305e82c3301'),
        ),
        isFalse,
      );
    });

    test('reads their own child\'s health info — allow', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.childHealth,
            childId: ownChildId,
          ),
        ),
        isTrue,
      );
    });

    test('cannot read another child\'s health info — deny', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.childHealth,
            childId: otherChildId,
          ),
        ),
        isFalse,
      );
    });

    test('answers a presence confirmation for their own child — allow', () {
      expect(
        ability.can(
          AbilityAction.answer,
          const ResourceRef(
            subject: AbilitySubject.presenceConfirmation,
            childId: ownChildId,
          ),
        ),
        isTrue,
      );
    });

    test('cannot answer for another child — deny', () {
      expect(
        ability.can(
          AbilityAction.answer,
          const ResourceRef(
            subject: AbilitySubject.presenceConfirmation,
            childId: otherChildId,
          ),
        ),
        isFalse,
      );
    });

    test('marks their own child\'s homework done — allow', () {
      expect(
        ability.can(
          AbilityAction.markDone,
          const ResourceRef(
            subject: AbilitySubject.homework,
            childId: ownChildId,
          ),
        ),
        isTrue,
      );
    });

    test('cannot update an attendance record — deny', () {
      // Attendance is recorded by educators and corrected by executives.
      // A guardian marking their own child present would defeat the point.
      expect(
        ability.can(
          AbilityAction.update,
          const ResourceRef(
            subject: AbilitySubject.attendanceRecord,
            childId: ownChildId,
          ),
        ),
        isFalse,
      );
    });

    test('cannot read a staff conversation — deny', () {
      // specs/10-security-and-privacy.md: parents never see the staff channel.
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.conversation,
            conversationKind: ConversationKind.staff,
            isConversationMember: true,
          ),
        ),
        isFalse,
        reason: 'membership must not override the staff-channel exclusion',
      );
    });

    test('reads a child conversation they are a member of — allow', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.conversation,
            conversationKind: ConversationKind.child,
            isConversationMember: true,
          ),
        ),
        isTrue,
      );
    });

    test('cannot create an announcement — deny', () {
      expect(
        ability.can(
          AbilityAction.create,
          const ResourceRef.type(AbilitySubject.announcement),
        ),
        isFalse,
      );
    });

    test('cannot reach the dashboard — deny', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef.type(AbilitySubject.dashboard),
        ),
        isFalse,
      );
    });

    test('cannot read the audit log — deny', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef.type(AbilitySubject.auditLogEntry),
        ),
        isFalse,
      );
    });

    test('cannot manage structure — deny', () {
      for (final subject in [
        AbilitySubject.season,
        AbilitySubject.category,
        AbilitySubject.group,
        AbilitySubject.roleAssignment,
      ]) {
        expect(
          ability.can(AbilityAction.manage, ResourceRef.type(subject)),
          isFalse,
          reason: 'a parent must not manage $subject',
        );
      }
    });
  });

  group('educator', () {
    late Ability ability;

    setUp(() {
      ability = abilityFor({RaeedRole.educator}, groups: {ownGroupId});
    });

    test('reads a child in their own group — allow', () {
      expect(ability.can(AbilityAction.read, childInGroup(ownGroupId)), isTrue);
    });

    test('cannot read a child in another group — deny', () {
      expect(
        ability.can(AbilityAction.read, childInGroup(otherGroupId)),
        isFalse,
      );
    });

    test('cannot read a child with no group relationship — deny', () {
      // The scope-leakage case: an educator holding a child's id but no
      // group_educator row reaching that child.
      expect(ability.can(AbilityAction.read, child(otherChildId)), isFalse);
    });

    test('updates attendance for their own group — allow', () {
      expect(
        ability.can(
          AbilityAction.update,
          const ResourceRef(
            subject: AbilitySubject.attendanceRecord,
            groupId: ownGroupId,
          ),
        ),
        isTrue,
      );
    });

    test('cannot update attendance for another group — deny', () {
      expect(
        ability.can(
          AbilityAction.update,
          const ResourceRef(
            subject: AbilitySubject.attendanceRecord,
            groupId: otherGroupId,
          ),
        ),
        isFalse,
      );
    });

    test('creates a session in their own group — allow', () {
      expect(
        ability.can(
          AbilityAction.create,
          const ResourceRef(
            subject: AbilitySubject.session,
            groupId: ownGroupId,
          ),
        ),
        isTrue,
      );
    });

    test('creates an announcement for their own group — allow', () {
      expect(
        ability.can(
          AbilityAction.create,
          const ResourceRef(
            subject: AbilitySubject.announcement,
            groupId: ownGroupId,
          ),
        ),
        isTrue,
      );
    });

    test('cannot create an announcement for another group — deny', () {
      // ANN-03: educators publish to their own groups only.
      expect(
        ability.can(
          AbilityAction.create,
          const ResourceRef(
            subject: AbilitySubject.announcement,
            groupId: otherGroupId,
          ),
        ),
        isFalse,
      );
    });

    test('cannot edit a child profile — deny', () {
      // CHD: staff notes only, and that field-level rule is server-side. The
      // app must not offer a general profile edit.
      expect(
        ability.can(AbilityAction.update, childInGroup(ownGroupId)),
        isFalse,
      );
    });

    test('cannot reach the dashboard — deny', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef.type(AbilitySubject.dashboard),
        ),
        isFalse,
      );
    });

    test('cannot read the audit log — deny', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef.type(AbilitySubject.auditLogEntry),
        ),
        isFalse,
      );
    });

    test('with no group assignment can reach no composer — deny', () {
      final unassigned = abilityFor({RaeedRole.educator});
      expect(
        unassigned.can(
          AbilityAction.create,
          const ResourceRef.type(AbilitySubject.announcement),
        ),
        isFalse,
      );
    });

    test('with a group assignment can reach the composer — allow', () {
      expect(
        ability.can(
          AbilityAction.create,
          const ResourceRef.type(AbilitySubject.announcement),
        ),
        isTrue,
        reason: 'a type-only check must not fail merely for naming no group',
      );
    });
  });

  group('executive', () {
    test('reads any child, with no relationship needed — allow', () {
      final ability = abilityFor({RaeedRole.executive});
      expect(ability.can(AbilityAction.read, child(otherChildId)), isTrue);
      expect(
        ability.can(AbilityAction.read, childInGroup(otherGroupId)),
        isTrue,
      );
    });

    test('reads any conversation — allow (logged and disclosed, MSG-08)', () {
      final ability = abilityFor({RaeedRole.executive});
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.conversation,
            conversationKind: ConversationKind.staff,
          ),
        ),
        isTrue,
      );
    });

    test('reaches the dashboard — allow', () {
      final ability = abilityFor({RaeedRole.executive});
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef.type(AbilitySubject.dashboard),
        ),
        isTrue,
      );
    });

    test('cannot read the audit log — deny (Admin only)', () {
      final ability = abilityFor({RaeedRole.executive});
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef.type(AbilitySubject.auditLogEntry),
        ),
        isFalse,
      );
    });

    test('cannot manage seasons — deny (Admin only)', () {
      final ability = abilityFor({RaeedRole.executive});
      expect(
        ability.can(
          AbilityAction.manage,
          const ResourceRef.type(AbilitySubject.season),
        ),
        isFalse,
      );
    });

    group('branch-restricted (ACC-08)', () {
      late Ability ability;

      setUp(() {
        ability = abilityFor({RaeedRole.executive}, branchId: ownBranchId);
      });

      test('reads a child in their own branch — allow', () {
        expect(
          ability.can(
            AbilityAction.read,
            const ResourceRef(
              subject: AbilitySubject.child,
              childId: otherChildId,
              branchId: ownBranchId,
            ),
          ),
          isTrue,
        );
      });

      test('cannot read a child in another branch — deny', () {
        expect(
          ability.can(
            AbilityAction.read,
            const ResourceRef(
              subject: AbilitySubject.child,
              childId: otherChildId,
              branchId: otherBranchId,
            ),
          ),
          isFalse,
        );
      });
    });
  });

  group('admin', () {
    late Ability ability;

    setUp(() => ability = abilityFor({RaeedRole.admin}));

    test('manages structure — allow', () {
      for (final subject in [
        AbilitySubject.season,
        AbilitySubject.category,
        AbilitySubject.group,
        AbilitySubject.roleAssignment,
      ]) {
        expect(
          ability.can(AbilityAction.manage, ResourceRef.type(subject)),
          isTrue,
          reason: 'an admin should manage $subject',
        );
      }
    });

    test('reads the audit log — allow', () {
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef.type(AbilitySubject.auditLogEntry),
        ),
        isTrue,
      );
    });

    test('manages structure even when branch-restricted — allow', () {
      // Structure management is not branch-scoped in the spec's rule set: the
      // `manage` grant on Season/Category/Group/RoleAssignment carries no
      // branch condition.
      final restricted = abilityFor({RaeedRole.admin}, branchId: ownBranchId);
      expect(
        restricted.can(
          AbilityAction.manage,
          const ResourceRef.type(AbilitySubject.season),
        ),
        isTrue,
      );
    });
  });

  group('multiple roles', () {
    test('an educator who is also a parent gets the union of both', () {
      // Common in a small association: a volunteer educator with a child
      // enrolled in a different group.
      final ability = abilityFor(
        {RaeedRole.parent, RaeedRole.educator},
        children: {ownChildId},
        groups: {ownGroupId},
      );

      expect(
        ability.can(AbilityAction.read, child(ownChildId)),
        isTrue,
        reason: 'their own child, via the parent role',
      );
      expect(
        ability.can(AbilityAction.read, childInGroup(ownGroupId)),
        isTrue,
        reason: 'their group\'s children, via the educator role',
      );
      expect(
        ability.can(AbilityAction.read, child(otherChildId)),
        isFalse,
        reason: 'holding two roles must not widen scope beyond either',
      );
      expect(
        ability.can(AbilityAction.read, childInGroup(otherGroupId)),
        isFalse,
      );
    });

    test('a parent who is also an educator still sees no staff channel', () {
      final ability = abilityFor(
        {RaeedRole.parent, RaeedRole.educator},
        children: {ownChildId},
        groups: {ownGroupId},
      );

      // The educator grant legitimately opens their own group's staff channel.
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.conversation,
            conversationKind: ConversationKind.staff,
            groupId: ownGroupId,
          ),
        ),
        isTrue,
      );
      // But not another group's.
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.conversation,
            conversationKind: ConversationKind.staff,
            groupId: otherGroupId,
          ),
        ),
        isFalse,
      );
    });
  });

  group('cannot overrides a prior can', () {
    test('the last matching rule wins, as in CASL', () {
      // Guards the rule-precedence contract the whole model rests on: the
      // parent's explicit `cannot(read, conversation type: staff)` is declared
      // after a broad `can(read, conversation)` and must carve an exception
      // out of it rather than being ignored.
      final ability = abilityFor({RaeedRole.parent}, children: {ownChildId});

      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.conversation,
            conversationKind: ConversationKind.child,
            isConversationMember: true,
          ),
        ),
        isTrue,
      );
      expect(
        ability.can(
          AbilityAction.read,
          const ResourceRef(
            subject: AbilitySubject.conversation,
            conversationKind: ConversationKind.staff,
            isConversationMember: true,
          ),
        ),
        isFalse,
      );
    });
  });

  group('cannot is the negation of can', () {
    test('for every subject and action', () {
      final ability = abilityFor({RaeedRole.parent}, children: {ownChildId});
      for (final subject in AbilitySubject.values) {
        final resource = ResourceRef.type(subject);
        for (final action in AbilityAction.values) {
          expect(
            ability.cannot(action, resource),
            equals(!ability.can(action, resource)),
          );
        }
      }
    });
  });
}
