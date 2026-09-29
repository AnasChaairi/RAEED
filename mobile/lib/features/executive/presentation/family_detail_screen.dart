import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/api_error_code.dart';
import '../../../core/error/raeed_exception.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/family.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/child_form_sheet.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_confirm_sheet.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/family_fields.dart';
import 'widgets/guardian_form_sheet.dart';
import 'widgets/password_handover_dialog.dart';
import 'widgets/section_header.dart';
import 'widgets/tone_chip.dart';

/// EXEC-M-10b — one household (`/manage/families/:familyId`).
///
/// Everything a family needs after it was created: correct a guardian, link
/// a second one, unlink one, add a child, fix a child's name or birth date.
/// The family's id is its guardian set, so every mutation returns the
/// household as it now is and the page keeps that, not the route's id.
class FamilyDetailScreen extends ConsumerStatefulWidget {
  const FamilyDetailScreen({
    required this.familyId,
    this.initial,
    this.openAddChild = false,
    super.key,
  });

  final String familyId;

  /// The family the card showed, rendered at once while the fetch runs.
  final Family? initial;

  /// Open the add-child sheet on arrival (the card's "+ طفل").
  final bool openAddChild;

  @override
  ConsumerState<FamilyDetailScreen> createState() => _FamilyDetailScreenState();
}

class _FamilyDetailScreenState extends ConsumerState<FamilyDetailScreen> {
  bool _openedAddChild = false;

  @override
  void initState() {
    super.initState();
    if (widget.openAddChild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final family = _current;
        if (family != null && mounted) _addChild(family);
      });
    }
  }

  Family? get _current =>
      ref.read(familyDetailProvider(widget.familyId)).value ?? widget.initial;

  FamilyDetail get _notifier =>
      ref.read(familyDetailProvider(widget.familyId).notifier);

  void _toast(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _editGuardian(Family family, FamilyGuardian guardian) async {
    final next = await GuardianFormSheet.showEdit(
      context,
      familyId: family.id,
      guardian: guardian,
    );
    if (next == null || !mounted) return;
    _notifier.apply(next);
    _toast(AppL10n.of(context).familyGuardianUpdated);
  }

  Future<void> _addGuardian(Family family) async {
    final added = await GuardianFormSheet.showAdd(context, familyId: family.id);
    if (added == null || !mounted) return;
    _notifier.apply(added.family);
    final l10n = AppL10n.of(context);
    if (added.credential.password != null) {
      // The one place the first password ever appears.
      await showPasswordHandover(context, guardians: [added.credential]);
      if (!mounted) return;
      _toast(l10n.familyGuardianLinked);
    } else {
      _toast(l10n.familyGuardianLinkedExisting);
    }
  }

  Future<void> _unlinkGuardian(Family family, FamilyGuardian guardian) async {
    final l10n = AppL10n.of(context);
    final confirmed = await ExecutiveConfirmSheet.show(
      context,
      weight: ConfirmWeight.irreversible,
      kind: l10n.familyUnlinkGuardian,
      title: l10n.familyUnlinkConfirmTitle(guardian.displayName),
      body: l10n.familyUnlinkConfirmBody,
      recordedText: l10n.familyUnlinkRecorded,
      confirmLabel: l10n.familyUnlinkCta,
    );
    if (!confirmed || !mounted) return;
    try {
      final next = await ref
          .read(familiesRepositoryProvider)
          .unlinkGuardian(familyId: family.id, guardianId: guardian.id);
      if (!mounted) return;
      _notifier.apply(next);
      _toast(l10n.familyUnlinkDone);
    } on Object catch (error) {
      if (!mounted) return;
      _toast(presentFailure(error, l10n).body);
    }
  }

  Future<void> _editChild(Family family, FamilyChild child) async {
    final next = await ChildFormSheet.showEdit(
      context,
      familyId: family.id,
      child: child,
    );
    if (next == null || !mounted) return;
    _notifier.apply(next);
    _toast(AppL10n.of(context).familyChildUpdated);
  }

  Future<void> _addChild(Family family) async {
    if (_openedAddChild && widget.openAddChild) return;
    _openedAddChild = true;
    final added = await ChildFormSheet.showAdd(context, familyId: family.id);
    if (added == null || !mounted) return;
    _notifier.apply(added.family);
    ref.invalidate(executiveGroupsProvider);
    _toast(AppL10n.of(context).familyChildAdded);
  }

  Future<void> _resend(Family family) async {
    final l10n = AppL10n.of(context);
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
      if (!mounted) return;
      await showPasswordHandover(context, guardians: credentials);
    } on Object catch (error) {
      if (!mounted) return;
      _toast(presentFailure(error, l10n).body);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final detail = ref.watch(familyDetailProvider(widget.familyId));
    // Whatever is newest: the fetched household, else the one the card
    // pushed while the fetch is still running.
    final family = detail.value ?? (detail.isLoading ? widget.initial : null);

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            SectionHeader(
              title: family?.label ?? l10n.manageTabFamilies,
              subtitle: family == null
                  ? null
                  : l10n.familyDetailSubtitle(
                      family.guardians.length,
                      family.children.length,
                    ),
              fallbackRoute: AppRoutes.manageTabPath('families'),
              trailing: family == null
                  ? null
                  : familyStatusChip(l10n, family.status),
            ),
            Expanded(
              child: switch ((family, detail)) {
                (final Family family, _) => _Body(
                  family: family,
                  onEditGuardian: (g) => _editGuardian(family, g),
                  onUnlinkGuardian: (g) => _unlinkGuardian(family, g),
                  onAddGuardian: () => _addGuardian(family),
                  onResend: family.canResendInvitation
                      ? () => _resend(family)
                      : null,
                  onEditChild: (c) => _editChild(family, c),
                  onAddChild: () => _addChild(family),
                ),
                (null, AsyncError(:final error)) => _errorView(error),
                _ => const SkeletonCardList(count: 2, height: 160),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(Object error) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    // Out of scope, or its guardians changed elsewhere: the id names nothing
    // any more. A retry would only repeat that, so offer the list instead.
    if (error case ApiException(code: ApiErrorCode.scopeForbidden)) {
      return Padding(
        padding: const EdgeInsets.all(RaeedSpacing.lg),
        child: ExecutiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.familyNotFoundTitle,
                style: context.type.label.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: RaeedSpacing.xs),
              Text(
                l10n.familyNotFoundBody,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
              const SizedBox(height: RaeedSpacing.md),
              OutlinedButton(
                onPressed: () =>
                    context.go(AppRoutes.manageTabPath('families')),
                child: Text(l10n.familyBackToList),
              ),
            ],
          ),
        ),
      );
    }
    return RaeedErrorView(error: error, onRetry: _notifier.refresh);
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.family,
    required this.onEditGuardian,
    required this.onUnlinkGuardian,
    required this.onAddGuardian,
    required this.onResend,
    required this.onEditChild,
    required this.onAddChild,
  });

  final Family family;
  final ValueChanged<FamilyGuardian> onEditGuardian;
  final ValueChanged<FamilyGuardian> onUnlinkGuardian;
  final VoidCallback onAddGuardian;
  final VoidCallback? onResend;
  final ValueChanged<FamilyChild> onEditChild;
  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.sm,
        RaeedSpacing.lg,
        RaeedSpacing.xl2,
      ),
      children: [
        _Section(
          title: l10n.familyGuardiansSection,
          footer: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (onResend != null)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    foregroundColor: palette.ink,
                  ),
                  onPressed: onResend,
                  child: Text(l10n.familyResend),
                ),
              OutlinedButton(
                key: const Key('family-add-guardian'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                onPressed: onAddGuardian,
                child: Text(l10n.familyAddGuardian),
              ),
            ],
          ),
          children: [
            for (final guardian in family.guardians)
              _GuardianRow(
                guardian: guardian,
                // The last guardian cannot go: the server refuses it, and
                // the button is not offered rather than offered to fail.
                canUnlink: family.guardians.length > 1,
                onEdit: () => onEditGuardian(guardian),
                onUnlink: () => onUnlinkGuardian(guardian),
              ),
          ],
        ),
        const SizedBox(height: RaeedSpacing.sm + 2),
        _Section(
          title: l10n.familyChildrenSection,
          footer: OutlinedButton(
            key: const Key('family-add-child'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
            onPressed: onAddChild,
            child: Text(l10n.familyAddChild),
          ),
          children: [
            for (final child in family.children)
              _ChildRow(
                child: child,
                subtitle: [if (child.dob != null) fullDate(locale, child.dob!)]
                    .join(' · '),
                onOpen: () => context.push(AppRoutes.childPath(child.id)),
                onEdit: () => onEditChild(child),
              ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    required this.footer,
  });

  final String title;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.type.label.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: RaeedSpacing.xs),
          for (final (index, child) in children.indexed) ...[
            if (index > 0) Divider(height: 1, color: palette.border),
            child,
          ],
          const SizedBox(height: RaeedSpacing.sm + 2),
          footer,
        ],
      ),
    );
  }
}

