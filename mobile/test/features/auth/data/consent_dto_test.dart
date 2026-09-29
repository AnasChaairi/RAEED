import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/auth/data/auth_dtos.dart';
import 'package:raeed/features/auth/domain/consent.dart';

void main() {
  test('a consent already given on the server counts as given', () {
    final requirement = consentRequirementFromJson({
      'privacy_policy_accepted': true,
      'children': [
        {'id': 'c1', 'full_name': 'أحمد', 'current_level': 'app_only'},
      ],
    });

    expect(requirement.children.single.currentLevel, ImageRightsLevel.appOnly);
    expect(requirement.isSatisfied, isTrue);
  });

  test('a child nobody has answered for still needs an answer', () {
    final requirement = consentRequirementFromJson({
      'privacy_policy_accepted': true,
      'children': [
        {'id': 'c1', 'full_name': 'أحمد', 'current_level': null},
      ],
    });
    expect(requirement.isSatisfied, isFalse);
  });
}
