import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../children/presentation/widgets/health_alert_badge.dart';
import '../../executive/domain/conversation.dart';
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_empty_state.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../../executive/presentation/widgets/image_rights_dot.dart';
import '../../executive/presentation/widgets/tone_chip.dart';
import '../domain/educator_group.dart';
import '../domain/educator_session.dart';
import 'educator_providers.dart';

enum GroupSegment { roster, homework, staff }

/// EDU-M-06 — a group: roster, homework, the team channel.
class EducatorGroupScreen extends ConsumerStatefulWidget {
  const EducatorGroupScreen({required this.groupId, this.now, super.key});

  final String groupId;
  final DateTime? now;

  @override
  ConsumerState<EducatorGroupScreen> createState() =>
      _EducatorGroupScreenState();
}

class _EducatorGroupScreenState extends ConsumerState<EducatorGroupScreen> {
  GroupSegment _segment = GroupSegment.roster;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final group = ref.watch(executiveGroupProvider(widget.groupId)).value;
    final on = palette.primaryOn;

    return Scaffold(
      backgroundColor: palette.bg,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: palette.primary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(RaeedRadius.xl2),
              ),
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
                        BackButton(
                          color: on,
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go(AppRoutes.homeTabPath('groups')),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group?.name ?? '',
                                style: context.type.h2.copyWith(color: on),
                              ),
                              Text(
                                group == null
                                    ? ''
                                    : [
                                        if (group.scheduleLabel != null)
                                          group.scheduleLabel!,
                                        if (group.place != null) group.place!,
                                        l10n.childrenCount(group.enrolledCount),
                                        if (group.educatorNames.length > 1)
                                          l10n.sessMetaWith(
                                            group.educatorNames.last,
                                          ),
                                      ].join(' · '),
                                style: context.type
                                    .tabular(context.type.caption)
                                    .copyWith(
                                      color: on.withValues(alpha: 0.75),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          for (final segment in GroupSegment.values) ...[
                            _Segment(
                              label: switch (segment) {
                                GroupSegment.roster => l10n.grpTabRoster,
                                GroupSegment.homework => l10n.grpTabHomework,
                                GroupSegment.staff => l10n.grpTabStaff,
                              },
                              selected: _segment == segment,
                              onTap: () => setState(() => _segment = segment),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: switch (_segment) {
              GroupSegment.roster => _RosterList(groupId: widget.groupId),
              GroupSegment.homework => _HomeworkList(
                groupId: widget.groupId,
                now: widget.now ?? DateTime.now(),
              ),
              GroupSegment.staff => _StaffChannel(
                groupId: widget.groupId,
                groupName: group?.name ?? '',
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final on = palette.primaryOn;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? on : on.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(RaeedRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.md,
              vertical: RaeedSpacing.sm,
            ),
            child: Text(
              label,
              style: context.type.caption.copyWith(
                color: selected ? palette.primary : on,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RosterList extends ConsumerWidget {
  const _RosterList({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final roster = ref.watch(educatorRosterProvider(groupId));
    return roster.when(
      loading: () => const SkeletonCardList(count: 6),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(educatorRosterProvider(groupId)),
      ),
      data: (children) => children.isEmpty
          ? ExecutiveEmptyState(
              kind: EmptyStateKind.dataProblem,
              title: l10n.grpRosterEmpty,
              body: '',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                RaeedSpacing.lg,
                RaeedSpacing.md,
                RaeedSpacing.lg,
                RaeedSpacing.xl2,
              ),
              itemCount: children.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RaeedSpacing.sm),
              itemBuilder: (_, index) => index == children.length
                  ? const Padding(
                      padding: EdgeInsets.only(top: RaeedSpacing.xs),
                      child: ImageRightsLegend(),
                    )
                  : RosterRow(child: children[index]),
            ),
    );
  }
}

class RosterRow extends StatelessWidget {
  const RosterRow({required this.child, super.key});

  final RosterChild child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final sub = child.needsCare
        ? l10n.rosterCare
        : child.isNew && child.expected == 0
        ? l10n.rosterNew
        : l10n.rosterAttendance(child.present, child.expected);

    return ExecutiveCard(
      onTap: () => context.push(AppRoutes.childPath(child.id)),
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md,
        vertical: RaeedSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(RaeedRadius.lg),
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
                        child.fullName,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (child.hasHealthAlert) ...[
                      const SizedBox(width: 5),
                      const HealthAlertBadge(size: 16),
                    ],
                  ],
                ),
                Text(
                  sub,
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(
                        color: child.needsCare
                            ? palette.warning
                            : palette.inkDim,
                      ),
                ),
              ],
            ),
          ),
          ImageRightsDot(level: child.imageRights),
        ],
      ),
    );
  }
}

