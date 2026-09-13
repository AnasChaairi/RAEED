import 'package:cached_network_image/cached_network_image.dart';
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
import 'widgets/status_selector.dart';

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
        _MarkingHeader(sheet: sheet),
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
                onSelect: (status) => controller.setStatus(entry, status),
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

/// The design's marking header: how far through the group you are, then the
/// live confirmed / absent / no-answer counts.
///
/// The bar carries one segment per child, coloured by that child's status, so
/// the educator can see at a glance both how much is left and what they have
/// been marking — a plain percentage would answer only the first.
///
/// The counts are set in tabular figures so the numbers do not shift the layout
/// as they change. On this screen they change on every tap, and a header that
/// jitters under the reader's eye is the fastest way to lose their place in a
/// list of twenty children.
class _MarkingHeader extends StatelessWidget {
  const _MarkingHeader({required this.sheet});

  final AttendanceSheet sheet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final style = context.type.tabular(context.type.caption);
    final marked = sheet.entries.where((entry) => !entry.isUnmarked).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.md,
        RaeedSpacing.lg,
        RaeedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.attendanceMarkedOf(marked, sheet.entries.length),
                  style: context.type
                      .tabular(context.type.label)
                      .copyWith(color: palette.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          _ProgressSegments(sheet: sheet),
          const SizedBox(height: RaeedSpacing.md),
          Wrap(
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
        ],
      ),
    );
  }
}

/// One segment per child, in list order, coloured by status.
class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments({required this.sheet});

  final AttendanceSheet sheet;

  /// Below the smallest spacing token: at twenty children a 4px gap would be
  /// wider than the segments it separates.
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      // The bar is decoration over information the counts below already carry
      // in words; announcing twenty segments would be noise.
      excludeSemantics: true,
      child: SizedBox(
        height: 6,
        child: Row(
          children: [
            for (final entry in sheet.entries) ...[
              if (entry != sheet.entries.first) const SizedBox(width: _gap),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: switch (entry.effectiveStatus) {
                      AttendanceStatus.present => palette.success,
                      AttendanceStatus.late => palette.accent,
                      AttendanceStatus.absent => palette.danger,
                      AttendanceStatus.excused => palette.primary,
                      null => palette.surfaceAlt,
                    },
                    borderRadius: BorderRadius.circular(RaeedRadius.sm),
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

/// One child: avatar, name, health badge, status buttons.
class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.entry,
    required this.onSelect,
    required this.onPick,
    required this.onResolveConflict,
  });

  final AttendanceEntry entry;
  final ValueChanged<AttendanceStatus> onSelect;
  final VoidCallback onPick;
  final VoidCallback onResolveConflict;

  /// What the name needs before the buttons may share its line.
  static const double _minNameWidth = 72;

  /// Body size, used only to read the user's scaling out of the text scaler.
  static const double _referenceFontSize = 14;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    final selector = AttendanceStatusSelector(
      status: entry.effectiveStatus,
      isPending: entry.isPending,
      onSelected: onSelect,
      onPickOther: onPick,
    );

    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaeedRadius.xl),
        side: BorderSide(
          color: entry.hasConflict ? palette.warning : palette.border,
          width: entry.hasConflict ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RaeedSpacing.md),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final scale =
                    MediaQuery.textScalerOf(context).scale(_referenceFontSize) /
                    _referenceFontSize;
                final name = Row(
                  children: [
                    _RowAvatar(entry: entry),
                    const SizedBox(width: RaeedSpacing.sm),
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
                );

                // The buttons never shrink and never ellipsize — they are the
                // whole screen. When the name can no longer hold its floor
                // beside them, they take their own line instead.
                final budget =
                    constraints.maxWidth -
                    AttendanceStatusSelector.widthFor(
                      entry.effectiveStatus,
                      scale,
                    ) -
                    RaeedSpacing.md;
                if (budget >= _minNameWidth * scale) {
                  return Row(
                    children: [
                      Expanded(child: name),
                      const SizedBox(width: RaeedSpacing.md),
                      selector,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name,
                    const SizedBox(height: RaeedSpacing.sm),
                    selector,
                  ],
                );
              },
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

/// The child's photo, or their initial when there is none.
///
/// Smaller than the parent home's avatar: an educator marking twenty children
/// is scanning names down a column, and a row that is taller than the control
/// it carries costs them a screenful.
class _RowAvatar extends StatelessWidget {
  const _RowAvatar({required this.entry});

  final AttendanceEntry entry;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final photoUrl = entry.photoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(RaeedRadius.md),
      child: SizedBox(
        width: _size,
        height: _size,
        child: photoUrl == null || photoUrl.isEmpty
            ? _InitialAvatar(name: entry.childName)
            : CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                // Photos are served behind short-lived signed URLs, so a failed
                // load is normal once one expires.
                placeholder: (_, _) => ColoredBox(color: palette.surfaceAlt),
                errorWidget: (_, _, _) => _InitialAvatar(name: entry.childName),
              ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final initial = name.trim().isEmpty ? '؟' : name.trim().characters.first;

    return ColoredBox(
      color: palette.primarySoft,
      child: Center(
        child: Text(
          initial,
          style: context.type.h3.copyWith(color: palette.primary),
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
        SkeletonBox(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(RaeedRadius.md),
        ),
        const SizedBox(width: RaeedSpacing.sm),
        const Expanded(child: SkeletonLine(widthFactor: 0.6, height: 16)),
        const SizedBox(width: RaeedSpacing.md),
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) const SizedBox(width: RaeedSpacing.xs),
          SkeletonBox(
            width: RaeedTouchTarget.primaryActionsPx,
            height: RaeedTouchTarget.primaryActionsPx,
            borderRadius: BorderRadius.circular(RaeedRadius.md),
          ),
        ],
      ],
    ),
  );
}
