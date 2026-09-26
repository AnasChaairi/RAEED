import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../children/domain/child_age.dart';
import '../domain/executive_child.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/image_rights_dot.dart';
import 'widgets/tone_chip.dart';

/// EXEC-M-09 — a child, as the executive sees them (`/children/:id`).
///
/// Two reads on this screen are deliberate and recorded, and the screen
/// makes both visible: the health text appears only after a confirm that
/// names the person and the child and says the view will be logged, and a
/// guardian's phone stays masked until tapped, which is logged too. Nothing
/// about either is fetched with the profile.
class ExecutiveChildScreen extends ConsumerWidget {
  const ExecutiveChildScreen({required this.childId, this.now, super.key});

  final String childId;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final profile = ref.watch(executiveChildProfileProvider(childId));

    return Scaffold(
      backgroundColor: palette.bg,
      body: profile.when(
        loading: () => Column(
          children: [
            _Header(profile: null, onBack: () => _back(context)),
            const Expanded(child: SkeletonCardList(count: 3, height: 120)),
          ],
        ),
        error: (error, _) => Column(
          children: [
            _Header(profile: null, onBack: () => _back(context)),
            Expanded(
              child: RaeedErrorView(
                error: error,
                onRetry: () =>
                    ref.invalidate(executiveChildProfileProvider(childId)),
              ),
            ),
          ],
        ),
        data: (data) => Column(
          children: [
            _Header(profile: data, onBack: () => _back(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RaeedSpacing.lg,
                  RaeedSpacing.md + 2,
                  RaeedSpacing.lg,
                  RaeedSpacing.xl2,
                ),
                children: [
                  HealthSection(
                    childId: data.id,
                    childName: data.fullName,
                    hasHealthAlert: data.hasHealthAlert,
                    now: now ?? DateTime.now(),
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  GuardiansSection(profile: data, now: now ?? DateTime.now()),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  _ConsentsSection(profile: data),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  _GroupsSection(profile: data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(AppRoutes.childrenList);
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.onBack});

  final ExecutiveChildProfile? profile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final on = palette.primaryOn;
    final loaded = profile;
    final age = loaded?.dateOfBirth == null
        ? null
        : ageInYearsOn(loaded!.dateOfBirth!, DateTime.now());
    final meta = loaded == null
        ? ''
        : [
            if (age != null) l10n.childAgeYears(age),
            if (loaded.mainGroup != null) loaded.mainGroup!.name,
            if (loaded.schoolLevel != null) loaded.schoolLevel!,
          ].join(' · ');
    final attendance = loaded?.seasonAttendance;

    return BrandGradient(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(RaeedRadius.xl2 + 4),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.sm,
            RaeedSpacing.xs,
            RaeedSpacing.lg,
            RaeedSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  BackButton(color: on, onPressed: onBack),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: on.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(RaeedRadius.xl),
                    ),
                    child: Icon(Icons.person_outline_rounded, color: on),
                  ),
                  const SizedBox(width: RaeedSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loaded?.fullName ?? '',
                          style: context.type.h2.copyWith(color: on),
                        ),
                        Text(
                          meta,
                          style: context.type
                              .tabular(context.type.caption)
                              .copyWith(color: on.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (loaded != null) ...[
                const SizedBox(height: RaeedSpacing.md + 2),
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: _HeaderTile(
                        value: attendance == null
                            ? '—'
                            : '${attendance.present}/${attendance.expected}',
                        label: l10n.childSeasonAttendance,
                      ),
                    ),
                    const SizedBox(width: RaeedSpacing.sm),
                    Expanded(
                      flex: 14,
                      child: _HeaderTile(
                        value: ImageRightsDot.label(l10n, loaded.imageRights),
                        icon: ImageRightsDot.icon(loaded.imageRights),
                        label: l10n.childImageRightsTile,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderTile extends StatelessWidget {
  const _HeaderTile({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final on = context.palette.primaryOn;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md,
        vertical: RaeedSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: on.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: on),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  style: context.type
                      .tabular(context.type.label)
                      .copyWith(color: on, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: context.type.caption.copyWith(
              color: on.withValues(alpha: 0.8),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsed → the "this will be recorded" confirm → revealed.
class HealthSection extends ConsumerStatefulWidget {
  const HealthSection({
    required this.childId,
    required this.childName,
    required this.hasHealthAlert,
    required this.now,
    super.key,
  });

  /// Shared by the executive's and the educator's child screens: both read
  /// the text through the same logged route.
  final String childId;
  final String childName;
  final bool hasHealthAlert;
  final DateTime now;

  @override
  ConsumerState<HealthSection> createState() => _HealthSectionState();
}

enum _HealthStep { collapsed, confirming, revealed }

class _HealthSectionState extends ConsumerState<HealthSection> {
  _HealthStep _step = _HealthStep.collapsed;
  HealthReveal? _reveal;
  bool _loading = false;

  Future<void> _show() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      final reveal = await ref
          .read(executiveChildrenRepositoryProvider)
          .revealHealth(widget.childId);
      if (!mounted) return;
      setState(() {
        _reveal = reveal;
        _step = _HealthStep.revealed;
      });
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
      setState(() => _step = _HealthStep.collapsed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final actor = ref.watch(
      sessionControllerProvider.select((s) => s.user?.displayName ?? ''),
    );

    return ExecutiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: widget.hasHealthAlert
                      ? palette.danger
                      : palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(RaeedRadius.sm + 2),
                ),
                child: Icon(
                  Icons.priority_high_rounded,
                  size: 14,
                  color: widget.hasHealthAlert
                      ? palette.surface
                      : palette.inkDim,
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              Expanded(
                child: Text(
                  l10n.healthSectionTitle,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ToneChip(
                label: l10n.healthEveryViewLogged,
                tone: ChipTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm + 2),
          if (!widget.hasHealthAlert)
            Text(
              l10n.healthNoneBody,
              style: context.type.caption.copyWith(color: palette.inkDim),
            )
          else
            switch (_step) {
              _HealthStep.collapsed => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.healthCollapsedBody,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () =>
                        setState(() => _step = _HealthStep.confirming),
                    child: Text(l10n.healthShowButton),
                  ),
                ],
              ),
              _HealthStep.confirming => Container(
                padding: const EdgeInsets.all(RaeedSpacing.md),
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(RaeedRadius.lg),
                  border: Border.all(color: palette.primary, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          size: 14,
                          color: palette.ink,
                        ),
                        const SizedBox(width: RaeedSpacing.xs),
                        Text(
                          l10n.healthConfirmTitle,
                          style: context.type.label.copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RaeedSpacing.xs),
                    Text(
                      l10n.healthConfirmBody(actor, widget.childName),
                      style: context.type.caption.copyWith(color: palette.ink),
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                            ),
                            onPressed: _loading ? null : _show,
                            child: Text(l10n.healthContinue),
                          ),
                        ),
                        const SizedBox(width: RaeedSpacing.sm),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            foregroundColor: palette.ink,
                          ),
                          onPressed: () =>
                              setState(() => _step = _HealthStep.collapsed),
                          child: Text(l10n.healthBack),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _HealthStep.revealed => Container(
                padding: const EdgeInsets.all(RaeedSpacing.md),
                decoration: BoxDecoration(
                  color: palette.dangerSoft,
                  borderRadius: BorderRadius.circular(RaeedRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.healthAlertTitle,
                            style: context.type.label.copyWith(
                              color: palette.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '⦿ ${l10n.healthRecordedAt(clockTime(locale, _reveal!.viewedAt))}',
                          style: context.type
                              .tabular(context.type.caption)
                              .copyWith(color: palette.inkDim, fontSize: 10.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: RaeedSpacing.xs),
                    ..._healthLines(l10n, _reveal!).map(
                      (line) => Text(
                        line,
                        style: context.type.bodySmall.copyWith(
                          color: palette.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.sm + 2,
                        vertical: RaeedSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(RaeedRadius.md),
                        border: Border.all(color: palette.border, width: 1.5),
                      ),
                      child: Text(
                        l10n.healthFieldsPending,
                        style: context.type.caption.copyWith(
                          color: palette.inkDim,
                        ),
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        backgroundColor: palette.surface,
                        foregroundColor: palette.ink,
                      ),
                      onPressed: () =>
                          setState(() => _step = _HealthStep.collapsed),
                      child: Text(l10n.healthCollapse),
                    ),
                  ],
                ),
              ),
            },
        ],
      ),
    );
  }

  static List<String> _healthLines(AppL10n l10n, HealthReveal reveal) {
    final health = reveal.health;
    return [
      if (health.allergies.isNotEmpty)
        '${l10n.healthAllergies}: ${health.allergies.join('، ')}',
      if (health.conditions.isNotEmpty)
        '${l10n.healthConditions}: ${health.conditions.join('، ')}',
      if (health.medications.isNotEmpty)
        '${l10n.healthMedications}: ${health.medications.join('، ')}',
      if (health.dietaryNotes != null)
        '${l10n.healthDietary}: ${health.dietaryNotes}',
      for (final entry in health.otherNotes.entries)
        '${entry.key}: ${entry.value}',
      if (reveal.specialNeedsNotes != null)
        '${l10n.healthSpecialNeeds}: ${reveal.specialNeedsNotes}',
    ];
  }
}

/// Guardians with account status and the logged phone reveal.
class GuardiansSection extends ConsumerStatefulWidget {
  const GuardiansSection({required this.profile, required this.now, super.key});

  final ExecutiveChildProfile profile;
  final DateTime now;

  @override
  ConsumerState<GuardiansSection> createState() => _GuardiansSectionState();
}

class _GuardiansSectionState extends ConsumerState<GuardiansSection> {
  final Map<String, String?> _revealed = {};

  Future<void> _reveal(GuardianSummary guardian) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final reveal = await ref
          .read(executiveChildrenRepositoryProvider)
          .revealPhone(childId: widget.profile.id, guardianId: guardian.id);
      if (!mounted) return;
      setState(() => _revealed[guardian.id] = reveal.phone);
      messenger.showSnackBar(
        SnackBar(content: Text('⦿ ${l10n.guardianRevealToast}')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);

    return ExecutiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.guardiansTitle,
            style: context.type.label.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final guardian in widget.profile.guardians)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: RaeedSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.border)),
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
                                text: guardian.displayName,
                                style: context.type.label.copyWith(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' · ${relationshipLabel(l10n, guardian.relationship)}',
                                style: context.type.caption.copyWith(
                                  color: palette.inkDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          guardian.account == AccountStatus.active
                              ? [
                                  l10n.guardianAccountActive,
                                  if (guardian.lastSeenAt != null)
                                    l10n.guardianLastSeen(
                                      relativeTime(
                                        l10n,
                                        locale,
                                        guardian.lastSeenAt!,
                                        now: widget.now,
                                      ),
                                    ),
                                ].join(' · ')
                              : l10n.guardianAccountPending,
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: RaeedSpacing.sm),
                  if (_revealed.containsKey(guardian.id))
                    Text(
                      _revealed[guardian.id] ?? '—',
                      textDirection: TextDirection.ltr,
                      style: context.type
                          .tabular(context.type.label)
                          .copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  else
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        backgroundColor: palette.bg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: RaeedSpacing.md,
                        ),
                      ),
                      onPressed: () => _reveal(guardian),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            guardian.phoneHint ?? '••',
                            style: context.type
                                .tabular(context.type.caption)
                                .copyWith(color: palette.inkDim),
                          ),
                          const SizedBox(width: RaeedSpacing.sm),
                          Text(
                            '${l10n.guardianReveal} ⦿',
                            style: context.type.caption.copyWith(
                              color: palette.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: RaeedSpacing.xs),
          Text(
            l10n.guardianRevealLogged,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        ],
      ),
    );
  }

  static String relationshipLabel(AppL10n l10n, String relationship) =>
      switch (relationship) {
        'mother' || 'الأم' => l10n.relMother,
        'father' || 'الأب' => l10n.relFather,
        _ => l10n.relGuardian,
      };
}

class _ConsentsSection extends StatelessWidget {
  const _ConsentsSection({required this.profile});

  final ExecutiveChildProfile profile;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final privacy = profile.privacyConsents;
    final image = profile.imageRightsConsents;

    Widget row(String title, String meta, Widget chip) => Container(
      padding: const EdgeInsets.symmetric(vertical: RaeedSpacing.sm),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  meta,
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
          chip,
        ],
      ),
    );

    return ExecutiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.consentsTitle,
            style: context.type.label.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          row(
            l10n.consentPrivacyLabel,
            privacy.isEmpty
                ? '—'
                : l10n.consentVersionAt(
                    privacy.first.version,
                    shortDate(locale, privacy.first.at),
                  ),
            privacy.isEmpty
                ? ToneChip(
                    label: l10n.consentMissing,
                    tone: ChipTone.warning,
                    icon: Icons.schedule_rounded,
                  )
                : ToneChip(
                    label: l10n.consentApproved,
                    tone: ChipTone.success,
                    icon: Icons.check_rounded,
                  ),
          ),
          row(
            l10n.consentImageRightsTitle,
            image.isEmpty
                ? l10n.consentImageRightsChangeable
                : '${l10n.consentVersionAt(image.first.version, shortDate(locale, image.first.at))} · '
                      '${l10n.consentImageRightsChangeable}',
            ToneChip(
              label: ImageRightsDot.label(l10n, profile.imageRights),
              tone: switch (profile.imageRights) {
                ImageRightsLevel.allowed => ChipTone.success,
                ImageRightsLevel.appOnly => ChipTone.info,
                ImageRightsLevel.notAllowed => ChipTone.danger,
              },
              icon: ImageRightsDot.icon(profile.imageRights),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsSection extends StatelessWidget {
  const _GroupsSection({required this.profile});

  final ExecutiveChildProfile profile;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return ExecutiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.childGroupsTitle,
            style: context.type.label.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final group in profile.groups)
            Container(
              padding: const EdgeInsets.symmetric(vertical: RaeedSpacing.sm),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                group.name,
                                style: context.type.label.copyWith(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (group.isMain) ...[
                              const SizedBox(width: 6),
                              ToneChip(
                                label: l10n.groupMainTag,
                                tone: ChipTone.primary,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          [
                            if (group.educatorNames.isNotEmpty)
                              group.educatorNames.join('، '),
                            if (group.scheduleLabel != null)
                              group.scheduleLabel!,
                          ].join(' · '),
                          style: context.type
                              .tabular(context.type.caption)
                              .copyWith(color: palette.inkDim),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${group.attendance.present}/${group.attendance.expected}',
                    style: context.type
                        .tabular(context.type.label)
                        .copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          if (profile.conversationId != null) ...[
            const SizedBox(height: RaeedSpacing.sm),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
                backgroundColor: palette.bg,
              ),
              onPressed: () => context.go(
                AppRoutes.conversationPath(profile.conversationId!),
              ),
              child: Text(l10n.openChildThread(profile.fullName)),
            ),
          ],
        ],
      ),
    );
  }
}
