import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/attendance_status.dart';

/// The one-tap status control.
///
/// `specs/06-mobile-app-spec.md`: "large one-tap status chips", with the goal
/// of marking a whole group in under a minute. Everything here follows from
/// that: it is `primaryActionsPx` tall rather than the 44px minimum, because it
/// is tapped repeatedly, at speed, often one-handed by someone standing up; and
/// it cycles on tap rather than opening a picker, because a picker turns one
/// gesture into three.
///
/// The status is carried by icon and text as well as colour. A hall is a bad
/// lighting environment, phone screens get sunlight, and some educators are
/// colour-blind — a chip that only differs by hue would be unreadable to all
/// three.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.status,
    required this.onTap,
    this.isPending = false,
    this.onLongPress,
    super.key,
  });

  /// The effective status, or null when the child is unmarked.
  final AttendanceStatus? status;

  /// Advances to the next status.
  final VoidCallback onTap;

  /// Opens the explicit picker, for correcting a mis-tap without cycling all
  /// the way around.
  final VoidCallback? onLongPress;

  /// Whether this mark is queued and has not reached the server.
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final colors = _colorsFor(context);
    final label = statusLabel(l10n, status);

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(RaeedRadius.pill),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: RaeedTouchTarget.primaryActionsPx,
            minWidth: 116,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: RaeedSpacing.lg,
            vertical: RaeedSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(RaeedRadius.pill),
            border: Border.all(color: colors.border, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(), size: 18, color: colors.foreground),
              const SizedBox(width: RaeedSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  style: context.type.button.copyWith(color: colors.foreground),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPending) ...[
                const SizedBox(width: RaeedSpacing.xs),
                // Not an error: the mark is saved on the device and will sync.
                Icon(
                  Icons.schedule_send_outlined,
                  size: 14,
                  color: palette.inkDim,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor() => switch (status) {
    AttendanceStatus.present => Icons.check_circle_outline,
    AttendanceStatus.late => Icons.schedule_outlined,
    AttendanceStatus.absent => Icons.cancel_outlined,
    AttendanceStatus.excused => Icons.verified_outlined,
    null => Icons.radio_button_unchecked,
  };

  _ChipColors _colorsFor(BuildContext context) {
    final palette = context.palette;
    return switch (status) {
      AttendanceStatus.present => _ChipColors(
        background: palette.surfaceAlt,
        foreground: palette.success,
        border: palette.success,
      ),
      AttendanceStatus.late => _ChipColors(
        background: palette.accentSoft,
        foreground: palette.accent,
        border: palette.accent,
      ),
      AttendanceStatus.absent => _ChipColors(
        background: palette.surface,
        foreground: palette.danger,
        border: palette.danger,
      ),
      AttendanceStatus.excused => _ChipColors(
        background: palette.primarySoft,
        foreground: palette.primary,
        border: palette.primary,
      ),
      null => _ChipColors(
        background: palette.surface,
        foreground: palette.inkDim,
        border: palette.border,
      ),
    };
  }
}

/// The localized label for a status, or "not marked" for null.
String statusLabel(AppL10n l10n, AttendanceStatus? status) => switch (status) {
  AttendanceStatus.present => l10n.attendancePresent,
  AttendanceStatus.late => l10n.attendanceLate,
  AttendanceStatus.absent => l10n.attendanceAbsent,
  AttendanceStatus.excused => l10n.attendanceExcused,
  null => l10n.attendanceNotMarked,
};

class _ChipColors {
  const _ChipColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
