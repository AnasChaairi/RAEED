import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/domain/conversation.dart';
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_empty_state.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import 'educator_providers.dart';

/// EDU-M-07 — threads by group, then the team and management.
class EducatorMessagesTab extends ConsumerWidget {
  const EducatorMessagesTab({this.now, super.key});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final threads = ref.watch(conversationsControllerProvider);
    final availability = ref.watch(availabilityControllerProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xl,
              RaeedSpacing.sm,
              RaeedSpacing.xl,
              RaeedSpacing.sm + 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eduTabMessages,
                  style: context.type.h1.copyWith(color: palette.ink),
                ),
                Text(
                  availability == null
                      ? l10n.msgAvailabilityUnset
                      : l10n.msgAvailability(availability.label),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: threads.when(
            loading: () => const SkeletonCardList(count: 5, height: 66),
            error: (error, _) => RaeedErrorView(
              error: error,
              onRetry: () => ref.invalidate(conversationsControllerProvider),
            ),
            data: (list) => list.isEmpty
                ? ExecutiveEmptyState(
                    kind: EmptyStateKind.reassuring,
                    title: l10n.msgEmptyTitle,
                    body: l10n.msgFooterEdu,
                  )
                : _ThreadList(threads: list, now: now ?? DateTime.now()),
          ),
        ),
      ],
    );
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList({required this.threads, required this.now});

  final List<ConversationSummary> threads;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final byGroup = <String, List<ConversationSummary>>{};
    final team = <ConversationSummary>[];
    for (final thread in threads) {
      if (thread.kind == ConversationKind.child) {
        byGroup.putIfAbsent(thread.groupName ?? '', () => []).add(thread);
      } else {
        team.add(thread);
      }
    }

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.xs,
        RaeedSpacing.sm + 2,
        RaeedSpacing.xs,
        6,
      ),
      child: Text(
        text,
        style: context.type.caption.copyWith(
          color: palette.inkDim,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        0,
        RaeedSpacing.lg,
        RaeedSpacing.xl2,
      ),
      children: [
        for (final entry in byGroup.entries) ...[
          header(
            entry.key.isEmpty
                ? l10n.msgSectionChildren
                : l10n.msgSectionChildrenOf(entry.key),
          ),
          for (final thread in entry.value) ...[
            ThreadRow(thread: thread, now: now),
            const SizedBox(height: RaeedSpacing.sm),
          ],
        ],
        if (team.isNotEmpty) ...[
          header(l10n.msgSectionTeam),
          for (final thread in team) ...[
            ThreadRow(thread: thread, now: now),
            const SizedBox(height: RaeedSpacing.sm),
          ],
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: RaeedSpacing.xs),
          child: Text(
            l10n.msgFooterEdu,
            textAlign: TextAlign.center,
            style: context.type.caption.copyWith(
              color: palette.inkDim,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class ThreadRow extends StatelessWidget {
  const ThreadRow({required this.thread, required this.now, super.key});

  final ConversationSummary thread;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    return ExecutiveCard(
      onTap: () => context.push(AppRoutes.conversationPath(thread.id)),
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.sm + 2,
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
                  ? Icons.person_outline_rounded
                  : Icons.groups_outlined,
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
                Text(
                  thread.lastMessagePreview ?? '',
                  style: context.type.caption.copyWith(color: palette.inkDim),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (thread.unreadCount > 0) ...[
            const SizedBox(width: RaeedSpacing.sm),
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${thread.unreadCount}',
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(
                      color: palette.primaryOn,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
