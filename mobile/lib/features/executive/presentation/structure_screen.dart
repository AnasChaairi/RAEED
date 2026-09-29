import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/authorization/raeed_role.dart';
import '../../../core/error/api_error_code.dart';
import '../../../core/error/raeed_exception.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/structure.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/admin_only_card.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_confirm_sheet.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/section_header.dart';
import 'widgets/tone_chip.dart';

enum StructureTab { seasons, categories, branches }

/// Whether an error is the server refusing a non-admin (`scope.forbidden`).
bool isForbidden(Object error) =>
    error is ApiException && error.code == ApiErrorCode.scopeForbidden;

/// The role word for the "admins only" card.
String currentRoleLabel(AppL10n l10n, RaeedRole? role) => switch (role) {
  RaeedRole.admin => l10n.roleAdmin,
  RaeedRole.executive => l10n.roleExecutive,
  RaeedRole.educator => l10n.roleEducator,
  RaeedRole.parent => l10n.roleParent,
  null => '',
};

/// EXEC-M-12 — seasons, categories, branches (`/structure`, admin).
class StructureScreen extends ConsumerStatefulWidget {
  const StructureScreen({super.key});

  @override
  ConsumerState<StructureScreen> createState() => _StructureScreenState();
}

class _StructureScreenState extends ConsumerState<StructureScreen> {
  StructureTab _tab = StructureTab.seasons;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final role = ref.watch(
      sessionControllerProvider.select((s) => s.effectiveRole),
    );
    // The seasons read is the admin gate: a non-admin's attempt is made,
    // refused and recorded, and the card below says so.
    final seasons = ref.watch(seasonsProvider);
    final forbidden = seasons.error != null && isForbidden(seasons.error!);

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: l10n.structureTitle,
              trailing: const AdminTag(),
            ),
            if (forbidden)
              Expanded(
                child: AdminOnlyCard(roleLabel: currentRoleLabel(l10n, role)),
              )
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: RaeedSpacing.lg,
                ),
                child: Row(
                  children: [
                    for (final tab in StructureTab.values) ...[
                      FilterPill(
                        label: switch (tab) {
                          StructureTab.seasons => l10n.strTabSeasons,
                          StructureTab.categories => l10n.strTabCategories,
                          StructureTab.branches => l10n.strTabBranches,
                        },
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
                  StructureTab.seasons => _SeasonsTab(seasons: seasons),
                  StructureTab.categories => const _CategoriesTab(),
                  StructureTab.branches => const _BranchesTab(),
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeasonsTab extends ConsumerStatefulWidget {
  const _SeasonsTab({required this.seasons});

  final AsyncValue<List<Season>> seasons;

  @override
  ConsumerState<_SeasonsTab> createState() => _SeasonsTabState();
}

class _SeasonsTabState extends ConsumerState<_SeasonsTab> {
  bool _adding = false;
  final _label = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _label.text.trim().length >= 2 &&
      _start != null &&
      _end != null &&
      _end!.isAfter(_start!);

  Future<void> _pick({required bool start}) async {
    final now = DateTime.now();
    final current = start ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? (start ? now : _start ?? now),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _create() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(structureRepositoryProvider)
          .createSeason(
            label: _label.text.trim(),
            startDate: _start!,
            endDate: _end!,
          );
      ref.invalidate(seasonsProvider);
      if (!mounted) return;
      setState(() {
        _adding = false;
        _start = null;
        _end = null;
      });
      _label.clear();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.seasonCreatedToast} · ⦿')),
      );
    } catch (error) {
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
    return widget.seasons.when(
      loading: () => const SkeletonCardList(count: 3, height: 90),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(seasonsProvider),
      ),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          0,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          for (final season in list) ...[
            ExecutiveCard(
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
                          season.label,
                          style: context.type
                              .tabular(context.type.h3)
                              .copyWith(color: palette.ink),
                        ),
                      ),
                      season.status == SeasonStatus.active
                          ? ToneChip(
                              label: l10n.seasonActive,
                              tone: ChipTone.success,
                              icon: Icons.circle,
                            )
                          : ToneChip(
                              label: l10n.seasonArchived,
                              tone: ChipTone.neutral,
                              icon: Icons.inventory_2_outlined,
                            ),
                    ],
                  ),
                  Text(
                    '${shortDate(locale, season.startDate)} → ${shortDate(locale, season.endDate)} · '
                    '${l10n.grpCount(season.groupCount)} · ${l10n.childrenCount(season.childCount)}',
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                  ),
                  if (season.status == SeasonStatus.active &&
                      list.length > 1) ...[
                    const SizedBox(height: RaeedSpacing.sm),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        foregroundColor: palette.ink,
                      ),
                      onPressed: () => _archive(context, ref, season),
                      child: Text(l10n.seasonArchive),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xs),
            child: Text(
              l10n.seasonsNote,
              style: context.type.caption.copyWith(color: palette.inkDim),
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          if (_adding)
            _AddForm(
              canSave: _canSave,
              onSave: _create,
              onCancel: () => setState(() => _adding = false),
              fields: [
                TextField(
                  key: const Key('season-label'),
                  controller: _label,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.seasonLabelHint,
                    isDense: true,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('season-start'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, RaeedTouchTarget.minPx),
                          foregroundColor: palette.ink,
                        ),
                        onPressed: () => _pick(start: true),
                        icon: const Icon(Icons.play_arrow_outlined, size: 18),
                        label: Text(
                          _start == null
                              ? l10n.seasonStartPick
                              : fullDate(locale, _start!),
                        ),
                      ),
                    ),
                    const SizedBox(width: RaeedSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('season-end'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, RaeedTouchTarget.minPx),
                          foregroundColor: palette.ink,
                        ),
                        onPressed: () => _pick(start: false),
                        icon: const Icon(Icons.stop_outlined, size: 18),
                        label: Text(
                          _end == null
                              ? l10n.seasonEndPick
                              : fullDate(locale, _end!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
              ),
              onPressed: () => setState(() => _adding = true),
              child: Text(l10n.newSeason),
            ),
        ],
      ),
    );
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    Season season,
  ) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await ExecutiveConfirmSheet.show(
      context,
      weight: ConfirmWeight.reversible,
      kind: l10n.archiveKind,
      title: l10n.archiveTitle(season.label),
      body: l10n.archiveBody,
      recordedText: l10n.archiveLog,
      confirmLabel: l10n.archiveCta,
    );
    if (!confirmed) return;
    try {
      await ref.read(structureRepositoryProvider).archiveSeason(season.id);
      ref.invalidate(seasonsProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.archivedToast} · ⦿')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }
}

