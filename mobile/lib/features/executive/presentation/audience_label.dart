import '../../../core/l10n/generated/app_localizations.dart';
import '../application/audience_reach.dart';
import '../domain/announcement_draft.dart';

/// "أولياء الأمور فقط", "أولياء أطفال: الأشبال، الزهرات".
String audienceLabel(
  AppL10n l10n,
  AnnouncementAudience audience, {
  AudienceReach? reach,
}) => switch (audience.mode) {
  AudienceMode.all => l10n.audAll,
  AudienceMode.parents => l10n.audParents,
  AudienceMode.educators => l10n.audEducators,
  AudienceMode.categories => l10n.audCategories,
  AudienceMode.groups => l10n.execTabGroups,
};

/// The plain-language line under the reach count.
String audienceSummary(
  AppL10n l10n,
  AnnouncementAudience audience, {
  AudienceReach? reach,
}) => switch (audience.mode) {
  AudienceMode.all => l10n.audSummaryAll,
  AudienceMode.parents => l10n.audSummaryParents,
  AudienceMode.educators => l10n.audSummaryEducators,
  AudienceMode.categories =>
    audience.isEmptySelection
        ? l10n.audSummaryNone
        : l10n.audSummaryCategories(
            reach == null
                ? '${audience.categoryIds.length}'
                : chosenCategories(
                    audience,
                    reach,
                  ).map((category) => category.name).join('، '),
          ),
  AudienceMode.groups =>
    audience.isEmptySelection
        ? l10n.audSummaryNone
        : (reach?.groups ?? const [])
              .where((group) => audience.groupIds.contains(group.id))
              .map((group) => group.name)
              .join('، '),
};
