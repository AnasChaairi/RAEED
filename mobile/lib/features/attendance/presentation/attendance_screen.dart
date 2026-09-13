import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../children/presentation/widgets/health_alert_badge.dart';
import '../domain/attendance_sheet.dart';
import '../domain/attendance_status.dart';
import 'attendance_providers.dart';
import 'widgets/status_chip.dart';

/// Attendance marking (`RAEED-21`).
///
/// The screen spec's goal is the design constraint: "Mark a whole group in
/// under a minute, offline-capable." Every decision here serves that —
/// one-tap chips sized for repeated taps, a summary header that does not shift
/// as counts change, a bulk action for the common ending, and an offline path
/// that never blocks submission.
///
/// The offline banner is worded as reassurance, not as an error. Marking a
/// group in a hall with no signal is a supported flow, and telling an educator
/// something went wrong when nothing did would push them to re-mark children
/// who are already recorded.
class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({
    required this.sessionId,
    required this.groupId,
    super.key,
  });

  /// The session being marked.
  final String sessionId;

  /// The group it belongs to.
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final sheet = ref.watch(
      attendanceSheetControllerProvider(sessionId, groupId),
    );

    return Scaffold(
      backgroundColor: context.palette.bg,
      appBar: AppBar(title: Text(l10n.attendanceTitle)),
      body: SafeArea(
        child: sheet.when(
          loading: () => const _SheetSkeleton(),
          error: (error, _) => RaeedErrorView(
            error: error,
            onRetry: () => ref.invalidate(
              attendanceSheetControllerProvider(sessionId, groupId),
            ),
          ),
          data: (data) =>
              _SheetBody(sheet: data, sessionId: sessionId, groupId: groupId),
        ),
      ),
    );
  }
}

class _SheetBody extends ConsumerWidget {
  const _SheetBody({
    required this.sheet,
    required this.sessionId,
    required this.groupId,
  });

  final AttendanceSheet sheet;
  final String sessionId;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final controller = ref.read(
      attendanceSheetControllerProvider(sessionId, groupId).notifier,
    );
    final pendingCount = ref.watch(pendingWriteCountProvider).value ?? 0;

    if (sheet.isEmpty) {
      return _EmptyGroup(message: l10n.attendanceEmptyGroup);
    }

    return Column(
      children: [
        _SummaryHeader(sheet: sheet),
        if (sheet.isFromCache || pendingCount > 0)
          OfflineBanner(
            reason: StaleDataReason.offline,
            // Reassurance, not an error — and submission stays enabled below.
            messageOverride: l10n.attendanceOfflineSaved,
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(RaeedSpacing.lg),
            itemCount: sheet.entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: RaeedSpacing.sm),
            itemBuilder: (context, index) {
              final entry = sheet.entries[index];
              return _AttendanceRow(
                entry: entry,
                onCycle: () => controller.cycle(entry),
                onPick: () => _pickStatus(context, controller, entry),
                onResolveConflict: () =>
                    _resolveConflict(context, controller, entry),
              );
            },
          ),
        ),
        _ActionBar(
          sheet: sheet,
          pendingCount: pendingCount,
          onMarkRemaining: controller.markRemainingPresent,
          onSubmit: () => _submit(context, controller),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    AttendanceSheetController controller,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    final outcome = await controller.submit();
    if (!context.mounted) return;

    // A conflict is not a snackbar. The educator has a decision to make about
    // a specific child, and a message that slides away in four seconds is the
    // wrong place for it — the row itself carries it until they act.
    if (outcome.unknownChildIds.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.attendanceUnknownChild)),
      );
      return;
    }
    if (!outcome.needsAttention) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            outcome.wasOffline
                ? l10n.attendanceOfflineSaved
                : l10n.attendanceSubmitted,
          ),
        ),
      );
    }
  }

  Future<void> _pickStatus(
    BuildContext context,
    AttendanceSheetController controller,
    AttendanceEntry entry,
  ) async {
    final l10n = AppL10n.of(context);
    final picked = await showModalBottomSheet<AttendanceStatus>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final status in AttendanceStatus.values)
              ListTile(
                title: Text(statusLabel(l10n, status)),
                onTap: () => Navigator.of(sheetContext).pop(status),
              ),
          ],
        ),
      ),
    );
    if (picked != null) await controller.setStatus(entry, picked);
  }

  Future<void> _resolveConflict(
    BuildContext context,
    AttendanceSheetController controller,
    AttendanceEntry entry,
  ) async {
    final conflict = entry.conflict;
    if (conflict == null) return;
    final l10n = AppL10n.of(context);

    final keepMine = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.attendanceConflictTitle),
        content: Text(
          l10n.attendanceConflictBody(
            statusLabel(l10n, conflict.attemptedStatus),
            statusLabel(l10n, conflict.serverStatus),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.attendanceConflictKeepServer),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.attendanceConflictKeepMine),
          ),
        ],
      ),
    );

    if (keepMine == null) return;
    await (keepMine
        ? controller.keepLocalMark(entry.childId)
        : controller.keepServerRecord(entry.childId));
  }
}

