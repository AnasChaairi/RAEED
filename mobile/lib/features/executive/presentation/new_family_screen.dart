import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../domain/executive_group.dart';
import '../domain/family.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'manage_screen.dart' show ManageTab;
import 'relative_time.dart';
import 'widgets/executive_card.dart';
import 'widgets/password_handover_dialog.dart';
import 'widgets/section_header.dart';
import 'widgets/tone_chip.dart';

/// EXEC-M-10 — the new-family wizard (`/manage/families/new`).
///
/// Guardians → children → review. No health field anywhere: that is the
/// guardian's to enter from their own account.
class NewFamilyScreen extends ConsumerStatefulWidget {
  const NewFamilyScreen({super.key});

  @override
  ConsumerState<NewFamilyScreen> createState() => _NewFamilyScreenState();
}

class _NewFamilyScreenState extends ConsumerState<NewFamilyScreen> {
  int _step = 1;
  FamilyDraft _draft = const FamilyDraft();
  bool _saving = false;

  void _update(FamilyDraft next) => setState(() => _draft = next);

  bool get _canAdvance => switch (_step) {
    1 => _draft.guardiansComplete,
    2 => _draft.childrenComplete,
    _ => true,
  };

  Future<void> _next() async {
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }
    if (_saving) return;
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      final created = await ref
          .read(familiesRepositoryProvider)
          .createFamily(_draft);
      ref.invalidate(familiesProvider);
      ref.invalidate(unassignedChildrenProvider);
      ref.invalidate(executiveGroupsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.familyCreatedToast(created.invitations)} · ⦿'),
        ),
      );
      // The first passwords are shown once, here, before the wizard is
      // gone — there is no other way for the guardian to get them.
      if (mounted && created.guardians.any((g) => g.password != null)) {
        await showPasswordHandover(context, guardians: created.guardians);
      }
      router.go(AppRoutes.manageTabPath(ManageTab.families.slug));
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(presentFailure(error, l10n).body)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final groups = ref.watch(executiveGroupsProvider).value ?? const [];

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            SectionHeader(
              title: _step == 3 ? l10n.reviewStepTitle : l10n.newFamilyTitle,
              fallbackRoute: AppRoutes.manage,
              trailing: Text(
                l10n.stepOfThree(_step),
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(color: palette.inkDim),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.lg),
              child: Row(
                children: [
                  for (var n = 1; n <= 3; n++) ...[
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _step >= n ? palette.primary : palette.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (n < 3) const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RaeedSpacing.lg),
                children: switch (_step) {
                  1 => _guardiansStep(l10n, palette),
                  2 => _childrenStep(l10n, palette, groups),
                  _ => _reviewStep(l10n, palette, groups),
                },
              ),
            ),
            Container(
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
              child: Row(
                children: [
                  if (_step > 1) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          RaeedTouchTarget.primaryActionsPx,
                        ),
                        foregroundColor: palette.ink,
                      ),
                      onPressed: () => setState(() => _step -= 1),
                      child: Text(l10n.previous),
                    ),
                    const SizedBox(width: RaeedSpacing.sm),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: _canAdvance && !_saving ? _next : null,
                      child: Text(
                        _step == 3
                            ? l10n.createAndInvite(_draft.guardians.length)
                            : l10n.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _guardiansStep(AppL10n l10n, RaeedPalette palette) => [
    Text(
      l10n.guardiansTitle,
      style: context.type.caption.copyWith(
        color: palette.inkDim,
        fontWeight: FontWeight.w600,
      ),
    ),
    const SizedBox(height: RaeedSpacing.sm),
    for (var i = 0; i < _draft.guardians.length; i++) ...[
      _GuardianCard(
        draft: _draft.guardians[i],
        removable: _draft.guardians.length > 1,
        onChanged: (g) =>
            _update(_draft.copyWith(guardians: [..._draft.guardians]..[i] = g)),
        onRemove: () => _update(
          _draft.copyWith(guardians: [..._draft.guardians]..removeAt(i)),
        ),
      ),
      const SizedBox(height: RaeedSpacing.sm),
    ],
    OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
      ),
      onPressed: () => _update(
        _draft.copyWith(
          guardians: [..._draft.guardians, const GuardianDraft()],
        ),
      ),
      child: Text(l10n.addGuardian),
    ),
  ];

  List<Widget> _childrenStep(
    AppL10n l10n,
    RaeedPalette palette,
    List<ExecutiveGroup> groups,
  ) => [
    for (var i = 0; i < _draft.children.length; i++) ...[
      _ChildCard(
        index: i,
        draft: _draft.children[i],
        groups: groups,
        removable: _draft.children.length > 1,
        onChanged: (c) =>
            _update(_draft.copyWith(children: [..._draft.children]..[i] = c)),
        onRemove: () => _update(
          _draft.copyWith(children: [..._draft.children]..removeAt(i)),
        ),
      ),
      const SizedBox(height: RaeedSpacing.sm),
    ],
    OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
      ),
      onPressed: () => _update(
        _draft.copyWith(children: [..._draft.children, const ChildDraft()]),
      ),
      child: Text(l10n.addChild),
    ),
  ];

  List<Widget> _reviewStep(
    AppL10n l10n,
    RaeedPalette palette,
    List<ExecutiveGroup> groups,
  ) {
    final locale = Localizations.localeOf(context);
    return [
      ExecutiveCard(
        radius: RaeedRadius.lg + 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _draft.guardians.map((g) => g.displayName.trim()).join(' · '),
              style: context.type.h3.copyWith(color: palette.ink),
            ),
            Text(
              _draft.guardians
                  .map(
                    (g) =>
                        '+212 ${g.phone} (${_relLabel(l10n, g.relationship)})',
                  )
                  .join(' · '),
              textDirection: TextDirection.ltr,
              style: context.type
                  .tabular(context.type.caption)
                  .copyWith(color: palette.inkDim),
            ),
          ],
        ),
      ),
      const SizedBox(height: RaeedSpacing.sm),
      for (final child in _draft.children) ...[
        ExecutiveCard(
          radius: RaeedRadius.lg + 2,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName.trim(),
                      style: context.type.label.copyWith(
                        color: palette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      child.dateOfBirth == null
                          ? ''
                          : shortDate(locale, child.dateOfBirth!),
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: palette.inkDim),
                    ),
                  ],
                ),
              ),
              ToneChip(
                label:
                    groups
                        .where((g) => g.id == child.groupId)
                        .firstOrNull
                        ?.name ??
                    l10n.familyNoGroup,
                tone: child.groupId == null
                    ? ChipTone.warning
                    : ChipTone.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: RaeedSpacing.sm),
      ],
      Container(
        padding: const EdgeInsets.all(RaeedSpacing.md + 2),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(RaeedRadius.lg + 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.whatHappens,
              style: context.type.label.copyWith(
                color: palette.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: RaeedSpacing.xs),
            Text(
              l10n.willInvite(_draft.guardians.length),
              style: context.type.caption.copyWith(color: palette.ink),
            ),
            Text(
              l10n.willShow,
              style: context.type.caption.copyWith(color: palette.ink),
            ),
            Text(
              l10n.willLog,
              style: context.type.caption.copyWith(color: palette.ink),
            ),
          ],
        ),
      ),
      if (_draft.unassignedCount > 0) ...[
        const SizedBox(height: RaeedSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RaeedSpacing.md,
            vertical: RaeedSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: palette.warningSoft,
            borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          ),
          child: Text(
            l10n.unassignedWarn(_draft.unassignedCount),
            style: context.type.caption.copyWith(color: palette.warning),
          ),
        ),
      ],
    ];
  }

  static String _relLabel(AppL10n l10n, String relationship) =>
      switch (relationship) {
        'mother' => l10n.relMother,
        'father' => l10n.relFather,
        _ => l10n.relGuardian,
      };
}

