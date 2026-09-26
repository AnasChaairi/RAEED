import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/l10n/hijri_date.dart';
import '../../../core/network/connectivity_monitor.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_empty_state.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../../executive/presentation/widgets/tone_chip.dart';
import '../domain/educator_session.dart';
import 'educator_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-01 — Today.
class TodayTab extends ConsumerWidget {
  const TodayTab({this.now, super.key});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final today = ref.watch(todayControllerProvider);
    final displayName = ref.watch(
      sessionControllerProvider.select((s) => s.user?.displayName ?? ''),
    );
    final offline = !ref.watch(connectivityStateProvider).isOnline;
    final at = now ?? DateTime.now();

    return Column(
      children: [
        _TodayHeader(displayName: displayName, now: at),
        if (offline)
          Container(
            width: double.infinity,
            color: palette.warningSoft,
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.xl,
              vertical: 5,
            ),
            child: Text(
              l10n.offlineAttendanceBanner,
              style: context.type.caption.copyWith(
                color: palette.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: today.when(
            loading: () => const SkeletonCardList(height: 110),
            error: (error, _) => RaeedErrorView(
              error: error,
              onRetry: () =>
                  ref.read(todayControllerProvider.notifier).refresh(),
            ),
            data: (view) => RefreshIndicator(
              onRefresh: () =>
                  ref.read(todayControllerProvider.notifier).refresh(),
              child: _TodayBody(view: view, now: at),
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.displayName, required this.now});

  final String displayName;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final on = palette.primaryOn;
    final greeting = now.hour < 12
        ? l10n.eduGreetingMorning
        : l10n.eduGreetingEvening;
    final hijri = HijriDate.fromGregorian(now).format(locale.languageCode);

    return BrandGradient(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(RaeedRadius.xl2),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.xl,
            RaeedSpacing.sm,
            RaeedSpacing.xl,
            RaeedSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: context.type.bodySmall.copyWith(
                            color: on.withValues(alpha: 0.72),
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: displayName.split(' ').first,
                                style: context.type.h2.copyWith(color: on),
                              ),
                              TextSpan(
                                text: ' · ${l10n.roleEducator}',
                                style: context.type.label.copyWith(
                                  color: palette.accentDecorative,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.notifications_none_rounded,
                    label: l10n.notifTitle,
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                  const SizedBox(width: RaeedSpacing.sm),
                  _HeaderButton(
                    icon: Icons.more_horiz_rounded,
                    label: l10n.execMore,
                    onTap: () => context.push(AppRoutes.more),
                  ),
                ],
              ),
              const SizedBox(height: RaeedSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dayAndMonth(locale, now),
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: on),
                    ),
                  ),
                  Text(
                    hijri,
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(
                          color: palette.accentDecorative,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = context.palette.primaryOn;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: on.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.lg),
          child: SizedBox(
            width: RaeedTouchTarget.minPx,
            height: RaeedTouchTarget.minPx,
            child: Icon(icon, color: on),
          ),
        ),
      ),
    );
  }
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody({required this.view, required this.now});

