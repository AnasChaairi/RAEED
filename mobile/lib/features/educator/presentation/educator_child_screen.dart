import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/brand_gradient.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../children/domain/child_age.dart';
import '../../executive/presentation/executive_child_screen.dart'
    show HealthSection;
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../../executive/presentation/widgets/image_rights_dot.dart';
import '../../executive/presentation/widgets/tone_chip.dart';
import '../domain/educator_child.dart';
import 'educator_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-06 — a child in the educator's group. The health text is behind
/// the recorded-view confirm; a guardian is reached through the thread or
/// a recorded emergency call whose number never renders.
class EducatorChildScreen extends ConsumerWidget {
  const EducatorChildScreen({
    required this.childId,
    this.now,
    this.dial,
    super.key,
  });

  final String childId;
  final DateTime? now;

  /// Injectable so tests never open the dialer.
  final Future<void> Function(String phone)? dial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final profile = ref.watch(educatorChildProfileProvider(childId));

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
                    ref.invalidate(educatorChildProfileProvider(childId)),
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
                  _GuardiansCard(profile: data, dial: dial),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  const _NotesCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _back(BuildContext context) => context.canPop()
      ? context.pop()
      : context.go(AppRoutes.homeTabPath('groups'));
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.onBack});

  final EducatorChildProfile? profile;
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
            if (loaded.schoolLevel != null) loaded.schoolLevel!,
            if (loaded.group != null) loaded.group!.name,
          ].join(' · ');

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
                      child: _Tile(
                        value: loaded.seasonAttendance == null
                            ? '—'
                            : '${loaded.seasonAttendance!.present}/${loaded.seasonAttendance!.expected}',
                        label: l10n.statAttendance,
                      ),
                    ),
                    const SizedBox(width: RaeedSpacing.sm),
                    Expanded(
                      flex: 10,
                      child: _Tile(
                        value: '${loaded.homeworkDone}/${loaded.homeworkTotal}',
                        label: l10n.eduChildHomeworkTile,
                      ),
                    ),
                    const SizedBox(width: RaeedSpacing.sm),
                    Expanded(
                      flex: 13,
                      child: _Tile(
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

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final on = context.palette.primaryOn;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.sm,
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

class _GuardiansCard extends ConsumerWidget {
  const _GuardiansCard({required this.profile, required this.dial});

  final EducatorChildProfile profile;
  final Future<void> Function(String phone)? dial;

  Future<void> _call(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final call = await ref
          .read(educatorChildrenRepositoryProvider)
          .emergencyCall(profile.id);
      final phone = call.phone;
      if (phone == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.guardianCallUnavailable)),
        );
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.guardianCallToast)));
      // The number goes to the dialer and is never rendered by this app.
      if (dial != null) {
        await dial!(phone);
      } else {
        await launchUrl(Uri(scheme: 'tel', path: phone));
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    // The designated emergency contact, else the first guardian linked —
    // someone must be reachable when a child needs their family now.
    final callTarget =
        profile.guardians.where((g) => g.isEmergencyContact).firstOrNull ??
        profile.guardians.firstOrNull;
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
          for (final guardian in profile.guardians)
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
                                    ' · ${guardian.isEmergencyContact ? l10n.guardianEmergency : relationshipLabel(l10n, guardian.relationship)}',
                                style: context.type.caption.copyWith(
                                  color: palette.inkDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          guardian == callTarget
                              ? l10n.guardianEmergencyHint
                              : guardian.account == AccountStatus.active
                              ? l10n.guardianAccountActive
                              : l10n.guardianAccountPending,
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: RaeedSpacing.sm),
                  if (guardian == callTarget)
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: palette.dangerSoft,
                        foregroundColor: palette.danger,
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () => _call(context, ref),
                      child: Text(l10n.guardianCall),
                    )
                  else if (profile.conversationId != null)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        backgroundColor: palette.bg,
                      ),
                      onPressed: () => context.push(
                        AppRoutes.conversationPath(profile.conversationId!),
                      ),
                      child: Text(l10n.guardianMessage),
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
              onPressed: () => context.push(
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

class _NotesCard extends StatefulWidget {
  const _NotesCard();

  @override
  State<_NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<_NotesCard> {
  bool _staff = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ExecutiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.notesTitle,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ToneChip(label: l10n.notesPhase2, tone: ChipTone.accent),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          SegmentedChoice<bool>(
            values: const [true, false],
            selected: _staff,
            labelOf: (staff) => staff ? l10n.notesStaff : l10n.notesShared,
            onSelect: (staff) => setState(() => _staff = staff),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          Text(
            _staff ? l10n.notesStaffBody : l10n.notesSharedBody,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        ],
      ),
    );
  }
}

String relationshipLabel(AppL10n l10n, String relationship) =>
    switch (relationship) {
      'mother' || 'الأم' => l10n.relMother,
      'father' || 'الأب' => l10n.relFather,
      _ => l10n.relGuardian,
    };
