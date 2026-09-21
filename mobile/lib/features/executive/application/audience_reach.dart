import '../domain/announcement_draft.dart';

/// How many people [audience] reaches, from the server's counts.
///
/// For a category audience the reach is the sum of the chosen categories'
/// guardian counts — the same figure the audience sheet shows next to each
/// chip, so the total the executive confirms is the total they built.
int reachFor(AnnouncementAudience audience, AudienceReach reach) =>
    switch (audience.mode) {
      AudienceMode.all => reach.allCount,
      AudienceMode.parents => reach.parentsCount,
      AudienceMode.educators => reach.educatorsCount,
      AudienceMode.categories =>
        reach.categories
            .where((category) => audience.categoryIds.contains(category.id))
            .fold(0, (sum, category) => sum + category.guardianCount),
    };

/// The chosen categories, in the server's order, for the plain-language
/// summary under the reach count.
List<AudienceCategory> chosenCategories(
  AnnouncementAudience audience,
  AudienceReach reach,
) => reach.categories
    .where((category) => audience.categoryIds.contains(category.id))
    .toList(growable: false);