class _GuardianRow extends StatelessWidget {
  const _GuardianRow({
    required this.guardian,
    required this.canUnlink,
    required this.onEdit,
    required this.onUnlink,
  });

  final FamilyGuardian guardian;
  final bool canUnlink;
  final VoidCallback onEdit;
  final VoidCallback onUnlink;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final account = guardian.account == AccountStatus.active
        ? ToneChip(label: l10n.guardianAccountActive, tone: ChipTone.success)
        : ToneChip(label: l10n.guardianAccountPending, tone: ChipTone.warning);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RaeedSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${guardian.displayName} · '
                  '${relationshipLabel(l10n, guardian.relationship)}',
                  style: context.type.label.copyWith(color: palette.ink),
                ),
                const SizedBox(height: RaeedSpacing.xs),
                Row(
                  children: [
                    account,
                    if (guardian.phoneHint != null) ...[
                      const SizedBox(width: RaeedSpacing.sm),
                      Text(
                        guardian.phoneHint!,
                        textDirection: TextDirection.ltr,
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('edit-guardian-${guardian.id}'),
            tooltip: l10n.familyEditGuardian,
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, color: palette.inkDim),
          ),
          if (canUnlink)
            IconButton(
              key: Key('unlink-guardian-${guardian.id}'),
              tooltip: l10n.familyUnlinkGuardian,
              onPressed: onUnlink,
              icon: Icon(Icons.person_remove_outlined, color: palette.danger),
            ),
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.child,
    required this.subtitle,
    required this.onOpen,
    required this.onEdit,
  });

  final FamilyChild child;
  final String subtitle;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RaeedSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: context.type.label.copyWith(color: palette.ink),
                  ),
                  const SizedBox(height: RaeedSpacing.xs),
                  Row(
                    children: [
                      ToneChip(
                        label: child.group?.name ?? l10n.familyNoGroup,
                        tone: child.group == null
                            ? ChipTone.warning
                            : ChipTone.primary,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(width: RaeedSpacing.sm),
                        Text(
                          subtitle,
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('edit-child-${child.id}'),
              tooltip: l10n.familyEditChild,
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: palette.inkDim),
            ),
          ],
        ),
      ),
    );
  }
}
