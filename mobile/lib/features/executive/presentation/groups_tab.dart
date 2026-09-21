import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/executive_group.dart';
import 'executive_providers.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/tone_chip.dart';

/// EXEC-M-05 — the group list.
class GroupsTab extends ConsumerWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final groups = ref.watch(executiveGroupsProvider);
    final restricted = ref.watch(
      sessionControllerProvider.select((s) => s.user?.branchId != null),
    );

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
                  l10n.execTabGroups,
                  style: context.type.h1.copyWith(color: palette.ink),
                ),
                if (groups.value case final List<ExecutiveGroup> list)
                  Text(
                    '${l10n.grpCount(list.length)} · '
                    '${restricted ? l10n.execScopeRestricted : l10n.execScopeAllBranches}',
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                  ),
              ],
            ),
          ),
          Expanded(
            child: groups.when(
              loading: () => const SkeletonCardList(count: 5),
              error: (error, _) => RaeedErrorView(
                error: error,
                onRetry: () => ref.invalidate(executiveGroupsProvider),
              ),
              data: (list) => list.isEmpty
                  ? ExecutiveEmptyState(
                      kind: EmptyStateKind.dataProblem,
                      title: l10n.grpEmptyTitle,
                      body: l10n.grpEmptyBody,
                    )
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(executiveGroupsProvider),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          RaeedSpacing.lg,
                          0,
                          RaeedSpacing.lg,
                          RaeedSpacing.xl2,
                        ),
                        itemCount: list.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: RaeedSpacing.sm),
                        itemBuilder: (_, index) => GroupRow(group: list[index]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One group: name · category, educators · schedule, the capacity chip.
class GroupRow extends StatelessWidget {
  const GroupRow({required this.group, super.key});

  final ExecutiveGroup group;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final capacity = group.capacity;
    final capacityText = capacity == null
        ? '${group.enrolledCount}'
        : '${group.enrolledCount}/$capacity';

    return ExecutiveCard(
      onTap: () => context.go(AppRoutes.groupPath(group.id)),
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: group.name,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (group.categoryName.isNotEmpty)
                        TextSpan(
                          text: ' · ${group.categoryName}',
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    if (group.educatorNames.isNotEmpty)
                      group.educatorNames.join('، '),
                    if (group.scheduleLabel != null) group.scheduleLabel!,
                  ].join(' · '),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: RaeedSpacing.sm),
          Semantics(
            label: group.isOverCapacity
                ? '${l10n.grpOverCapacity} $capacityText'
                : capacityText,
            child: ExcludeSemantics(
              child: ToneChip(
                label: capacityText,
                tone: group.isOverCapacity
                    ? ChipTone.warning
                    : ChipTone.neutral,
                icon: group.isOverCapacity ? Icons.arrow_drop_up_rounded : null,
              ),
            ),
          ),
          const SizedBox(width: RaeedSpacing.sm),
          Icon(Icons.arrow_forward_rounded, size: 18, color: palette.inkDim),
        ],
      ),
    );
  }
}
