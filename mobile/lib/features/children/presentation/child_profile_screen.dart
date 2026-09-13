import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../../shared/widgets/skeleton.dart';
import '../domain/child_age.dart';
import '../domain/child_detail.dart';
import 'home_providers.dart';

/// The four sub-tabs from the routing table in `specs/06-mobile-app-spec.md`.
enum ChildProfileTab {
  /// `/children/:id/schedule`.
  schedule(AppRoutes.childSchedule),

  /// `/children/:id/attendance`.
  attendance(AppRoutes.childAttendance),

  /// `/children/:id/homework`.
  homework(AppRoutes.childHomework),

  /// `/children/:id/materials`.
  materials(AppRoutes.childMaterials);

  const ChildProfileTab(this.slug);

  /// The path segment this tab is reached by.
  final String slug;

  /// Resolves a path segment to a tab, defaulting to [schedule].
  static ChildProfileTab fromSlug(String? slug) {
    for (final tab in ChildProfileTab.values) {
      if (tab.slug == slug) return tab;
    }
    return ChildProfileTab.schedule;
  }
}

/// A child's profile (`RAEED-12`).
///
/// This is the tap-through target for the health-alert badge, and the only
/// place in the app where a child's health text is rendered at all. Every
/// executive read of it is separately audit-logged server-side (`AUD-03`) —
/// the app's part of that bargain is not to render it anywhere a list view
/// would put it in front of a bystander.
class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({required this.childId, this.initialTab, super.key});

  /// The child being viewed.
  final String childId;

  /// Which sub-tab to open on, from the path.
  final ChildProfileTab? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(childDetailProvider(childId));

    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.childProfileTitle)),
        body: const _ProfileSkeleton(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.childProfileTitle)),
        body: RaeedErrorView(
          error: error,
          onRetry: () => ref.invalidate(childDetailProvider(childId)),
        ),
      ),
      data: (child) => _ChildProfileView(
        child: child,
        initialTab: initialTab ?? ChildProfileTab.schedule,
      ),
    );
  }
}

class _ChildProfileView extends StatelessWidget {
  const _ChildProfileView({required this.child, required this.initialTab});

  final ChildDetail child;
  final ChildProfileTab initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return DefaultTabController(
      length: ChildProfileTab.values.length,
      initialIndex: initialTab.index,
      child: Scaffold(
        backgroundColor: palette.bg,
        appBar: AppBar(
          title: Text(child.fullName),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: palette.primary,
            unselectedLabelColor: palette.inkDim,
            indicatorColor: palette.primary,
            tabs: [
              for (final tab in ChildProfileTab.values)
                Tab(text: _tabLabel(l10n, tab)),
            ],
          ),
        ),
        body: Column(
          children: [
            _ProfileHeader(child: child),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  for (final tab in ChildProfileTab.values)
                    _TabPlaceholder(tab: tab),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _tabLabel(AppL10n l10n, ChildProfileTab tab) => switch (tab) {
  ChildProfileTab.schedule => l10n.childTabSchedule,
  ChildProfileTab.attendance => l10n.childTabAttendance,
  ChildProfileTab.homework => l10n.childTabHomework,
  ChildProfileTab.materials => l10n.childTabMaterials,
};

/// Name, group, and — here and only here — the health record.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.child});

  final ChildDetail child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final dob = child.summary.dateOfBirth;
    final age = dob == null ? null : ageInYearsOn(dob, DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (child.summary.group != null)
            Text(
              '${l10n.childProfileGroupLabel}: ${child.summary.group!.name}',
              style: context.type.bodySmall.copyWith(color: palette.inkDim),
            ),
          if (age != null) ...[
            const SizedBox(height: RaeedSpacing.xs),
            Text(
              l10n.childAgeYears(age),
              style: context.type.bodySmall.copyWith(color: palette.inkDim),
            ),
          ],
          if (child.summary.healthAlert || child.health.isNotEmpty) ...[
            const SizedBox(height: RaeedSpacing.md),
            _HealthSection(child: child),
          ],
        ],
      ),
    );
  }
}

/// The one place health text is rendered.
class _HealthSection extends StatelessWidget {
  const _HealthSection({required this.child});

  final ChildDetail child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final health = child.health;
    final entries = <String>[
      ...health.allergies,
      ...health.conditions,
      ...health.medications,
      if (health.dietaryNotes != null) health.dietaryNotes!,
      ...health.otherNotes.values,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(RaeedRadius.md),
        border: Border.all(color: palette.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_outlined,
                size: 18,
                color: palette.accent,
              ),
              const SizedBox(width: RaeedSpacing.sm),
              Text(
                l10n.childProfileHealthTitle,
                style: context.type.label.copyWith(color: palette.accent),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          if (entries.isEmpty)
            Text(
              l10n.childProfileNoHealthInfo,
              style: context.type.bodySmall.copyWith(color: palette.ink),
            )
          else
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: RaeedSpacing.xs),
                child: Text(
                  entry,
                  style: context.type.bodySmall.copyWith(color: palette.ink),
                ),
              ),
        ],
      ),
    );
  }
}

/// Each sub-tab's content ships with its own ticket; the profile, its routing
/// and the health record are real now.
class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.tab});

  final ChildProfileTab tab;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(RaeedSpacing.xl2),
      child: Text(
        AppL10n.of(context).childProfileComingSoon,
        style: context.type.body.copyWith(color: context.palette.inkDim),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(RaeedSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonLine(widthFactor: 0.45, height: 18),
        SizedBox(height: RaeedSpacing.sm),
        SkeletonLine(widthFactor: 0.3),
        SizedBox(height: RaeedSpacing.lg),
        SkeletonBox(width: double.infinity, height: 88),
      ],
    ),
  );
}
