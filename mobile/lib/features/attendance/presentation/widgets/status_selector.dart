import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/attendance_status.dart';

/// The row's status control: one button per status, as the design draws it.
///
/// `specs/06-mobile-app-spec.md` asks for "large one-tap status chips" with the
/// goal of marking a whole group in under a minute. Discrete buttons are the
/// shorter path to that than the cycling chip the spec's parenthetical
/// describes: present, late and absent are each one tap from any starting
/// state, where cycling costs up to three and makes a mis-tap expensive — you
/// have to go all the way round to undo it.
///
/// Excused is not one of the three. It is not a mark made while walking a hall;
/// it is an excuse accepted afterwards, and it appears as its own segment only
/// once something has set it. Until then it lives behind a long-press, which is
/// also how a mis-tap is corrected without cycling.
///
/// Status is carried by shape and position as well as colour: a hall is a bad
/// lighting environment, phone screens get sunlight, and some educators are
/// colour-blind.
class AttendanceStatusSelector extends StatelessWidget {
  const AttendanceStatusSelector({
    required this.status,
    required this.onSelected,
    this.onPickOther,
    this.isPending = false,
    super.key,
  });

  /// The effective status, or null when the child is unmarked.
  final AttendanceStatus? status;

  /// Marks the child with one of the three fast statuses.
  final ValueChanged<AttendanceStatus> onSelected;

  /// Opens the explicit picker — the only route to "excused".
  final VoidCallback? onPickOther;

  /// Whether this mark is queued and has not reached the server.
  final bool isPending;

  /// The statuses that earn a permanent button.
  static const List<AttendanceStatus> fastStatuses = [
    AttendanceStatus.present,
    AttendanceStatus.late,
    AttendanceStatus.absent,
  ];

  /// Roughly what [build] occupies, for callers budgeting a row around it.
  static double widthFor(AttendanceStatus? status, double scale) {
    final segments = fastStatuses.contains(status) || status == null ? 3 : 4;
    return segments * RaeedTouchTarget.primaryActionsPx * scale +
        (segments - 1) * RaeedSpacing.xs;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final shown = [
      ...fastStatuses,
      // Only ever shown once something set it; never offered as a fourth tap.
      if (status != null && !fastStatuses.contains(status)) status!,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final candidate in shown) ...[
          if (candidate != shown.first) const SizedBox(width: RaeedSpacing.xs),
          _Segment(
            status: candidate,
            label: statusLabel(l10n, candidate),
            isSelected: status == candidate,
            isPending: isPending && status == candidate,
            onTap: fastStatuses.contains(candidate)
                ? () => onSelected(candidate)
                : onPickOther,
            onLongPress: onPickOther,
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.status,
    required this.label,
    required this.isSelected,
    required this.isPending,
    this.onTap,
    this.onLongPress,
  });

  final AttendanceStatus status;
  final String label;
  final bool isSelected;
  final bool isPending;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = _toneFor(context, status);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(RaeedRadius.md),
        child: Container(
          // Square and full-height: tapped repeatedly, at speed, often
          // one-handed by someone standing up.
          width: RaeedTouchTarget.primaryActionsPx,
          height: RaeedTouchTarget.primaryActionsPx,
          decoration: BoxDecoration(
            color: isSelected ? tone.fill : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(RaeedRadius.md),
            border: Border.all(
              color: isSelected ? tone.fill : palette.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                iconForStatus(status),
                size: 20,
                color: isSelected ? tone.on : palette.inkDim,
              ),
              if (isPending)
                PositionedDirectional(
                  bottom: 3,
                  end: 3,
                  // Not an error: the mark is saved on the device and will
                  // sync. A queued mark that looked like a failure would get
                  // re-tapped.
                  child: Icon(
                    Icons.schedule_send_outlined,
                    size: 11,
                    color: tone.on,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _SegmentTone _toneFor(BuildContext context, AttendanceStatus status) {
    final palette = context.palette;
    return switch (status) {
      AttendanceStatus.present => _SegmentTone(
        fill: palette.success,
        on: palette.primaryOn,
      ),
      AttendanceStatus.late => _SegmentTone(
        fill: palette.accent,
        on: palette.primaryOn,
      ),
      AttendanceStatus.absent => _SegmentTone(
        fill: palette.danger,
        on: palette.primaryOn,
      ),
      AttendanceStatus.excused => _SegmentTone(
        fill: palette.primary,
        on: palette.primaryOn,
      ),
    };
  }
}

class _SegmentTone {
  const _SegmentTone({required this.fill, required this.on});

  final Color fill;
  final Color on;
}

/// The glyph for a status — the non-colour half of the signal.
IconData iconForStatus(AttendanceStatus? status) => switch (status) {
  AttendanceStatus.present => Icons.check_rounded,
  AttendanceStatus.late => Icons.schedule_rounded,
  AttendanceStatus.absent => Icons.close_rounded,
  AttendanceStatus.excused => Icons.verified_outlined,
  null => Icons.radio_button_unchecked,
};

/// The localized label for a status, or "not marked" for null.
String statusLabel(AppL10n l10n, AttendanceStatus? status) => switch (status) {
  AttendanceStatus.present => l10n.attendancePresent,
  AttendanceStatus.late => l10n.attendanceLate,
  AttendanceStatus.absent => l10n.attendanceAbsent,
  AttendanceStatus.excused => l10n.attendanceExcused,
  null => l10n.attendanceNotMarked,
};
