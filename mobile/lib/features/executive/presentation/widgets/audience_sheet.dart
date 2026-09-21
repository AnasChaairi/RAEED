import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../application/audience_reach.dart';
import '../../domain/announcement_draft.dart';
import '../audience_label.dart';

/// The audience picker: four modes, category chips, and a live reach count
/// with a plain-language summary — so the number the executive confirms on
/// the urgent dialog is the number they built here.
class AudienceSheet extends StatefulWidget {
  const AudienceSheet({required this.initial, this.reach, super.key});

  final AnnouncementAudience initial;

  /// Null when the reach endpoint failed; the picker still works, without
  /// counts.
  final AudienceReach? reach;

  /// Opens the sheet; resolves to the chosen audience, or null on dismiss.
  static Future<AnnouncementAudience?> show(
    BuildContext context, {
    required AnnouncementAudience initial,
    AudienceReach? reach,
  }) => showModalBottomSheet<AnnouncementAudience>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AudienceSheet(initial: initial, reach: reach),
  );

  @override
  State<AudienceSheet> createState() => _AudienceSheetState();
}

class _AudienceSheetState extends State<AudienceSheet> {
  late AnnouncementAudience _audience = widget.initial;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final reach = widget.reach;
    final total = reach == null ? null : reachFor(_audience, reach);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RaeedRadius.xl2),
        ),
        boxShadow: context.elevationSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xl,
              RaeedSpacing.md,
              RaeedSpacing.xl,
              0,
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: RaeedSpacing.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.annAudienceSheetTitle,
                    style: context.type.h3.copyWith(color: palette.ink),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.xl,
                vertical: RaeedSpacing.md,
              ),
              children: [
                for (final mode in AudienceMode.values) ...[
                  _ModeRow(
                    label: _modeLabel(l10n, mode),
                    count: _modeCount(mode),
                    selected: _audience.mode == mode,
                    onTap: () => setState(
                      () => _audience = mode == AudienceMode.categories
                          ? AnnouncementAudience(
                              mode: mode,
                              categoryIds: _audience.categoryIds,
                            )
                          : AnnouncementAudience(mode: mode),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (_audience.mode == AudienceMode.categories &&
                    reach != null) ...[
                  const SizedBox(height: RaeedSpacing.sm),
                  Text(
                    l10n.audCategoriesHeading,
                    style: context.type.label.copyWith(color: palette.inkDim),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final category in reach.categories)
                        _CategoryChip(
                          label: category.name,
                          selected: _audience.categoryIds.contains(category.id),
                          onTap: () => setState(
                            () => _audience = _audience.withCategoryToggled(
                              category.id,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  RaeedSpacing.xl,
                  RaeedSpacing.md,
                  RaeedSpacing.xl,
                  RaeedSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (total != null)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$total ',
                              style: context.type
                                  .tabular(context.type.h1)
                                  .copyWith(color: palette.primary),
                            ),
                            TextSpan(
                              text: l10n
                                  .audPeople(total)
                                  .replaceFirst('$total ', ''),
                              style: context.type.bodySmall.copyWith(
                                color: palette.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      audienceSummary(l10n, _audience, reach: reach),
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.md),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_audience),
                      child: Text(l10n.audDone),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(AppL10n l10n, AudienceMode mode) => switch (mode) {
    AudienceMode.all => l10n.audAll,
    AudienceMode.parents => l10n.audParents,
    AudienceMode.educators => l10n.audEducators,
    AudienceMode.categories => l10n.audCategories,
  };

  String? _modeCount(AudienceMode mode) {
    final reach = widget.reach;
    if (reach == null) return null;
    return switch (mode) {
      AudienceMode.all => '${reach.allCount}',
      AudienceMode.parents => '${reach.parentsCount}',
      AudienceMode.educators => '${reach.educatorsCount}',
      AudienceMode.categories => '…',
    };
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final String? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: count == null ? label : '$label ($count)',
      child: Material(
        color: selected ? palette.primarySoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          side: BorderSide(
            color: selected ? palette.primary : palette.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? palette.primary : Colors.transparent,
                      border: Border.all(
                        color: selected ? palette.primary : palette.inkDim,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: RaeedSpacing.sm + 2),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        label,
                        style: context.type.bodySmall.copyWith(
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ),
                  if (count != null)
                    ExcludeSemantics(
                      child: Text(
                        count!,
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? palette.primary : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? palette.primary : palette.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.md),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: context.type.label.copyWith(
                      color: selected ? palette.primaryOn : palette.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