  final TodayView view;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final next = view.nextSession;
    final notice = view.pinnedNotice;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.md,
        RaeedSpacing.lg,
        RaeedSpacing.xl2,
      ),
      children: [
        if (next == null)
          ExecutiveEmptyState(
            kind: EmptyStateKind.reassuring,
            title: l10n.todayNoSession,
            body: l10n.todayNoSessionsAtAll,
          )
        else if (next.attendance.recorded)
          _AttendanceDoneCard(next: next)
        else
          NextSessionCard(next: next, now: now),
        for (final session in view.sessionsWithoutContent) ...[
          const SizedBox(height: RaeedSpacing.sm + 2),
          _NoContentNudge(session: session),
        ],
        const SizedBox(height: RaeedSpacing.sm + 2),
        Row(
          children: [
            Expanded(
              child: _Shortcut(
                icon: Icons.edit_note_rounded,
                background: palette.primarySoft,
                foreground: palette.primary,
                label: l10n.shortcutHomework,
                onTap: next == null
                    ? null
                    : () => context.push(
                        AppRoutes.sessionHomeworkNewPath(next.item.id),
                      ),
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm),
            Expanded(
              child: _Shortcut(
                icon: Icons.photo_camera_outlined,
                background: palette.accentSoft,
                foreground: palette.accent,
                label: l10n.shortcutMemory,
                onTap: () => context.push(AppRoutes.memoriesCompose),
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm),
            Expanded(
              child: _Shortcut(
                icon: Icons.campaign_outlined,
                background: palette.infoSoft,
                foreground: palette.info,
                label: l10n.shortcutAnnouncement,
                onTap: () => context.push(AppRoutes.announcementCompose),
              ),
            ),
          ],
        ),
        const SizedBox(height: RaeedSpacing.md),
        Text(
          l10n.homeTodaySessions,
          style: context.type.label.copyWith(
            color: palette.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: RaeedSpacing.sm),
        if (view.todaySessions.isEmpty)
          Text(
            next == null
                ? l10n.todayNoSession
                : l10n.todayNextOn(dayAndMonth(locale, next.item.startsAt)),
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        for (final session in view.todaySessions) ...[
          SessionRow(item: session, now: now),
          const SizedBox(height: RaeedSpacing.sm),
        ],
        if (notice != null) ...[
          const SizedBox(height: RaeedSpacing.sm),
          Text(
            l10n.todayFromManagement,
            style: context.type.label.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          ExecutiveCard(
            radius: RaeedRadius.lg + 2,
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.md + 2,
              vertical: RaeedSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ToneChip(label: l10n.annPinned, tone: ChipTone.primary),
                  ],
                ),
                if (notice.body != null)
                  Text(
                    notice.body!,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                if (notice.ackRequired) ...[
                  const SizedBox(height: RaeedSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        foregroundColor: notice.confirmed
                            ? palette.success
                            : palette.primary,
                        backgroundColor: notice.confirmed
                            ? palette.successSoft
                            : null,
                        side: BorderSide(
                          color: notice.confirmed
                              ? palette.success
                              : palette.border,
                        ),
                      ),
                      onPressed: notice.confirmed
                          ? null
                          : () => ref
                                .read(todayControllerProvider.notifier)
                                .confirmRead(),
                      child: Text(
                        notice.confirmed ? l10n.todayAckDone : l10n.todayAckCta,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The next session with the guardians' answers and the way to attendance.
class NextSessionCard extends StatelessWidget {
  const NextSessionCard({required this.next, required this.now, super.key});

  final NextSession next;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final item = next.item;
    final minutes = item.startsAt.difference(now).inMinutes;
    final chip = item.startsAt.isAfter(now)
        ? '${l10n.todayNextSession} · ${l10n.todayInMinutes(minutes.clamp(0, 1 << 30))}'
        : '${l10n.todayNextSession} · ${l10n.todayLive}';
    final tallies = next.presence ?? PresenceTallies.empty;

    return ExecutiveCard(
      borderColor: palette.primary,
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ToneChip(label: chip, tone: ChipTone.primary),
              ),
              Text(
                clockTime(locale, item.startsAt),
                style: context.type
                    .tabular(context.type.label)
                    .copyWith(color: palette.ink, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          Text(
            item.title ?? item.group.name,
            style: context.type.h3.copyWith(color: palette.ink),
          ),
          Text(
            [
              item.group.name,
              if (item.place != null) item.place!,
              l10n.childrenCount(next.enrolledCount),
            ].join(' · '),
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
          const SizedBox(height: RaeedSpacing.md),
          Semantics(
            button: true,
            label: l10n.presTitle,
            child: InkWell(
              onTap: () => context.push(AppRoutes.sessionPresencePath(item.id)),
              borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
              child: Row(
                children: [
                  _Tally(
                    count: tallies.yes,
                    label: l10n.presTallyYes,
                    tone: ChipTone.success,
                  ),
                  const SizedBox(width: 6),
                  _Tally(
                    count: tallies.late,
                    label: l10n.presTallyLate,
                    tone: ChipTone.warning,
                  ),
                  const SizedBox(width: 6),
                  _Tally(
                    count: tallies.no,
                    label: l10n.presTallyNo,
                    tone: ChipTone.info,
                  ),
                  const SizedBox(width: 6),
                  _Tally(
                    count: tallies.none,
                    label: l10n.presTallyNone,
                    tone: ChipTone.neutral,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: RaeedSpacing.md),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () =>
                context.push(AppRoutes.attendancePath(item.group.id, item.id)),
            child: Text(l10n.todayRecordAttendance),
          ),
        ],
      ),
    );
  }
}

class _Tally extends StatelessWidget {
  const _Tally({required this.count, required this.label, required this.tone});

  final int count;
  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = ToneChip.colorsFor(context, tone);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: context.type
                  .tabular(context.type.h3)
                  .copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              label,
              style: context.type.caption.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceDoneCard extends StatelessWidget {
  const _AttendanceDoneCard({required this.next});

  final NextSession next;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final counts = next.attendance;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.lg,
        vertical: RaeedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: palette.successSoft,
        borderRadius: BorderRadius.circular(RaeedRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: palette.success),
          ),
          const SizedBox(width: RaeedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todayAttendanceDone(next.item.group.name),
                  style: context.type.label.copyWith(
                    color: palette.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.todayAttendanceSummary(
                    counts.present,
                    counts.late,
                    counts.excused,
                    counts.absent,
                  ),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: palette.surface,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () =>
                context.push(AppRoutes.sessionSummaryPath(next.item.id)),
            child: Text(l10n.todaySessionSummaryCta),
          ),
        ],
      ),
    );
  }
}

class _NoContentNudge extends StatelessWidget {
  const _NoContentNudge({required this.session});

  final SessionItem session;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: palette.warningSoft,
        borderRadius: BorderRadius.circular(RaeedRadius.lg + 2),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: palette.warning, size: 20),
          const SizedBox(width: RaeedSpacing.sm + 2),
          Expanded(
            child: Text(
              l10n.todayNoContent(
                session.group.name,
                clockTime(locale, session.startsAt),
              ),
              style: context.type.caption.copyWith(color: palette.ink),
            ),
          ),
          const SizedBox(width: RaeedSpacing.sm),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: palette.surface,
              foregroundColor: palette.warning,
              minimumSize: const Size(0, 36),
            ),
            onPressed: () =>
                context.push(AppRoutes.sessionEditPath(session.id)),
            child: Text(l10n.todayAdd),
          ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ExecutiveCard(
      onTap: onTap,
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        vertical: RaeedSpacing.md,
        horizontal: RaeedSpacing.xs,
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(RaeedRadius.md),
            ),
            child: Icon(icon, size: 18, color: foreground),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: context.type.caption.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
