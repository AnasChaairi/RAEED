import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/l10n/hijri_date.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../../executive/presentation/widgets/tone_chip.dart';
import '../domain/educator_session.dart';
import 'educator_providers.dart';
import 'widgets/cancel_session_sheet.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-04 — one session: content, materials, homework, the two actions,
/// and the way to cancel or move it.
class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({required this.sessionId, this.now, super.key});

  final String sessionId;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final detail = ref.watch(sessionDetailProvider(sessionId));

    return Scaffold(
      backgroundColor: palette.bg,
      body: detail.when(
        loading: () => Column(
          children: [
            _Header(detail: null, onBack: () => _back(context)),
            const Expanded(child: SkeletonCardList(count: 3, height: 110)),
          ],
        ),
        error: (error, _) => Column(
          children: [
            _Header(detail: null, onBack: () => _back(context)),
            Expanded(
              child: RaeedErrorView(
                error: error,
                onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
              ),
            ),
          ],
        ),
        data: (data) => Column(
          children: [
            _Header(detail: data, onBack: () => _back(context)),
            Expanded(
              child: _Body(detail: data, now: now ?? DateTime.now()),
            ),
          ],
        ),
      ),
    );
  }

  static void _back(BuildContext context) => context.canPop()
      ? context.pop()
      : context.go(AppRoutes.homeTabPath('sessions'));
}

class _Header extends StatelessWidget {
  const _Header({required this.detail, required this.onBack});

  final SessionDetail? detail;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final on = palette.primaryOn;
    final item = detail?.item;
    final cancelled = item?.isCancelled ?? false;

