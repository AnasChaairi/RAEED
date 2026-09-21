import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/dashboard_overview.dart';
import 'executive_card.dart';

/// Label, big tabular number, delta.
class StatTile extends StatelessWidget {
  const StatTile({required this.stat, super.key});

  final DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final delta = stat.delta;
    final label = switch (stat.kind) {
      StatKind.children => l10n.statChildren,
      StatKind.families => l10n.statFamilies,
      StatKind.groups => l10n.statGroups,
      StatKind.educators => l10n.statEducators,
    };

    return ExecutiveCard(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      radius: RaeedRadius.lg + 2,
      semanticLabel: delta == null
          ? '$label: ${stat.value}'
          : '$label: ${stat.value} (${_signed(delta)})',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (delta != null && delta != 0)
                  Text(
                    _signed(delta),
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(
                          color: delta > 0 ? palette.success : palette.inkDim,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${stat.value}',
              style: context.type
                  .tabular(context.type.h1)
                  .copyWith(color: palette.ink, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  static String _signed(int delta) => delta > 0 ? '+$delta' : '$delta';
}
