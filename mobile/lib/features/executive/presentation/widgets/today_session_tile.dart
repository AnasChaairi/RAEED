import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../application/session_attendance_state.dart';
import '../../domain/dashboard_overview.dart';
import '../relative_time.dart';
import 'executive_card.dart';
import 'tone_chip.dart';

/// One of today's sessions: time, group · title, educator, attendance chip.
class TodaySessionTile extends StatelessWidget {
  const TodaySessionTile({
    required this.session,
    required this.now,
    this.onTap,
    super.key,
  });

  final TodaySession session;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final state = sessionAttendanceStateAt(session, now);
    final title = session.title == null
        ? session.groupName
        : '${session.groupName} · ${session.title}';

    return ExecutiveCard(
      onTap: onTap,
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                clockTime(locale, session.startsAt),
                style: context.type
                    .tabular(context.type.label)
                    .copyWith(
                      color: palette.inkDim,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.type.label.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (session.educatorName != null)
                    Text(
                      session.educatorName!,
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm),
            attendanceChip(l10n, state),
          ],
        ),
      ),
    );
  }

  /// The chip for [state] — shared with the group detail's session rows.
  static Widget attendanceChip(AppL10n l10n, SessionAttendanceState state) =>
      switch (state) {
        SessionAttendanceState.recorded => ToneChip(
          label: l10n.sessionAttendanceRecorded,
          tone: ChipTone.success,
          icon: Icons.check_rounded,
        ),
        SessionAttendanceState.notRecorded => ToneChip(
          label: l10n.sessionAttendanceNotRecorded,
          tone: ChipTone.danger,
          icon: Icons.priority_high_rounded,
        ),
        SessionAttendanceState.live => ToneChip(
          label: l10n.sessionAttendanceLive,
          tone: ChipTone.info,
          icon: Icons.circle,
        ),
        SessionAttendanceState.upcoming => ToneChip(
          label: l10n.sessionAttendanceUpcoming,
          tone: ChipTone.neutral,
          icon: Icons.radio_button_unchecked,
        ),
      };
}