class _CategoriesTab extends ConsumerStatefulWidget {
  const _CategoriesTab();

  @override
  ConsumerState<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<_CategoriesTab> {
  bool _adding = false;
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(structureRepositoryProvider)
          .createCategory(name: _name.text.trim());
      ref.invalidate(categoriesProvider);
      if (!mounted) return;
      setState(() => _adding = false);
      _name.clear();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.categoryCreatedToast} · ⦿')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final categories = ref.watch(categoriesProvider);
    return categories.when(
      loading: () => const SkeletonCardList(count: 5),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          0,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.md + 2,
              vertical: RaeedSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(RaeedRadius.lg),
            ),
            child: Text(
              l10n.catsOpenDecision,
              style: context.type.caption.copyWith(color: palette.ink),
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm),
          for (final category in list) ...[
            _CategoryCard(category: category),
            const SizedBox(height: RaeedSpacing.sm),
          ],
          if (_adding)
            _AddForm(
              onSave: _create,
              onCancel: () => setState(() => _adding = false),
              // Name only: the range and gender are not asked (open
              // decision #1), and a field left blank is not a decision.
              fields: [
                TextField(
                  key: const Key('category-name'),
                  controller: _name,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.categoryNameHint,
                    isDense: true,
                  ),
                ),
              ],
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
              ),
              onPressed: () => setState(() => _adding = true),
              child: Text(l10n.newCategory),
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: context.type.h3.copyWith(color: palette.ink),
                ),
                Text(
                  '${l10n.childrenCount(category.childCount)} · ${l10n.grpCount(category.groupCount)}',
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
          ToneChip(
            label: category.isRangeSet
                ? [
                    if (category.minAge != null || category.maxAge != null)
                      l10n.catAgeRange(
                        category.minAge ?? 0,
                        category.maxAge ?? 0,
                      ),
                    if (category.gender != null)
                      switch (category.gender!) {
                        CategoryGender.boys => l10n.genderBoys,
                        CategoryGender.girls => l10n.genderGirls,
                        CategoryGender.mixed => l10n.genderMixed,
                      },
                  ].join(' · ')
                : l10n.catAgeGenderUnset,
            tone: ChipTone.accent,
          ),
        ],
      ),
    );
  }
}

