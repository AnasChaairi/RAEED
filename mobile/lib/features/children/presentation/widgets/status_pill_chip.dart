import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../application/child_status_pill.dart';
import '../../domain/child_day_status.dart';

/// The one-glance answer to "where is my child and what's next".
///
/// A fresh absence alert overrides everything else into a high-contrast state
/// (`specs/06-mobile-app-spec.md`). That override is not styling for its own
/// sake: `ATT-07` makes an unexplained absence the one safety-critical event in
/// the product, and a parent scanning four child cards has to see it without
/// reading them.
///
/// Colour is never the only signal. The alert state also changes the icon and
/// the label, so it survives a colour-blind reader, a sunlit screen, and a
/// screenshot printed in greyscale.
class StatusPillChip extends StatelessWidget {
  const StatusPillChip({required this.pill, this.onTap, super.key});

  /// The resolved pill, from `resolveStatusPill`.
  final StatusPill pill;

  /// Opens presence confirmation or attendance detail. Null when the status is
  /// not actionable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = _colorsFor(context);
    final label = pill.isAlert ? l10n.absenceAlertTitle : _labelFor(l10n);

    final chip = Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RaeedSpacing.md,
        vertical: RaeedSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(RaeedRadius.pill),
        border: Border.all(color: colors.border, width: pill.isAlert ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(), size: 14, color: colors.foreground),
          const SizedBox(width: RaeedSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: context.type.caption.copyWith(color: colors.foreground),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (pill.isActionable && onTap != null) ...[
            const SizedBox(width: RaeedSpacing.xs),
            Icon(
              // Mirrors under Directionality, as a chevron must in Arabic.
              Icons.chevron_right,
              size: 14,
              color: colors.foreground,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(label: label, child: chip);
    }

    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaeedRadius.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: RaeedTouchTarget.minPx),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: chip,
          ),
        ),
      ),
    );
  }

  String _labelFor(AppL10n l10n) => switch (pill.kind) {
    DayStatusKind.noSession => l10n.childNoSessionToday,
    DayStatusKind.awaitingPresenceAnswer => l10n.statusAwaitingAnswer,
    DayStatusKind.presenceConfirmed => l10n.statusPresenceConfirmed,
    DayStatusKind.presenceDeclined => l10n.statusPresenceDeclined,
    DayStatusKind.presenceLate => l10n.statusPresenceLate,
    DayStatusKind.present => l10n.statusPresent,
    DayStatusKind.late => l10n.statusLate,
    DayStatusKind.absent => l10n.statusAbsent,
    DayStatusKind.excused => l10n.statusExcused,
    DayStatusKind.unknown => l10n.statusUnknown,
  };

  IconData _iconFor() {
    if (pill.isAlert) return Icons.warning_amber_rounded;
    return switch (pill.kind) {
      DayStatusKind.noSession => Icons.event_busy_outlined,
      DayStatusKind.awaitingPresenceAnswer => Icons.help_outline,
      DayStatusKind.presenceConfirmed => Icons.event_available_outlined,
      DayStatusKind.presenceDeclined => Icons.event_busy_outlined,
      DayStatusKind.presenceLate => Icons.schedule_outlined,
      DayStatusKind.present => Icons.check_circle_outline,
      DayStatusKind.late => Icons.schedule_outlined,
      DayStatusKind.absent => Icons.cancel_outlined,
      DayStatusKind.excused => Icons.verified_outlined,
      DayStatusKind.unknown => Icons.remove,
    };
  }

  _PillColors _colorsFor(BuildContext context) {
    final palette = context.palette;
    return switch (pill.tone) {
      StatusPillTone.critical => _PillColors(
        background: palette.surface,
        foreground: palette.danger,
        border: palette.danger,
      ),
      StatusPillTone.attention => _PillColors(
        background: palette.accentSoft,
        foreground: palette.accent,
        border: palette.accent,
      ),
      StatusPillTone.positive => _PillColors(
        background: palette.surfaceAlt,
        foreground: palette.success,
        border: palette.border,
      ),
      StatusPillTone.info => _PillColors(
        background: palette.primarySoft,
        foreground: palette.primary,
        border: palette.border,
      ),
      StatusPillTone.muted || StatusPillTone.neutral => _PillColors(
        background: palette.surfaceAlt,
        foreground: palette.inkDim,
        border: palette.border,
      ),
    };
  }
}

class _PillColors {
  const _PillColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
