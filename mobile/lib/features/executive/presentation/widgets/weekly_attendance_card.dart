import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/dashboard_overview.dart';
import 'executive_card.dart';

/// This week's attendance rate with the trailing weeks as a bar strip.
///
/// The strip is decorative context for the number, not a chart to read:
/// no axis, no legend, and the "too little data" state replaces the number
/// rather than showing a misleading 0%.
class WeeklyAttendanceCard extends StatelessWidget {
  const WeeklyAttendanceCard({required this.attendance, super.key});

  final WeeklyAttendance attendance;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final rate = attendance.ratePercent;
    final delta = attendance.deltaPoints;
    final caption = context.type.tabular(context.type.caption);

    return ExecutiveCard(
      semanticLabel: rate == null
          ? '${l10n.dashWeeklyAttendance}: ${l10n.dashTooLittleData}'
          : '${l10n.dashWeeklyAttendance}: $rate% '
                '(${attendance.presentCount} / ${attendance.expectedCount})',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    l10n.dashWeeklyAttendance,
                    style: context.type.label.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${attendance.presentCount} / ${attendance.expectedCount}',
                  style: caption.copyWith(color: palette.inkDim),
                ),
              ],
            ),
            const SizedBox(height: RaeedSpacing.xs),
            if (rate == null)
              Text(
                l10n.dashTooLittleData,
                style: context.type.bodySmall.copyWith(color: palette.inkDim),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$rate%',
                    style: context.type
                        .tabular(context.type.h1)
                        .copyWith(color: palette.ink, height: 1.2),
                  ),
                  if (delta != null && delta != 0) ...[
                    const SizedBox(width: RaeedSpacing.sm),
                    Text(
                      delta > 0 ? '▲ $delta' : '▼ ${-delta}',
                      style: caption.copyWith(
                        color: delta > 0 ? palette.success : palette.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            if (attendance.weeklyRates.isNotEmpty) ...[
              const SizedBox(height: RaeedSpacing.sm),
              _BarStrip(rates: attendance.weeklyRates),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarStrip extends StatelessWidget {
  const _BarStrip({required this.rates});

  final List<int> rates;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < rates.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: FractionallySizedBox(
                heightFactor: _heightFor(rates[i]),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i == rates.length - 1
                        ? palette.primary
                        : palette.primarySoft,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Bars span the 60–100% band the association actually lives in; a full
  /// 0–100 axis would make every week look identical.
  static double _heightFor(int rate) =>
      ((rate - 60) / 40).clamp(0.12, 1).toDouble();
}
