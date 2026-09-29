import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/executive_child.dart';
import '../domain/executive_group.dart';
import '../domain/family.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_confirm_sheet.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/family_fields.dart';
import 'widgets/password_handover_dialog.dart';
import 'widgets/section_header.dart';
import 'widgets/tone_chip.dart';

/// The three tabs of the hub.
enum ManageTab {
  unassigned('unassigned'),
  families('families'),
  groups('groups');

  const ManageTab(this.slug);

  final String slug;

  static ManageTab fromSlug(String? slug) => values.firstWhere(
    (tab) => tab.slug == slug,
    orElse: () => ManageTab.unassigned,
  );
}

/// EXEC-M-10 — families and groups (`/manage`).
class ManageScreen extends ConsumerStatefulWidget {
  const ManageScreen({this.initialTab = ManageTab.unassigned, super.key});

  final ManageTab initialTab;

  @override
  ConsumerState<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends ConsumerState<ManageScreen> {
  late ManageTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final unassigned = ref.watch(unassignedChildrenProvider);
    final families = ref.watch(familiesProvider);
    final groups = ref.watch(executiveGroupsProvider);
    final selection = ref.watch(unassignedSelectionProvider);

    final subtitle = [
      if (families.value != null) l10n.familiesCount(families.value!.length),
      if (groups.value != null) l10n.grpCount(groups.value!.length),
    ].join(' · ');

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: l10n.manageTitle,
              subtitle: subtitle.isEmpty ? null : subtitle,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.lg),
              child: Row(
                children: [
                  for (final tab in ManageTab.values) ...[
                    FilterPill(
                      label:
                          tab == ManageTab.unassigned &&
                              (unassigned.value?.isNotEmpty ?? false)
                          ? '${_tabLabel(l10n, tab)} ${unassigned.value!.length}'
                          : _tabLabel(l10n, tab),
                      selected: _tab == tab,
                      onTap: () => setState(() => _tab = tab),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            Expanded(
              child: switch (_tab) {
                ManageTab.unassigned => _UnassignedTab(
                  children: unassigned,
                  selection: selection,
                ),
                ManageTab.families => _FamiliesTab(families: families),
                ManageTab.groups => _GroupsTab(groups: groups),
              },
            ),
            switch (_tab) {
              ManageTab.unassigned when selection.isNotEmpty => _BottomBar(
                child: FilledButton(
                  onPressed: () => _openAssign(context),
                  child: Text(l10n.assignCta(selection.length)),
                ),
              ),
              ManageTab.families => _BottomBar(
                child: FilledButton(
                  onPressed: () => context.push(AppRoutes.manageNewFamily),
                  child: Text(l10n.newFamilyCta),
                ),
              ),
              ManageTab.groups => _BottomBar(
                child: FilledButton(
                  onPressed: () => context.push(AppRoutes.manageNewGroup),
                  child: Text(l10n.newGroupCta),
                ),
              ),
              _ => const SizedBox.shrink(),
            },
          ],
        ),
      ),
    );
  }

  static String _tabLabel(AppL10n l10n, ManageTab tab) => switch (tab) {
    ManageTab.unassigned => l10n.manageTabUnassigned,
    ManageTab.families => l10n.manageTabFamilies,
    ManageTab.groups => l10n.manageTabGroups,
  };

  Future<void> _openAssign(
    BuildContext context, {
    String? preselectedGroupId,
  }) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final selected = ref.read(unassignedSelectionProvider);
    final children = ref.read(unassignedChildrenProvider).value ?? const [];
    final groups = ref.read(executiveGroupsProvider).value ?? const [];
    final chosen = children
        .where((child) => selected.contains(child.id))
        .toList();
    if (chosen.isEmpty) return;

    final target = await AssignSheet.show(
      context,
      children: chosen,
      groups: groups,
      preselectedGroupId: preselectedGroupId,
    );
    if (target == null || !mounted) return;

    final after = target.enrolledCount + chosen.length;
    if (target.capacity != null && after > target.capacity!) {
      final confirmed = await ExecutiveConfirmSheet.show(
        this.context,
        weight: ConfirmWeight.highReach,
        kind: l10n.assignOverKind,
        title: l10n.assignOverTitle(target.name),
        body: l10n.assignWarn(after, target.capacity!, target.name),
        recordedText: l10n.assignOverLog,
        confirmLabel: l10n.assignOverCta,
      );
      if (!confirmed || !mounted) return;
    }

    try {
      await ref
          .read(familiesRepositoryProvider)
          .assignChildren(
            groupId: target.id,
            childIds: chosen.map((child) => child.id).toList(),
          );
      ref.read(unassignedSelectionProvider.notifier).clear();
      ref.invalidate(unassignedChildrenProvider);
      ref.invalidate(executiveGroupsProvider);
      ref.invalidate(familiesProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.assignedToast(chosen.length, target.name)} · ⦿ ${l10n.recordedShort}',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.sm + 2,
        RaeedSpacing.lg,
        RaeedSpacing.md,
      ),
      child: child,
    );
  }
}

