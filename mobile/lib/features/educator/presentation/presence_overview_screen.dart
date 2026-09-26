import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_empty_state.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../domain/educator_session.dart';
import 'educator_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-02 — who is coming, who declined and why, who never answered.
class PresenceOverviewScreen extends ConsumerStatefulWidget {
  const PresenceOverviewScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<PresenceOverviewScreen> createState() =>
      _PresenceOverviewScreenState();
}

class _PresenceOverviewScreenState
    extends ConsumerState<PresenceOverviewScreen> {
  bool _reminded = false;
  bool _sending = false;

  Future<void> _remind(int count) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      final reminded = await ref
          .read(sessionsRepositoryProvider)
          .remindUnanswered(widget.sessionId);
      if (!mounted) return;
      setState(() => _reminded = true);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.presRemindedToast(reminded))),
      );
      ref.invalidate(presenceOverviewProvider(widget.sessionId));
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final overview = ref.watch(presenceOverviewProvider(widget.sessionId));
    final session = ref.watch(sessionDetailProvider(widget.sessionId)).value;

    final subtitle = session == null
        ? null
        : overview.value?.sentAt != null
        ? l10n.presSubtitle(
            session.item.group.name,
            clockTime(locale, session.item.startsAt),
            relativeTime(
              l10n,
              locale,
              overview.value!.sentAt!,
              now: DateTime.now(),
            ),
          )
        : l10n.presSubtitleNotSent(
            session.item.group.name,
            clockTime(locale, session.item.startsAt),
          );

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            EducatorPageHeader(title: l10n.presTitle, subtitle: subtitle),
            Expanded(
              child: overview.when(
                loading: () => const SkeletonCardList(count: 3, height: 100),
                error: (error, _) => RaeedErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(
                    presenceOverviewProvider(widget.sessionId),
                  ),
                ),
                data: (data) => data.wasSent
                    ? _Body(overview: data)
                    : ExecutiveEmptyState(
                        kind: EmptyStateKind.dataProblem,
                        title: l10n.presNotSent,
                        body: '',
                      ),
              ),
            ),
            if (overview.value case final data? when data.wasSent)
              BottomActionBar(
                hint: data.deadlineAt == null
                    ? null
                    : l10n.presRemindNote(clockTime(locale, data.deadlineAt!)),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: _reminded || data.reminderSent
                        ? palette.successSoft
                        : null,
                    foregroundColor: _reminded || data.reminderSent
                        ? palette.success
                        : null,
                  ),
                  onPressed:
                      _reminded ||
                          data.reminderSent ||
                          _sending ||
                          data.tallies.none == 0
                      ? null
                      : () => _remind(data.tallies.none),
                  child: Text(
                    _reminded || data.reminderSent
                        ? l10n.presRemindDone
                        : l10n.presRemind(data.tallies.none),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.overview});

  final PresenceOverview overview;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final t = overview.tallies;
    final legend = [
      (l10n.presTallyYes, t.yes, palette.success),
      (l10n.presTallyLate, t.late, palette.warning),
      (l10n.presTallyNo, t.no, palette.info),
      (l10n.presTallyNone, t.none, palette.inkDim),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.md,
        RaeedSpacing.lg,
        RaeedSpacing.xl2,
      ),
      children: [
        ExecutiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.presPlanning,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${t.expected} ',
                      style: context.type
                          .tabular(context.type.h1)
                          .copyWith(color: palette.ink),
                    ),
                    TextSpan(
                      text: l10n.presExpectedOf(overview.enrolledCount),
                      style: context.type.bodySmall.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      for (final (_, count, color) in legend)
                        if (count > 0)
                          Expanded(
                            flex: count,
                            child: ColoredBox(color: color),
                          ),
                      if (t.total == 0)
                        Expanded(child: ColoredBox(color: palette.border)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: RaeedSpacing.sm + 2,
                runSpacing: 2,
                children: [
                  for (final (label, count, color) in legend)
                    Text(
                      '● $label $count',
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: color),
                    ),
                ],
              ),
            ],
          ),
        ),
        for (final group in overview.groups)
          if (group.children.isNotEmpty) ...[
            const SizedBox(height: RaeedSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xs),
              child: Text(
                '${switch (group.answer) {
                  PresenceAnswerKind.none => l10n.presTallyNone,
                  PresenceAnswerKind.no => l10n.presTallyNo,
                  PresenceAnswerKind.late => l10n.presTallyLate,
                  PresenceAnswerKind.yes => l10n.presTallyYes,
                }} · ${group.children.length}',
                style: context.type.caption.copyWith(
                  color: palette.inkDim,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: RaeedSpacing.xs),
            ExecutiveCard(
              padding: EdgeInsets.zero,
              radius: RaeedRadius.lg + 2,
              child: Column(
                children: [
                  for (final child in group.children)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.md + 2,
                        vertical: RaeedSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        border: child == group.children.last
                            ? null
                            : Border(bottom: BorderSide(color: palette.border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              child.fullName,
                              style: context.type.label.copyWith(
                                color: palette.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (child.reason != null)
                            Text(
                              presenceReasonLabel(l10n, child.reason!),
                              style: context.type.caption.copyWith(
                                color: palette.inkDim,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
      ],
    );
  }
}

/// The reason chips a guardian may pick, in words.
String presenceReasonLabel(AppL10n l10n, String reason) => switch (reason) {
  'illness' => l10n.presenceReasonIllness,
  'travel' => l10n.presenceReasonTravel,
  'exam' => l10n.presenceReasonExam,
  'other' => l10n.presenceReasonOther,
  _ => reason,
};
