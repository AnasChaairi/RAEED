import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../../shared/errors/failure_presenter.dart';
import '../../domain/family.dart';
import '../executive_providers.dart';
import 'family_fields.dart';
import 'sheet_frame.dart';

/// Edit one guardian of a household, or link another one (EXEC-M-10b).
///
/// The sheet owns the request: a refusal (`guardians.phone_taken`, a network
/// failure) is shown inside it and the values stay, so the executive fixes
/// the number rather than typing everything again. It pops with what the
/// server returned, and the page takes it from there.
class GuardianFormSheet extends ConsumerStatefulWidget {
  const GuardianFormSheet({required this.familyId, this.guardian, super.key});

  final String familyId;

  /// The guardian being edited; null links a new one.
  final FamilyGuardian? guardian;

  /// Resolves to the household as it now is, or null when cancelled.
  static Future<Family?> showEdit(
    BuildContext context, {
    required String familyId,
    required FamilyGuardian guardian,
  }) => showModalBottomSheet<Family>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GuardianFormSheet(familyId: familyId, guardian: guardian),
  );

  /// Resolves to what linking did, or null when cancelled.
  static Future<GuardianAdded?> showAdd(
    BuildContext context, {
    required String familyId,
  }) => showModalBottomSheet<GuardianAdded>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GuardianFormSheet(familyId: familyId),
  );

  @override
  ConsumerState<GuardianFormSheet> createState() => _GuardianFormSheetState();
}

class _GuardianFormSheetState extends ConsumerState<GuardianFormSheet> {
  late String _name = widget.guardian?.displayName ?? '';
  late String _relationship = widget.guardian?.relationship ?? 'parent';

  /// National digits. In edit mode, empty means "keep the current number".
  String _phone = '';
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.guardian != null;

  static final _nationalMobile = RegExp(r'^[5-7]\d{8}$');

  GuardianPatch get _patch {
    final guardian = widget.guardian!;
    final name = _name.trim();
    return GuardianPatch(
      displayName: name != guardian.displayName ? name : null,
      phone: _phone.isEmpty ? null : _phone,
      relationship: _relationship != guardian.relationship
          ? _relationship
          : null,
    );
  }

  bool get _canSave {
    if (_name.trim().length < 2) return false;
    if (_isEdit) {
      if (_phone.isNotEmpty && !_nationalMobile.hasMatch(_phone)) return false;
      return !_patch.isEmpty;
    }
    return _nationalMobile.hasMatch(_phone);
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
        result = await repository.updateGuardian(
          familyId: widget.familyId,
          guardianId: widget.guardian!.id,
          patch: _patch,
        );
      } else {
        result = await repository.addGuardian(
          familyId: widget.familyId,
          guardian: GuardianDraft(
            displayName: _name,
            phone: _phone,
            relationship: _relationship,
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
    final changingPhone = _isEdit && _phone.isNotEmpty;

    return SheetFrame(
      title: _isEdit ? l10n.familyEditGuardian : l10n.familyAddGuardian,
      error: _error,
      recordedText: l10n.familyEditRecorded,
      saving: _saving,
      canSave: _canSave,
      onSave: _save,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: const Key('guardian-name'),
                initialValue: _name,
                enabled: !_saving,
                onChanged: (v) => setState(() => _name = v),
                decoration: InputDecoration(
                  hintText: l10n.guardianNameHint,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm),
            RelationshipDropdown(
              value: _relationship,
              onChanged: (v) => setState(() => _relationship = v),
            ),
          ],
        ),
        const SizedBox(height: RaeedSpacing.sm),
        NationalPhoneField(
          key: const Key('guardian-phone'),
          initialValue: _phone,
          onChanged: (v) => setState(() => _phone = v),
          hintText: _isEdit
              ? '${widget.guardian!.phoneHint ?? ''} · ${l10n.familyPhoneUnchangedHint}'
              : null,
        ),
        if (changingPhone) ...[
          const SizedBox(height: RaeedSpacing.sm),
          Text(
            l10n.familyPhoneChangeWarning,
            key: const Key('phone-change-warning'),
            style: context.type.caption.copyWith(color: palette.warning),
          ),
        ],
      ],
    );
  }
}