class _UnassignedTab extends ConsumerWidget {
  const _UnassignedTab({required this.children, required this.selection});

  final AsyncValue<List<ExecutiveChildSummary>> children;
  final Set<String> selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return children.when(
      loading: () => const SkeletonCardList(),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(unassignedChildrenProvider),
      ),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          0,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xs),
            child: Text(
              l10n.unassignedHint,
              style: context.type.caption.copyWith(color: palette.inkDim),
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          if (list.isEmpty)
            ExecutiveEmptyState(
              kind: EmptyStateKind.reassuring,
              title: l10n.unassignedEmpty,
              body: '',
            )
          else
            for (final child in list)
              Padding(
                padding: const EdgeInsets.only(bottom: RaeedSpacing.sm),
                child: _SelectableChildRow(
                  child: child,
                  selected: selection.contains(child.id),
                  onTap: () => ref
                      .read(unassignedSelectionProvider.notifier)
                      .toggle(child.id),
                ),
              ),
        ],
      ),
    );
  }
}

class _SelectableChildRow extends StatelessWidget {
  const _SelectableChildRow({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final ExecutiveChildSummary child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: child.fullName,
      child: ExecutiveCard(
        onTap: onTap,
        radius: RaeedRadius.lg + 2,
        color: selected ? palette.primarySoft : null,
        borderColor: selected ? palette.primary : null,
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.md + 2,
          vertical: RaeedSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? palette.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(RaeedRadius.sm + 1),
                border: Border.all(
                  color: selected ? palette.primary : palette.inkDim,
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: palette.primaryOn,
                    )
                  : null,
            ),
            const SizedBox(width: RaeedSpacing.md),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  child.fullName,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The bottom sheet picking a target group, showing each group's capacity
/// after the move.
class AssignSheet extends StatefulWidget {
  const AssignSheet({
    required this.children,
    required this.groups,
    this.preselectedGroupId,
    super.key,
  });

  final List<ExecutiveChildSummary> children;
  final List<ExecutiveGroup> groups;
  final String? preselectedGroupId;

  static Future<ExecutiveGroup?> show(
    BuildContext context, {
    required List<ExecutiveChildSummary> children,
    required List<ExecutiveGroup> groups,
    String? preselectedGroupId,
  }) => showModalBottomSheet<ExecutiveGroup>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AssignSheet(
      children: children,
      groups: groups,
      preselectedGroupId: preselectedGroupId,
    ),
  );

  @override
  State<AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends State<AssignSheet> {
  late String? _targetId = widget.preselectedGroupId;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final target = widget.groups.where((g) => g.id == _targetId).firstOrNull;
    final count = widget.children.length;
    final over =
        target != null &&
        target.capacity != null &&
        target.enrolledCount + count > target.capacity!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RaeedRadius.xl2),
        ),
        boxShadow: context.elevationSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xl,
              RaeedSpacing.md,
              RaeedSpacing.xl,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: RaeedSpacing.md),
                Text(
                  l10n.assignSheetTitle(count),
                  style: context.type.h3.copyWith(color: palette.ink),
                ),
                Text(
                  widget.children.map((c) => c.fullName).join('، '),
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.xl,
                vertical: RaeedSpacing.md,
              ),
              children: [
                for (final group in widget.groups) ...[
                  _GroupTargetRow(
                    group: group,
                    added: _targetId == group.id ? count : 0,
                    selected: _targetId == group.id,
                    onTap: () => setState(() => _targetId = group.id),
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  RaeedSpacing.xl,
                  RaeedSpacing.md,
                  RaeedSpacing.xl,
                  RaeedSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (over)
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: RaeedSpacing.sm + 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: RaeedSpacing.md,
                          vertical: RaeedSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: palette.warningSoft,
                          borderRadius: BorderRadius.circular(RaeedRadius.md),
                        ),
                        child: Text(
                          '▲ ${l10n.assignWarn(target.enrolledCount + count, target.capacity!, target.name)}',
                          style: context.type.caption.copyWith(
                            color: palette.warning,
                          ),
                        ),
                      ),
                    Text(
                      '⦿ ${l10n.assignLogged}',
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: target == null
                                ? null
                                : () => Navigator.of(context).pop(target),
                            child: Text(
                              target == null
                                  ? l10n.assignPick
                                  : l10n.assignTo(target.name),
                            ),
                          ),
                        ),
                        const SizedBox(width: RaeedSpacing.sm),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(
                              0,
                              RaeedTouchTarget.primaryActionsPx,
                            ),
                            foregroundColor: palette.ink,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.dialogCancel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTargetRow extends StatelessWidget {
  const _GroupTargetRow({
    required this.group,
    required this.added,
    required this.selected,
    required this.onTap,
  });

  final ExecutiveGroup group;
  final int added;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final after = group.enrolledCount + added;
    final capacity = group.capacity;
    final tone = capacity == null
        ? ChipTone.neutral
        : after > capacity
        ? ChipTone.warning
        : after == capacity
        ? ChipTone.neutral
        : ChipTone.success;
    final label = capacity == null
        ? '$after'
        : added > 0
        ? '${group.enrolledCount}→$after/$capacity'
        : '$after/$capacity';

    return Semantics(
      button: true,
      selected: selected,
      label: '${group.name} $label',
      child: Material(
        color: selected ? palette.primarySoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.lg),
          side: BorderSide(
            color: selected ? palette.primary : palette.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.md,
              vertical: RaeedSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? palette.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? palette.primary : palette.inkDim,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: RaeedSpacing.sm + 2),
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: context.type.label.copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          [
                            if (group.educatorNames.isNotEmpty)
                              group.educatorNames.join('، '),
                            if (group.scheduleLabel != null)
                              group.scheduleLabel!,
                          ].where((s) => s.isNotEmpty).join(' · '),
                          style: context.type
                              .tabular(context.type.caption)
                              .copyWith(color: palette.inkDim),
                        ),
                      ],
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: ToneChip(
                    label: label,
                    tone: tone,
                    icon: tone == ChipTone.warning
                        ? Icons.arrow_drop_up_rounded
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FamiliesTab extends ConsumerWidget {
  const _FamiliesTab({required this.families});

  final AsyncValue<List<Family>> families;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return families.when(
      loading: () => const SkeletonCardList(),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(familiesProvider),
      ),
      data: (list) => list.isEmpty
          ? ExecutiveEmptyState(
              kind: EmptyStateKind.dataProblem,
              title: l10n.familiesEmpty,
              body: '',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                RaeedSpacing.lg,
                0,
                RaeedSpacing.lg,
                RaeedSpacing.xl2,
              ),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RaeedSpacing.sm),
              itemBuilder: (_, index) => FamilyCard(family: list[index]),
            ),
    );
  }
}

