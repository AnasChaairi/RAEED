import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/data/executive_announcement_dto.dart';
import 'package:raeed/features/executive/domain/announcement_draft.dart';

void main() {
  test('an announcement aimed at groups is not shown as aimed at everyone', () {
    final audience = audienceFromJson({
      'type': 'groups',
      'category_ids': <String>[],
      'group_ids': ['g1', 'g2'],
    });

    expect(audience.mode, AudienceMode.groups);
    expect(audience.groupIds, {'g1', 'g2'});
  });

  test('an audience this build does not know falls back to everyone', () {
    expect(audienceFromJson({'type': 'branches'}).mode, AudienceMode.all);
  });
}
