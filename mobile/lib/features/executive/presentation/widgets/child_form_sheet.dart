import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../../shared/errors/failure_presenter.dart';
import '../../domain/executive_group.dart';
import '../../domain/family.dart';
import '../announcements_tab.dart' show FilterPill;
import '../executive_providers.dart';
import '../relative_time.dart';
import 'sheet_frame.dart';

/// Add a child to a household, or correct one's name and birth date
/// (EXEC-M-10b). No health field, as in the wizard: that is the guardian's
/// to enter (`CHD-04`). The main group is offered only when adding — moving
/// a child between groups is the Unassigned tab's and the group's job.
class ChildFormSheet extends ConsumerStatefulWidget {
  const ChildFormSheet({required this.familyId, this.child, super.key});

  final String familyId;

  /// The child being corrected; null adds one.
  final FamilyChild? child;

  /// Resolves to the household as it now is, or null when cancelled.
  static Future<Family?> showEdit(
    BuildContext context, {
    required String familyId,
    required FamilyChild child,
  }) => showModalBottomSheet<Family>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChildFormSheet(familyId: familyId, child: child),
  );

  /// Resolves to what adding did, or null when cancelled.
  static Future<ChildAdded?> showAdd(
    BuildContext context, {
    required String familyId,
  }) => showModalBottomSheet<ChildAdded>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChildFormSheet(familyId: familyId),
  );

  @override
  ConsumerState<ChildFormSheet> createState() => _ChildFormSheetState();
}

class _ChildFormSheetState extends ConsumerState<ChildFormSheet> {
  late String _name = widget.child?.fullName ?? '';
  late DateTime? _dob = widget.child?.dob;
  String? _groupId;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.child != null;

  ChildPatch get _patch {
    final child = widget.child!;
    final name = _name.trim();
    return ChildPatch(
      fullName: name != child.fullName ? name : null,
      dateOfBirth: _dob != child.dob ? _dob : null,
    );
  }

  bool get _canSave {
    if (_name.trim().length < 2 || _dob == null) return false;
    return !_isEdit || !_patch.isEmpty;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 8, now.month, now.day),
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final repository = ref.read(familiesRepositoryProvider);
    try {
      final Object result;
      if (_isEdit) {
        result = await repository.updateChild(
          familyId: widget.familyId,
          childId: widget.child!.id,
          patch: _patch,
        );
      } else {
        result = await repository.addChild(
          familyId: widget.familyId,
          child: ChildDraft(
            fullName: _name,
            dateOfBirth: _dob,
            groupId: _groupId,
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = presentFailure(error, AppL10n.of(context)).body;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final groups = _isEdit
        ? const <ExecutiveGroup>[]
        : ref.watch(executiveGroupsProvider).value ?? const [];

    return SheetFrame(
      title: _isEdit ? l10n.familyEditChild : l10n.addChild,
      error: _error,
      recordedText: l10n.familyEditRecorded,
      saving: _saving,
      canSave: _canSave,
      onSave: _save,
      children: [
        TextFormField(
          key: const Key('child-name'),
          initialValue: _name,
          enabled: !_saving,
          onChanged: (v) => setState(() => _name = v),
          decoration: InputDecoration(
            hintText: l10n.childNameHint,
            isDense: true,
          ),
        ),
        const SizedBox(height: RaeedSpacing.sm),
        OutlinedButton.icon(
          key: const Key('child-dob'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
            foregroundColor: palette.ink,
          ),
          onPressed: _saving ? null : _pickDate,
          icon: const Icon(Icons.cake_outlined, size: 18),
          label: Text(
            _dob == null
                ? '${l10n.dobLabel} · ${l10n.dobPick}'
                : fullDate(locale, _dob!),
          ),
        ),
        if (!_isEdit) ...[
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
                  selected: _groupId == group.id,
                  onTap: () => setState(
                    () => _groupId = _groupId == group.id ? null : group.id,
                  ),
                ),
              FilterPill(
                label: l10n.groupLater,
                selected: _groupId == null,
                onTap: () => setState(() => _groupId = null),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          Text(
            l10n.healthNotHere,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        ],
      ],
    );
  }
}
