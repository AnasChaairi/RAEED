import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/brand_gradient.dart';
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
        // No AppBar: the gradient identity band *is* the header, and an app bar
        // above it would be a second, competing one.
        //
        // Nested rather than a plain Column so the header and the health record
        // scroll away under a pinned tab bar. A health record is unbounded —
        // allergies, conditions, medication, diet — and a fixed header would
        // eventually leave the tabs no room at all.
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: _ProfileHeader(child: child)),
            if (child.summary.healthAlert || child.health.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    RaeedSpacing.lg,
                    RaeedSpacing.lg,
                    RaeedSpacing.lg,
                    0,
                  ),
                  child: _HealthSection(child: child),
                ),
              ),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              backgroundColor: palette.surface,
              surfaceTintColor: Colors.transparent,
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: palette.primary,
                unselectedLabelColor: palette.inkDim,
                indicatorColor: palette.primary,
                dividerColor: palette.border,
                tabs: [
                  for (final tab in ChildProfileTab.values)
                    Tab(text: _tabLabel(l10n, tab)),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              for (final tab in ChildProfileTab.values)
                _TabPlaceholder(tab: tab),
            ],
          ),
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

/// The design's identity band: the photo, the name, and the two facts that
/// place the child — their group and their age.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.child});

  final ChildDetail child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final dob = child.summary.dateOfBirth;
    final age = dob == null ? null : ageInYearsOn(dob, DateTime.now());

    return BrandGradient(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(RaeedRadius.xl2),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.sm,
            RaeedSpacing.sm,
            RaeedSpacing.lg,
            RaeedSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                // Mirrors under Directionality, as a back chevron must.
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  color: palette.primaryOn,
                  tooltip: l10n.commonBack,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: RaeedSpacing.sm,
                ),
                child: Row(
                  children: [
                    _ProfileAvatar(child: child),
                    const SizedBox(width: RaeedSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.summary.fullName,
                            style: context.type.h2.copyWith(
                              color: palette.primaryOn,
                            ),
                          ),
                          const SizedBox(height: RaeedSpacing.sm),
                          Wrap(
                            spacing: RaeedSpacing.sm,
                            runSpacing: RaeedSpacing.xs,
                            children: [
                              if (child.summary.group != null)
                                _HeaderChip(
                                  label:
                                      '${l10n.childProfileGroupLabel}: '
                                      '${child.summary.group!.name}',
                                ),
                              if (age != null)
                                _HeaderChip(label: l10n.childAgeYears(age)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A translucent chip on the gradient. Drawn from `primaryOn` rather than a
/// palette surface: on a gradient there is no surface token that is correct.
class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.sm,
        vertical: RaeedSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.primaryOn.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RaeedRadius.sm),
        border: Border.all(color: palette.primaryOn.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: context.type.caption.copyWith(
          color: palette.primaryOn.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.child});

  final ChildDetail child;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final photoUrl = child.summary.photoUrl;
    final name = child.summary.fullName;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RaeedRadius.xl2),
        border: Border.all(
          color: palette.primaryOn.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RaeedRadius.xl),
        child: photoUrl == null || photoUrl.isEmpty
            ? ColoredBox(
                color: palette.primaryOn.withValues(alpha: 0.15),
                child: Center(
                  child: Text(
                    name.trim().isEmpty ? '؟' : name.trim().characters.first,
                    style: context.type.h1.copyWith(color: palette.primaryOn),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => ColoredBox(
                  color: palette.primaryOn.withValues(alpha: 0.15),
                ),
                errorWidget: (_, _, _) => ColoredBox(
                  color: palette.primaryOn.withValues(alpha: 0.15),
                ),
              ),
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
    // Labelled by category rather than run together: "peanuts" under
    // "allergies" and "peanuts" under "dietary notes" mean different things to
    // an educator holding an epi-pen, and a flat list loses that distinction.
    final sections = <(String, List<String>)>[
      (l10n.childHealthAllergies, health.allergies),
      (l10n.childHealthConditions, health.conditions),
      (l10n.childHealthMedications, health.medications),
      (
        l10n.childHealthDiet,
        [if (health.dietaryNotes != null) health.dietaryNotes!],
      ),
      // Keys this build does not know about, kept visible rather than dropped.
      (l10n.childHealthOther, health.otherNotes.values.toList()),
    ].where((section) => section.$2.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(RaeedRadius.xl2),
        border: Border.all(color: palette.accentDecorative),
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
              Flexible(
                child: Text(
                  l10n.childProfileHealthTitle,
                  style: context.type.label.copyWith(color: palette.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.md),
          if (sections.isEmpty)
            Text(
              l10n.childProfileNoHealthInfo,
              style: context.type.bodySmall.copyWith(color: palette.ink),
            )
          else
            for (final section in sections) ...[
              if (section != sections.first)
                const SizedBox(height: RaeedSpacing.md),
              Text(
                section.$1,
                style: context.type.caption.copyWith(color: palette.accent),
              ),
              const SizedBox(height: RaeedSpacing.xs),
              for (final entry in section.$2)
                Padding(
                  padding: const EdgeInsets.only(bottom: RaeedSpacing.xs),
                  child: Text(
                    entry,
                    style: context.type.body.copyWith(color: palette.ink),
                  ),
                ),
            ],
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