class _GuardianCard extends StatelessWidget {
  const _GuardianCard({
    required this.draft,
    required this.removable,
    required this.onChanged,
    required this.onRemove,
  });

  final GuardianDraft draft;
  final bool removable;
  final ValueChanged<GuardianDraft> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.all(RaeedSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: draft.displayName,
                  onChanged: (v) => onChanged(draft.copyWith(displayName: v)),
                  decoration: InputDecoration(
                    hintText: l10n.guardianNameHint,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: draft.relationship,
                  items: [
                    DropdownMenuItem(
                      value: 'mother',
                      child: Text(l10n.relMother),
                    ),
                    DropdownMenuItem(
                      value: 'father',
                      child: Text(l10n.relFather),
                    ),
                    DropdownMenuItem(
                      value: 'parent',
                      child: Text(l10n.relGuardian),
                    ),
                  ],
                  onChanged: (v) => v == null
                      ? null
                      : onChanged(draft.copyWith(relationship: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          TextFormField(
            initialValue: draft.phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            onChanged: (v) => onChanged(
              draft.copyWith(phone: v.replaceAll(RegExp(r'\D'), '')),
            ),
            decoration: InputDecoration(
              prefixText: '+212 ',
              hintText: l10n.guardianPhoneHint,
              isDense: true,
            ),
          ),
          if (removable)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: palette.danger),
                onPressed: onRemove,
                child: Text(l10n.remove),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.index,
    required this.draft,
    required this.groups,
    required this.removable,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final ChildDraft draft;
  final List<ExecutiveGroup> groups;
  final bool removable;
  final ValueChanged<ChildDraft> onChanged;
  final VoidCallback onRemove;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.dateOfBirth ?? DateTime(now.year - 8, now.month, now.day),
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked != null) onChanged(draft.copyWith(dateOfBirth: picked));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.all(RaeedSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.childN(index + 1),
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (removable)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: palette.danger,
                    minimumSize: const Size(0, 32),
                  ),
                  onPressed: onRemove,
                  child: Text(l10n.remove),
                ),
            ],
          ),
          TextFormField(
            initialValue: draft.fullName,
            onChanged: (v) => onChanged(draft.copyWith(fullName: v)),
            decoration: InputDecoration(
              hintText: l10n.childNameHint,
              isDense: true,
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
              foregroundColor: palette.ink,
            ),
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.cake_outlined, size: 18),
            label: Text(
              draft.dateOfBirth == null
                  ? '${l10n.dobLabel} · ${l10n.dobPick}'
                  : shortDate(locale, draft.dateOfBirth!),
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          Text(
            l10n.mainGroupLabel,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final group in groups)
                FilterPill(
                  label:
                      group.capacity != null &&
                          group.enrolledCount >= group.capacity!
                      ? '${group.name} · ${l10n.groupFull}'
                      : group.name,
                  selected: draft.groupId == group.id,
                  onTap: () => onChanged(
                    draft.groupId == group.id
                        ? draft.copyWith(clearGroup: true)
                        : draft.copyWith(groupId: group.id),
                  ),
                ),
              FilterPill(
                label: l10n.groupLater,
                selected: draft.groupId == null,
                onTap: () => onChanged(draft.copyWith(clearGroup: true)),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.sm + 2,
              vertical: RaeedSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(RaeedRadius.md),
              border: Border.all(color: palette.border, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: palette.danger,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.priority_high_rounded,
                    size: 12,
                    color: palette.surface,
                  ),
                ),
                const SizedBox(width: RaeedSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.healthNotHere,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