/// One household: status, guardians, children with their group.
class FamilyCard extends ConsumerWidget {
  const FamilyCard({required this.family, super.key});

  final Family family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final status = familyStatusChip(l10n, family.status);

    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  family.label,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              status,
            ],
          ),
          Text(
            family.guardians
                .map((g) => g.displayName)
                .where((n) => n.isNotEmpty)
                .join(' · '),
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final child in family.children)
                ToneChip(
                  label:
                      '${child.fullName} · ${child.group?.name ?? l10n.familyNoGroup}',
                  tone: child.group == null
                      ? ChipTone.warning
                      : ChipTone.primary,
                ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm + 2),
          Row(
            children: [
              if (family.canResendInvitation) ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    foregroundColor: palette.ink,
                  ),
                  onPressed: () => _resend(context, ref),
                  child: Text(l10n.familyResend),
                ),
                const SizedBox(width: 6),
              ],
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                onPressed: () => context.push(AppRoutes.manageNewFamily),
                child: Text(l10n.familyAddChild),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final pending = family.guardians.where(
      (g) => g.account == AccountStatus.pending,
    );
    try {
      final credentials = <GuardianCredential>[];
      for (final guardian in pending) {
        final password = await ref
            .read(familiesRepositoryProvider)
            .resendInvitation(guardian.id);
        credentials.add(
          GuardianCredential(
            id: guardian.id,
            displayName: guardian.displayName,
            password: password,
          ),
        );
      }
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.familyResentToast} · ⦿')),
      );
      if (context.mounted && credentials.isNotEmpty) {
        await showPasswordHandover(context, guardians: credentials);
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }
}

