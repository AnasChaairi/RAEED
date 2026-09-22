import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../children/presentation/widgets/health_alert_badge.dart';
import '../domain/executive_child.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/image_rights_dot.dart';
import 'widgets/section_header.dart';

/// EXEC-M-08 — the executive's children list (`/children`).
class ChildrenScreen extends ConsumerStatefulWidget {
  const ChildrenScreen({super.key});

  @override
  ConsumerState<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends ConsumerState<ChildrenScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _categoryId;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final children = ref.watch(
      executiveChildrenProvider(
        query: _query.isEmpty ? null : _query,
        categoryId: _categoryId,
      ),
    );
    final categories = ref.watch(categoriesProvider).value ?? const [];

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: l10n.moreChildren,
              subtitle: children.value == null
                  ? null
                  : l10n.childrenCount(children.value!.length),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.lg),
              child: TextField(
                controller: _search,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: l10n.childrenSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.lg),
              child: Row(
                children: [
                  FilterPill(
                    label: l10n.filterAll,
                    selected: _categoryId == null,
                    onTap: () => setState(() => _categoryId = null),
                  ),
                  for (final category in categories) ...[
                    const SizedBox(width: 6),
                    FilterPill(
                      label: category.name,
                      selected: _categoryId == category.id,
                      onTap: () => setState(() => _categoryId = category.id),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            Expanded(
              child: children.when(
                loading: () => const SkeletonCardList(count: 6),
                error: (error, _) => RaeedErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(executiveChildrenProvider),
                ),
                data: (list) => list.isEmpty
                    ? ExecutiveEmptyState(
                        kind: EmptyStateKind.dataProblem,
                        title: l10n.childrenEmptyTitle,
                        body: l10n.childrenEmptyBody,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          RaeedSpacing.lg,
                          0,
                          RaeedSpacing.lg,
                          RaeedSpacing.xl2,
                        ),
                        itemCount: list.length + 1,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: RaeedSpacing.sm),
                        itemBuilder: (_, index) => index == list.length
                            ? const Padding(
                                padding: EdgeInsets.only(top: RaeedSpacing.xs),
                                child: ImageRightsLegend(),
                              )
                            : ExecutiveChildRow(child: list[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One child: name with the icon-only health badge, group · attendance,
/// the image-rights dot.
class ExecutiveChildRow extends StatelessWidget {
  const ExecutiveChildRow({required this.child, super.key});

  final ExecutiveChildSummary child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final attendance = child.attendance;
    final meta = [
      if (child.child.group != null) child.child.group!.name,
      if (attendance != null && attendance.expected > 0)
        l10n.attendanceShort('${attendance.present}/${attendance.expected}'),
    ].join(' · ');

    return ExecutiveCard(
      onTap: () => context.go(AppRoutes.childPath(child.id)),
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
              Icons.person_outline_rounded,
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
                    Flexible(
                      child: Text(
                        child.fullName,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (child.child.healthAlert) ...[
                      const SizedBox(width: 6),
                      const HealthAlertBadge(size: 12),
                    ],
                  ],
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                  ),
              ],
            ),
          ),
          const SizedBox(width: RaeedSpacing.sm),
          ImageRightsDot(level: child.imageRights),
          const SizedBox(width: RaeedSpacing.sm),
          Icon(Icons.arrow_forward_rounded, size: 18, color: palette.inkDim),
        ],
      ),
    );
  }
}
