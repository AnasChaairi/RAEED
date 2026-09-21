import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/dashboard_overview.dart';
import 'executive_card.dart';
import 'tone_chip.dart';

/// One alert in the "needs your attention" panel.
///
/// Severity is carried three ways at once — the chip's word, its icon, and
/// the card's tint — and the danger card alone takes an outline, which is
/// what lets it be found without reading.
class AlertCard extends StatelessWidget {
  const AlertCard({required this.alert, this.onTap, super.key});

  final DashboardAlert alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final tone = toneFor(alert.severity);
    final colors = ToneChip.colorsFor(context, tone);
    final isDanger = alert.severity == AlertSeverity.danger;

    return ExecutiveCard(
      onTap: onTap,
      color: colors.background,
      borderColor: isDanger ? palette.danger : Colors.transparent,
      borderWidth: 1.5,
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      semanticLabel: '${severityLabel(l10n, alert.severity)}: ${alert.text}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 32),
        child: Row(
          children: [
            ExcludeSemantics(
              child: ToneChip(
                label: severityLabel(l10n, alert.severity),
                tone: tone,
                icon: iconFor(alert.severity),
                onSurface: true,
              ),
            ),
            const SizedBox(width: RaeedSpacing.md),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  alert.text,
                  style: context.type.bodySmall.copyWith(color: palette.ink),
                ),
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm),
            Icon(
              // Mirrors under RTL, as a "go there" arrow must.
              Icons.arrow_forward_rounded,
              size: 18,
              color: colors.foreground,
            ),
          ],
        ),
      ),
    );
  }

  static ChipTone toneFor(AlertSeverity severity) => switch (severity) {
    AlertSeverity.danger => ChipTone.danger,
    AlertSeverity.warning => ChipTone.warning,
    AlertSeverity.info => ChipTone.info,
  };

  static IconData iconFor(AlertSeverity severity) => switch (severity) {
    AlertSeverity.danger => Icons.priority_high_rounded,
    AlertSeverity.warning => Icons.schedule_rounded,
    AlertSeverity.info => Icons.circle,
  };

  static String severityLabel(AppL10n l10n, AlertSeverity severity) =>
      switch (severity) {
        AlertSeverity.danger => l10n.severityDanger,
        AlertSeverity.warning => l10n.severityWarning,
        AlertSeverity.info => l10n.severityInfo,
      };
}