class _GroupsTab extends ConsumerWidget {
  const _GroupsTab({required this.groups});

  final AsyncValue<List<ExecutiveGroup>> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return groups.when(
      loading: () => const SkeletonCardList(),
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
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                RaeedSpacing.lg,
                0,
                RaeedSpacing.lg,
                RaeedSpacing.xl2,
              ),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RaeedSpacing.sm),
              itemBuilder: (_, index) => GroupCapacityCard(group: list[index]),
            ),
    );
  }
}

/// A group with its capacity bar and the "assign children" shortcut.
class GroupCapacityCard extends StatelessWidget {
  const GroupCapacityCard({required this.group, super.key});

  final ExecutiveGroup group;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final capacity = group.capacity;
    final fill = capacity == null || capacity == 0
        ? 0.0
        : (group.enrolledCount / capacity).clamp(0.0, 1.0);

    return ExecutiveCard(
      onTap: () => context.push(AppRoutes.groupPath(group.id)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: context.type.h3.copyWith(color: palette.ink),
                    ),
                    Text(
                      [
                        group.categoryName,
                        group.educatorNames.join('، '),
                        if (group.scheduleLabel != null) group.scheduleLabel!,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: palette.inkDim),
                    ),
                  ],
                ),
              ),
              ToneChip(
                label: capacity == null
                    ? '${group.enrolledCount}'
                    : '${group.enrolledCount}/$capacity',
                tone: group.isOverCapacity
                    ? ChipTone.warning
                    : capacity != null && group.enrolledCount == capacity
                    ? ChipTone.neutral
                    : ChipTone.success,
                icon: group.isOverCapacity ? Icons.arrow_drop_up_rounded : null,
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fill,
              minHeight: 6,
              backgroundColor: palette.surfaceAlt,
              color: group.isOverCapacity ? palette.warning : palette.primary,
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm + 2),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              backgroundColor: palette.bg,
            ),
            onPressed: () =>
                context.go(AppRoutes.manageTabPath(ManageTab.unassigned.slug)),
            child: Text(l10n.groupAssignHere),
          ),
        ],
      ),
    );
  }
}