/// The inline add form the structure tabs share: fields, save, cancel.
class _AddForm extends StatelessWidget {
  const _AddForm({
    required this.fields,
    required this.onSave,
    required this.onCancel,
    this.canSave = true,
  });

  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool canSave;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, field) in fields.indexed) ...[
            if (index > 0) const SizedBox(height: RaeedSpacing.sm),
            field,
          ],
          const SizedBox(height: RaeedSpacing.sm + 2),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  key: const Key('structure-save'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
                  ),
                  onPressed: canSave ? onSave : null,
                  child: Text(l10n.commonSave),
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, RaeedTouchTarget.minPx),
                  foregroundColor: palette.ink,
                ),
                onPressed: onCancel,
                child: Text(l10n.dialogCancel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BranchesTab extends ConsumerStatefulWidget {
  const _BranchesTab();

  @override
  ConsumerState<_BranchesTab> createState() => _BranchesTabState();
}

class _BranchesTabState extends ConsumerState<_BranchesTab> {
  bool _adding = false;
  final _name = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(structureRepositoryProvider)
          .createBranch(
            name: _name.text.trim(),
            address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          );
      ref.invalidate(branchesProvider);
      if (!mounted) return;
      setState(() => _adding = false);
      _name.clear();
      _address.clear();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.branchCreatedToast} · ⦿')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final branches = ref.watch(branchesProvider);
    return branches.when(
      loading: () => const SkeletonCardList(count: 1, height: 80),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(branchesProvider),
      ),
      data: (list) => ListView(
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          0,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          for (final branch in list) ...[
            ExecutiveCard(
              radius: RaeedRadius.lg + 2,
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.md + 2,
                vertical: RaeedSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: context.type.h3.copyWith(color: palette.ink),
                  ),
                  Text(
                    [
                      if (branch.address != null) branch.address!,
                      ...branch.executiveNames,
                    ].join(' · '),
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm),
          ],
          if (list.length <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.xs),
              child: Text(
                l10n.branchesNote,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
            ),
          const SizedBox(height: RaeedSpacing.sm),
          if (_adding)
            ExecutiveCard(
              radius: RaeedRadius.lg + 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      hintText: l10n.branchNameHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm),
                  TextField(
                    controller: _address,
                    decoration: InputDecoration(
                      hintText: l10n.branchAddressHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              RaeedTouchTarget.minPx,
                            ),
                          ),
                          onPressed: _create,
                          child: Text(l10n.commonSave),
                        ),
                      ),
                      const SizedBox(width: RaeedSpacing.sm),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, RaeedTouchTarget.minPx),
                          foregroundColor: palette.ink,
                        ),
                        onPressed: () => setState(() => _adding = false),
                        child: Text(l10n.dialogCancel),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
              ),
              onPressed: () => setState(() => _adding = true),
              child: Text(l10n.newBranch),
            ),
        ],
      ),
    );
  }
}
