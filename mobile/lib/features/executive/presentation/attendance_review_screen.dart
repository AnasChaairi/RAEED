import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../children/presentation/widgets/health_alert_badge.dart';
import '../domain/attendance_review.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/correction_sheet.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/tone_chip.dart';

/// EXEC-M-05 — the executive's attendance review for one session.
///
/// Read-mostly. The one write is a correction, which is a **new** record
/// pointing at the one it supersedes; the row then shows both, with who,
/// when, and the recorded marker. Nothing here edits in place.
class AttendanceReviewScreen extends ConsumerWidget {
  const AttendanceReviewScreen({
    required this.sessionId,
    required this.groupId,
    this.now,
    super.key,
  });

  final String sessionId;
  final String groupId;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final sheet = ref.watch(
      attendanceReviewControllerProvider(sessionId, groupId),
    );

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: sheet.when(
          loading: () => Column(
            children: [
              _Header(sheet: null, onBack: () => _back(context)),
              const Expanded(child: SkeletonCardList(count: 5, height: 60)),
            ],
          ),
          error: (error, _) => Column(
            children: [
              _Header(sheet: null, onBack: () => _back(context)),
              Expanded(
                child: RaeedErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(
                    attendanceReviewControllerProvider(sessionId, groupId),
                  ),
                ),
              ),
            ],
          ),
          data: (data) => Column(
            children: [
              _Header(sheet: data, onBack: () => _back(context)),
              Expanded(
                child: data.isEmpty
                    ? ExecutiveEmptyState(
                        kind: EmptyStateKind.dataProblem,
                        title: AppL10n.of(context).grpRosterEmpty,
                        body: '',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(RaeedSpacing.md + 2),
                        itemCount: data.rows.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: RaeedSpacing.sm),
                        itemBuilder: (_, index) => ReviewRow(
                          row: data.rows[index],
                          now: now ?? DateTime.now(),
                          onCorrect: () =>
                              _correct(context, ref, data.rows[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _back(BuildContext context) => context.canPop()
      ? context.pop()
      : context.go(AppRoutes.groupPath(groupId));

  Future<void> _correct(
    BuildContext context,
    WidgetRef ref,
    AttendanceReviewRow row,
  ) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final draft = await CorrectionSheet.show(context, row: row);
    if (draft == null) return;
    try {
      await ref
          .read(attendanceReviewControllerProvider(sessionId, groupId).notifier)
          .correct(draft);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.corrSavedToast} · ${l10n.recordedShort}'),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.sheet, required this.onBack});

  final AttendanceReviewSheet? sheet;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final loaded = sheet;

    final subtitle = loaded == null
        ? ''
        : [
            dayAndMonth(locale, loaded.startsAt),
            clockTime(locale, loaded.startsAt),
            if (loaded.recordedByName != null && loaded.recordedAt != null)
              l10n.reviewRecordedBy(
                loaded.recordedByName!,
                clockTime(locale, loaded.recordedAt!),
              ),
          ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.sm,
        RaeedSpacing.xs,
        RaeedSpacing.md + 2,
        RaeedSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BackButton(onPressed: onBack),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loaded == null
                          ? ''
                          : l10n.reviewTitle(loaded.groupName ?? ''),
                      style: context.type.h3.copyWith(color: palette.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: palette.inkDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (loaded != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: RaeedSpacing.sm,
                top: RaeedSpacing.sm,
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ToneChip(
                    label: '${loaded.countOf(AttendanceStatus.present)}',
                    tone: ChipTone.success,
                    icon: Icons.check_rounded,
                  ),
                  ToneChip(
                    label: '${loaded.countOf(AttendanceStatus.absent)}',
                    tone: ChipTone.danger,
                    icon: Icons.close_rounded,
                  ),
                  ToneChip(
                    label: '${loaded.countOf(AttendanceStatus.late)}',
                    tone: ChipTone.warning,
                    icon: Icons.schedule_rounded,
                  ),
                  ToneChip(
                    label: '${loaded.countOf(AttendanceStatus.excused)}',
                    tone: ChipTone.info,
                    icon: Icons.contrast_rounded,
                  ),
                  if (loaded.unmarkedCount > 0)
                    ToneChip(
                      label: '${loaded.unmarkedCount}',
                      tone: ChipTone.neutral,
                      icon: Icons.radio_button_unchecked,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One child: current status, the guardian's answer, the correct button,
/// and — once corrected — the trail beneath.
class ReviewRow extends StatelessWidget {
  const ReviewRow({
    required this.row,
    required this.now,
    this.onCorrect,
    super.key,
  });

  final AttendanceReviewRow row;
  final DateTime now;
  final VoidCallback? onCorrect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);

    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      borderColor: row.isCorrected ? palette.info : null,
      borderWidth: 1.5,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md,
        vertical: RaeedSpacing.sm + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(RaeedRadius.lg - 1),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: palette.inkDim,
                  size: 20,
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            row.childName,
                            style: context.type.label.copyWith(
                              color: palette.ink,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (row.hasHealthAlert) ...[
                          const SizedBox(width: 6),
                          const HealthAlertBadge(size: 12),
                        ],
                      ],
                    ),
                    Text(
                      _guardianLine(l10n),
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              statusChip(l10n, row.currentStatus),
              const SizedBox(width: RaeedSpacing.sm),
              Semantics(
                button: true,
                label: '${l10n.reviewCorrect} — ${row.childName}',
                child: Material(
                  color: palette.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RaeedRadius.md),
                    side: BorderSide(color: palette.border),
                  ),
                  child: InkWell(
                    onTap: onCorrect,
                    borderRadius: BorderRadius.circular(RaeedRadius.md),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: palette.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (row.isCorrected) ...[
            const SizedBox(height: RaeedSpacing.sm + 2),
            Divider(color: palette.border),
            const SizedBox(height: RaeedSpacing.sm),
            for (final record in row.records)
              Padding(
                padding: const EdgeInsets.only(bottom: RaeedSpacing.xs),
                child: _TrailLine(record: record, locale: locale),
              ),
          ],
        ],
      ),
    );
  }

  String _guardianLine(AppL10n l10n) => switch (row.presenceAnswer) {
    PresenceAnswerValue.yes => l10n.reviewGuardianConfirmed,
    PresenceAnswerValue.no => l10n.reviewGuardianDeclared,
    PresenceAnswerValue.late => l10n.reviewGuardianLate,
    null => l10n.reviewGuardianNoAnswer,
  };

  /// The chip for a status, or the quiet "not marked" one.
  static Widget statusChip(AppL10n l10n, AttendanceStatus? status) =>
      switch (status) {
        AttendanceStatus.present => ToneChip(
          label: l10n.statusPresent,
          tone: ChipTone.success,
          icon: Icons.check_rounded,
        ),
        AttendanceStatus.absent => ToneChip(
          label: l10n.statusAbsent,
          tone: ChipTone.danger,
          icon: Icons.close_rounded,
        ),
        AttendanceStatus.late => ToneChip(
          label: l10n.statusLate,
          tone: ChipTone.warning,
          icon: Icons.schedule_rounded,
        ),
        AttendanceStatus.excused => ToneChip(
          label: l10n.statusExcused,
          tone: ChipTone.info,
          icon: Icons.contrast_rounded,
        ),
        null => ToneChip(
          label: l10n.attendanceNotMarked,
          tone: ChipTone.neutral,
          icon: Icons.radio_button_unchecked,
        ),
      };

  static String statusLabel(AppL10n l10n, AttendanceStatus status) =>
      switch (status) {
        AttendanceStatus.present => l10n.statusPresent,
        AttendanceStatus.absent => l10n.statusAbsent,
        AttendanceStatus.late => l10n.statusLate,
        AttendanceStatus.excused => l10n.statusExcused,
      };
}

class _TrailLine extends StatelessWidget {
  const _TrailLine({required this.record, required this.locale});

  final AttendanceRecordEntry record;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final color = record.isCorrection ? palette.info : palette.inkDim;
    final status = ReviewRow.statusLabel(l10n, record.status);
    final time = clockTime(locale, record.recordedAt);

    final parts = [
      record.isCorrection
          ? l10n.reviewTrailCorrected(status, record.recordedByName, time)
          : l10n.reviewTrailOriginal(status, record.recordedByName, time),
      if (record.deviceLabel != null) record.deviceLabel!,
      if (record.guardiansNotified) l10n.reviewTrailNotified,
      if (record.correctedFromId != null)
        l10n.reviewTrailRefers(record.correctedFromId!),
      if (record.isCorrection) l10n.recordedShort,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(Icons.circle, size: 6, color: color),
        ),
        const SizedBox(width: RaeedSpacing.sm),
        Expanded(
          child: Text(
            parts.join(' · '),
            style: context.type
                .tabular(context.type.caption)
                .copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
