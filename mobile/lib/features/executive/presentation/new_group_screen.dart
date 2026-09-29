import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../domain/family.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'manage_screen.dart' show ManageTab;
import 'widgets/section_header.dart';

/// EXEC-M-10 — the new-group form (`/manage/groups/new`).
class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  GroupDraft _draft = const GroupDraft();
  bool _saving = false;

  void _update(GroupDraft next) => setState(() => _draft = next);

  Future<void> _create() async {
    if (!_draft.isComplete || _saving) return;
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      final group = await ref
          .read(familiesRepositoryProvider)
          .createGroup(_draft);
      ref.invalidate(executiveGroupsProvider);
      ref.invalidate(unassignedChildrenProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.groupCreatedToast(group.name)} · ⦿ ${l10n.recordedShort}',
          ),
        ),
      );
      router.go(AppRoutes.manageTabPath(ManageTab.groups.slug));
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
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final educators = ref.watch(educatorsProvider).value ?? const [];
    final unassigned = ref.watch(unassignedChildrenProvider).value ?? const [];
    final checklist = [
      _draft.hasName ? l10n.checklistNameOk : l10n.checklistNameMissing,
      if (_draft.categoryId == null) l10n.checklistCategoryMissing,
      _draft.educatorIds.isNotEmpty
          ? l10n.checklistEducatorOk
          : l10n.checklistEducatorMissing,
      l10n.checklistChildren(_draft.childIds.length),
      l10n.checklistLogged,
    ].join(' · ');

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: context.type.caption.copyWith(
          color: palette.inkDim,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            SectionHeader(
              title: l10n.newGroupTitle,
              fallbackRoute: AppRoutes.manage,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RaeedSpacing.lg),
                children: [
                  label(l10n.fieldName),
                  TextField(
                    onChanged: (v) => _update(_draft.copyWith(name: v)),
                    decoration: InputDecoration(
                      hintText: l10n.groupNameHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  label(l10n.fieldCategory),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final category in categories)
                        FilterPill(
                          label: category.name,
                          selected: _draft.categoryId == category.id,
                          onTap: () =>
                              _update(_draft.copyWith(categoryId: category.id)),
                        ),
                    ],
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  label(l10n.fieldCapacity),
                  _Stepper(
                    value: _draft.capacity,
                    onChanged: (v) => _update(_draft.copyWith(capacity: v)),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  label(l10n.fieldEducators),
                  for (final educator in educators) ...[
                    _ToggleRow(
                      title: educator.displayName,
                      trailing: l10n.educatorLoad(educator.groupCount),
                      selected: _draft.educatorIds.contains(educator.id),
                      onTap: () => _update(
                        _draft.copyWith(
                          educatorIds: _toggled(
                            _draft.educatorIds,
                            educator.id,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: RaeedSpacing.sm),
                  label(l10n.fieldChildrenOptional),
                  for (final child in unassigned) ...[
                    _ToggleRow(
                      title: child.fullName,
                      selected: _draft.childIds.contains(child.id),
                      checkbox: true,
                      onTap: () => _update(
                        _draft.copyWith(
                          childIds: _toggled(_draft.childIds, child.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: RaeedSpacing.sm),
                  Text(
                    checklist,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                ],
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
              child: FilledButton(
                onPressed: _draft.isComplete && !_saving ? _create : null,
                child: Text(
                  '${l10n.createGroupCta(_draft.hasName ? _draft.name.trim() : l10n.theGroup)} · ⦿',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Set<String> _toggled(Set<String> set, String id) {
    final next = Set<String>.of(set);
    if (!next.remove(id)) next.add(id);
    return next;
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        border: Border.all(color: palette.border, width: 1.5),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > 4 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
            color: palette.primary,
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: context.type
                  .tabular(context.type.label)
                  .copyWith(color: palette.ink, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: value < 40 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
            color: palette.primary,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.selected,
    required this.onTap,
    this.trailing,
    this.checkbox = false,
  });

  final String title;
  final String? trailing;
  final bool selected;
  final bool checkbox;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: selected ? palette.primarySoft : palette.surface,
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: RaeedTouchTarget.minPx,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: checkbox ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: checkbox ? BorderRadius.circular(5) : null,
                      color: selected ? palette.primary : Colors.transparent,
                      border: Border.all(
                        color: selected ? palette.primary : palette.inkDim,
                        width: 2,
                      ),
                    ),
                    child: selected && checkbox
                        ? Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: palette.primaryOn,
                          )
                        : null,
                  ),
                  const SizedBox(width: RaeedSpacing.sm + 2),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        title,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (trailing != null)
                    ExcludeSemantics(
                      child: Text(
                        trailing!,
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