class _HomeworkList extends ConsumerWidget {
  const _HomeworkList({required this.groupId, required this.now});

  final String groupId;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final homework = ref.watch(groupHomeworkProvider(groupId));
    return homework.when(
      loading: () => const SkeletonCardList(count: 3, height: 90),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(groupHomeworkProvider(groupId)),
      ),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          RaeedSpacing.md,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          if (list.isEmpty)
            ExecutiveEmptyState(
              kind: EmptyStateKind.reassuring,
              title: l10n.hwEmpty,
              body: '',
            )
          else
            for (final item in list) ...[
              _HomeworkCard(item: item, now: now, locale: locale),
              const SizedBox(height: RaeedSpacing.sm),
            ],
          Text(
            l10n.hwFooter,
            textAlign: TextAlign.center,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        ],
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  const _HomeworkCard({
    required this.item,
    required this.now,
    required this.locale,
  });

  final HomeworkItem item;
  final DateTime now;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final open = item.isOpenAt(now);
    final target = item.isWholeGroup
        ? l10n.sessWholeGroup
        : l10n.hwTargetChildren(item.targetCount);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title ?? item.instructions,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ToneChip(
                label: open ? l10n.hwStateOpen : l10n.hwStateClosed,
                tone: open ? ChipTone.primary : ChipTone.neutral,
              ),
            ],
          ),
          Text(
            open
                ? l10n.hwListMeta(target, dayAndMonth(locale, item.dueAt))
                : l10n.hwListMetaClosed(target, shortDate(locale, item.dueAt)),
            style: context.type
                .tabular(context.type.caption)
                .copyWith(color: palette.inkDim),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: item.doneShare,
                    minHeight: 6,
                    backgroundColor: palette.surfaceAlt,
                    color: palette.primary,
                  ),
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              Text(
                '${item.doneCount}/${item.targetCount}',
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(color: palette.ink, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffChannel extends ConsumerWidget {
  const _StaffChannel({required this.groupId, required this.groupName});

  final String groupId;
  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final conversations = ref.watch(conversationsControllerProvider);
    return conversations.when(
      loading: () => const SkeletonCardList(count: 2, height: 80),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(conversationsControllerProvider),
      ),
      data: (list) {
        final staff = list
            .where(
              (thread) =>
                  thread.kind == ConversationKind.staff &&
                  thread.title == groupName,
            )
            .firstOrNull;
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.lg,
            RaeedSpacing.md,
            RaeedSpacing.lg,
            RaeedSpacing.xl2,
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.md,
                vertical: RaeedSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
              ),
              child: Text(
                l10n.staffChannelNote,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
            ),
            const SizedBox(height: RaeedSpacing.md),
            if (staff == null)
              Text(
                l10n.staffChannelMissing,
                style: context.type.caption.copyWith(color: palette.inkDim),
              )
            else ...[
              if (staff.lastMessagePreview != null)
                ExecutiveCard(
                  radius: RaeedRadius.lg + 2,
                  child: Text(
                    staff.lastMessagePreview!,
                    style: context.type.bodySmall.copyWith(color: palette.ink),
                  ),
                ),
              const SizedBox(height: RaeedSpacing.sm + 2),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () =>
                    context.push(AppRoutes.conversationPath(staff.id)),
                child: Text(l10n.staffChannelOpen),
              ),
            ],
          ],
        );
      },
    );
  }
}
