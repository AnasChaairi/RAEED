import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/executive/application/audience_reach.dart';
import 'package:raeed/features/executive/domain/announcement_draft.dart';

void main() {
  const reach = AudienceReach(
    allCount: 264,
    parentsCount: 246,
    educatorsCount: 18,
    categories: [
      AudienceCategory(id: 'ashbal', name: 'الأشبال', guardianCount: 58),
      AudienceCategory(id: 'zahrat', name: 'الزهرات', guardianCount: 49),
      AudienceCategory(id: 'fitya', name: 'الفتية', guardianCount: 34),
    ],
  );

  test('the fixed audiences use the server counts', () {
    expect(reachFor(const AnnouncementAudience.all(), reach), 264);
    expect(reachFor(const AnnouncementAudience.parents(), reach), 246);
    expect(reachFor(const AnnouncementAudience.educators(), reach), 18);
  });

  test('a category audience sums the chosen categories', () {
    const audience = AnnouncementAudience(
      mode: AudienceMode.categories,
      categoryIds: {'ashbal', 'zahrat'},
    );
    expect(reachFor(audience, reach), 107);
    expect(chosenCategories(audience, reach).map((c) => c.name), [
      'الأشبال',
      'الزهرات',
    ]);
  });

  test('no category chosen reaches nobody and is not sendable', () {
    const audience = AnnouncementAudience(mode: AudienceMode.categories);
    expect(reachFor(audience, reach), 0);
    expect(audience.isEmptySelection, isTrue);
    expect(
      const AnnouncementDraft(title: 'x', audience: audience).isSendable,
      isFalse,
    );
  });

  test('an unknown category id counts for nothing', () {
    const audience = AnnouncementAudience(
      mode: AudienceMode.categories,
      categoryIds: {'nope'},
    );
    expect(reachFor(audience, reach), 0);
  });

  test('toggling a category flips it and forces the categories mode', () {
    final audience = const AnnouncementAudience.parents().withCategoryToggled(
      'ashbal',
    );
    expect(audience.mode, AudienceMode.categories);
    expect(audience.categoryIds, {'ashbal'});
    expect(audience.withCategoryToggled('ashbal').categoryIds, isEmpty);
  });
}