/// The live confirmed / absent / no-answer counts.
///
/// Set in tabular figures so the numbers do not shift the layout as they
/// change — on this screen they change on every tap, and a header that jitters
/// under the reader's eye is the fastest way to lose their place in a list of
/// twenty children.
class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.sheet});

  final AttendanceSheet sheet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final style = context.type.tabular(context.type.caption);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.lg,
        vertical: RaeedSpacing.md,
      ),
      color: palette.surface,
      child: Wrap(
        spacing: RaeedSpacing.lg,
        runSpacing: RaeedSpacing.xs,
        children: [
          Text(
            l10n.attendanceSummaryConfirmed(sheet.confirmedCount),
            style: style.copyWith(color: palette.success),
          ),
          Text(
            l10n.attendanceSummaryAbsent(sheet.declaredAbsentCount),
            style: style.copyWith(color: palette.danger),
          ),
          Text(
            l10n.attendanceSummaryNoAnswer(sheet.noAnswerCount),
            style: style.copyWith(color: palette.inkDim),
          ),
        ],
      ),
    );
  }
}

/// One child: name, health badge, status chip.
class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.entry,
    required this.onCycle,
    required this.onPick,
    required this.onResolveConflict,
  });

  final AttendanceEntry entry;
  final VoidCallback onCycle;
  final VoidCallback onPick;
  final VoidCallback onResolveConflict;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        side: BorderSide(
          color: entry.hasConflict ? palette.warning : palette.border,
          width: entry.hasConflict ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RaeedSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.childName,
                          style: context.type.body.copyWith(color: palette.ink),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (entry.hasHealthAlert) ...[
                        const SizedBox(width: RaeedSpacing.xs),
                        // Icon only here too: an attendance list is read in a
                        // classroom with parents at the door.
                        const HealthAlertBadge(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: RaeedSpacing.md),
                StatusChip(
                  status: entry.effectiveStatus,
                  isPending: entry.isPending,
                  onTap: onCycle,
                  onLongPress: onPick,
                ),
              ],
            ),
            if (entry.hasConflict) ...[
              const SizedBox(height: RaeedSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: onResolveConflict,
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: palette.warning,
                  ),
                  label: Text(
                    l10n.attendanceConflictTitle,
                    style: context.type.caption.copyWith(
                      color: palette.warning,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Mark remaining present" and submit.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.sheet,
    required this.pendingCount,
    required this.onMarkRemaining,
    required this.onSubmit,
  });

  final AttendanceSheet sheet;
  final int pendingCount;
  final Future<void> Function() onMarkRemaining;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final hasUnmarked = sheet.entries.any((entry) => entry.isUnmarked);

    return Container(
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: RaeedSpacing.sm),
              child: Text(
                l10n.attendancePendingCount(pendingCount),
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(color: palette.inkDim),
              ),
            ),
          if (hasUnmarked)
            OutlinedButton(
              onPressed: () => onMarkRemaining(),
              child: Text(l10n.attendanceMarkRemainingPresent),
            ),
          if (hasUnmarked) const SizedBox(height: RaeedSpacing.sm),
          FilledButton(
            // Never disabled by being offline. The screen spec is explicit
            // that the offline state "never blocks submission" — submitting
            // queues, and queueing is the whole design.
            onPressed: onSubmit,
            child: Text(l10n.attendanceSubmit),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroup extends StatelessWidget {
  const _EmptyGroup({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(RaeedSpacing.xl2),
      child: Text(
        message,
        style: context.type.body.copyWith(color: context.palette.inkDim),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _SheetSkeleton extends StatelessWidget {
  const _SheetSkeleton();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(RaeedSpacing.lg),
    itemCount: 6,
    separatorBuilder: (_, _) => const SizedBox(height: RaeedSpacing.sm),
    itemBuilder: (_, _) => Row(
      children: [
        const Expanded(child: SkeletonLine(widthFactor: 0.6, height: 16)),
        const SizedBox(width: RaeedSpacing.md),
        SkeletonBox(
          width: 116,
          height: RaeedTouchTarget.primaryActionsPx,
          borderRadius: BorderRadius.circular(RaeedRadius.pill),
        ),
      ],
    ),
  );
}
