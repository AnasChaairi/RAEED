import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/conversation.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';

/// EXEC-M-03 — the thread list, grouped by conversation kind.
///
/// The subtitle discloses oversight up front (`MSG-08`): an executive reads
/// any thread, and every read of a thread they are not in is recorded.
class MessagesTab extends ConsumerWidget {
  const MessagesTab({this.now, super.key});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final threads = ref.watch(conversationsControllerProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xl,
              RaeedSpacing.md,
              RaeedSpacing.xl,
              RaeedSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.execTabMessages,
                  style: context.type.h1.copyWith(color: palette.ink),
                ),
                Text(
                  l10n.msgOversightSubtitle,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
          Expanded(
            child: threads.when(
              loading: () => const SkeletonCardList(),
              error: (error, _) => RaeedErrorView(
                error: error,
                onRetry: () => ref
                    .read(conversationsControllerProvider.notifier)
                    .refresh(),
              ),
              data: (list) => list.isEmpty
                  ? ExecutiveEmptyState(
                      kind: EmptyStateKind.dataProblem,
                      title: l10n.msgEmptyTitle,
                      body: l10n.msgEmptyBody,
                    )
                  : _ThreadList(threads: list, now: now ?? DateTime.now()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadList extends ConsumerWidget {
  const _ThreadList({required this.threads, required this.now});

  final List<ConversationSummary> threads;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final sections = [
      (ConversationKind.child, l10n.msgSectionChildren),
      (ConversationKind.staff, l10n.msgSectionStaff),
      (ConversationKind.executive, l10n.msgSectionExecutives),
    ];

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(conversationsControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          0,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          for (final (kind, label) in sections)
            if (threads.any((thread) => thread.kind == kind)) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  RaeedSpacing.xs,
                  RaeedSpacing.md,
                  RaeedSpacing.xs,
                  6,
                ),
                child: Text(
                  label,
                  style: context.type.caption.copyWith(
                    color: palette.inkDim,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final thread in threads.where((t) => t.kind == kind))
                Padding(
                  padding: const EdgeInsets.only(bottom: RaeedSpacing.sm),
                  child: _ThreadRow(thread: thread, now: now),
                ),
            ],
        ],
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.thread, required this.now});

  final ConversationSummary thread;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);

    return ExecutiveCard(
      onTap: () => context.go(AppRoutes.conversationPath(thread.id)),
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(RaeedRadius.lg),
            ),
            child: Icon(
              thread.kind == ConversationKind.child
                  ? Icons.child_care_outlined
                  : Icons.forum_outlined,
              color: palette.inkDim,
              size: 20,
            ),
          ),
          const SizedBox(width: RaeedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        thread.title,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (thread.lastMessageAt != null)
                      Text(
                        relativeTime(
                          l10n,
                          locale,
                          thread.lastMessageAt!,
                          now: now,
                        ),
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                  ],
                ),
                if (thread.lastMessagePreview != null)
                  Text(
                    thread.lastMessagePreview!,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (thread.hasOpenReport) ...[
            const SizedBox(width: RaeedSpacing.sm),
            Icon(Icons.flag_rounded, size: 16, color: palette.danger),
          ],
          if (thread.unreadCount > 0) ...[
            const SizedBox(width: RaeedSpacing.sm),
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(RaeedRadius.pill),
              ),
              child: Text(
                '${thread.unreadCount}',
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(
                      color: palette.primaryOn,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