    return BrandGradient(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(RaeedRadius.xl2),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.sm,
            RaeedSpacing.xs,
            RaeedSpacing.md,
            RaeedSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  BackButton(color: on, onPressed: onBack),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item == null
                              ? ''
                              : [
                                  item.group.name,
                                  if (item.theme != null) item.theme!,
                                ].join(' · '),
                          style: context.type.caption.copyWith(
                            color: on.withValues(alpha: 0.75),
                          ),
                        ),
                        Text(
                          item?.title ?? item?.group.name ?? '',
                          style: context.type.h3.copyWith(
                            color: on,
                            decoration: cancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item != null && !cancelled)
                    Semantics(
                      button: true,
                      label: l10n.sessEdit,
                      child: Material(
                        color: on.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(RaeedRadius.lg),
                        child: InkWell(
                          onTap: () =>
                              context.push(AppRoutes.sessionEditPath(item.id)),
                          borderRadius: BorderRadius.circular(RaeedRadius.lg),
                          child: SizedBox(
                            width: RaeedTouchTarget.minPx,
                            height: RaeedTouchTarget.minPx,
                            child: Icon(
                              Icons.edit_outlined,
                              color: on,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (item != null) ...[
                const SizedBox(height: RaeedSpacing.sm + 2),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RaeedSpacing.sm,
                  ),
                  child: Wrap(
                    spacing: RaeedSpacing.sm,
                    runSpacing: RaeedSpacing.xs,
                    children: [
                      _HeaderPill(
                        '${dayAndMonth(locale, item.startsAt)} · ${HijriDate.fromGregorian(item.startsAt.toLocal()).format(locale.languageCode)}',
                      ),
                      _HeaderPill(
                        '${clockTime(locale, item.startsAt)}–${clockTime(locale, item.endsAt)}',
                      ),
                      if (item.place != null) _HeaderPill(item.place!),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final on = context.palette.primaryOn;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: on.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(RaeedRadius.pill),
      ),
      child: Text(
        text,
        style: context.type.tabular(context.type.caption).copyWith(color: on),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.detail, required this.now});

  final SessionDetail detail;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final item = detail.item;
    final cancelled = item.isCancelled;
    final objectives = detail.objectives?.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.md,
        RaeedSpacing.lg,
        RaeedSpacing.xl2,
      ),
      children: [
        if (cancelled || item.rescheduledFrom != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.md + 2,
              vertical: RaeedSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: cancelled ? palette.dangerSoft : palette.warningSoft,
              borderRadius: BorderRadius.circular(RaeedRadius.lg),
            ),
            child: Text(
              cancelled
                  ? l10n.sessCancelledBanner
                  : l10n.sessMovedBanner(
                      '${dayAndMonth(locale, item.startsAt)} ${clockTime(locale, item.startsAt)}',
                    ),
              style: context.type.caption.copyWith(
                color: cancelled ? palette.danger : palette.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm + 2),
        ],
        _Section(
          title: l10n.sessObjectives,
          child: Text(
            objectives == null || objectives.isEmpty
                ? l10n.sessNoObjectives
                : objectives
                      .split('\n')
                      .map((line) => line.startsWith('•') ? line : '• $line')
                      .join('\n'),
            style: context.type.bodySmall.copyWith(
              color: objectives == null || objectives.isEmpty
                  ? palette.inkDim
                  : palette.ink,
              height: 1.9,
            ),
          ),
        ),
        const SizedBox(height: RaeedSpacing.sm + 2),
        _Section(
          title: l10n.sessMaterials,
          trailing: Text(
            '${detail.materials.length}',
            style: context.type
                .tabular(context.type.caption)
                .copyWith(color: palette.inkDim),
          ),
          child: detail.materials.isEmpty
              ? Text(
                  l10n.sessNoMaterials,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                )
              : Column(
                  children: [
                    for (final material in detail.materials)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: RaeedSpacing.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: palette.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            MaterialKindTile(kind: material.kind),
                            const SizedBox(width: RaeedSpacing.sm + 2),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material.title ??
                                        material.storageKey.split('/').last,
                                    style: context.type.label.copyWith(
                                      color: palette.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (material.sizeBytes != null)
                                    Text(
                                      _size(material.sizeBytes!),
                                      style: context.type
                                          .tabular(context.type.caption)
                                          .copyWith(color: palette.inkDim),
                                    ),
                                ],
                              ),
                            ),
                            ToneChip(
                              label: visibilityLabel(l10n, material.visibility),
                              tone: visibilityTone(material.visibility),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: RaeedSpacing.sm + 2),
        _Section(
          title: l10n.sessHomework,
          trailing: cancelled
              ? null
              : TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(0, 32)),
                  onPressed: () =>
                      context.push(AppRoutes.sessionHomeworkNewPath(item.id)),
                  child: Text(l10n.sessAddHomework),
                ),
          child: detail.homework.isEmpty
              ? Text(
                  l10n.sessNoHomework,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final homework in detail.homework) ...[
                      Text(
                        homework.title ?? homework.instructions,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.sessHomeworkMeta(
                          homework.isWholeGroup
                              ? l10n.sessWholeGroup
                              : l10n.hwTargetChildren(homework.targetCount),
                          dayAndMonth(locale, homework.dueAt),
                          homework.doneCount,
                          homework.targetCount,
                        ),
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: homework.doneShare,
                          minHeight: 6,
                          backgroundColor: palette.surfaceAlt,
                          color: palette.primary,
                        ),
                      ),
                      if (homework != detail.homework.last)
                        const SizedBox(height: RaeedSpacing.sm + 2),
                    ],
                  ],
                ),
        ),
        if (!cancelled) ...[
          const SizedBox(height: RaeedSpacing.sm + 2),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => context.push(
                    AppRoutes.attendancePath(item.group.id, item.id),
                  ),
                  child: Text(
                    item.attendanceRecorded
                        ? l10n.sessAttendanceDone
                        : l10n.todayRecordAttendance,
                  ),
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: palette.surface,
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.sessionSummaryPath(item.id)),
                  child: Text(
                    item.summarySent
                        ? l10n.sessSummaryDone
                        : l10n.sessSummaryCta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
              foregroundColor: palette.danger,
            ),
            onPressed: () => CancelSessionSheet.show(context, ref, detail),
            child: Text(l10n.sessCancelCta),
          ),
        ],
      ],
    );
  }

  static String _size(int bytes) => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).round()} KB';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ExecutiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.type.caption.copyWith(
                    color: palette.inkDim,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: RaeedSpacing.xs),
          child,
        ],
      ),
    );
  }
}
