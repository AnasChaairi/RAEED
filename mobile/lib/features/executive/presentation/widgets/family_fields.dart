import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/family.dart';
import 'tone_chip.dart';

/// The fields a guardian and a child are entered with — shared by the
/// new-family wizard and the family page's edit sheets, so a phone is typed
/// the same way in both and a relationship has one set of labels.

/// The relationship a guardian has to the household's children.
class RelationshipDropdown extends StatelessWidget {
  const RelationshipDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;

  /// The values the form offers. Anything else on the wire (a legacy or
  /// server-side value) is shown as the generic label and kept as it is
  /// until the executive picks one.
  static const options = ['mother', 'father', 'parent'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: options.contains(value) ? value : 'parent',
        items: [
          for (final option in options)
            DropdownMenuItem(
              value: option,
              child: Text(relationshipLabel(l10n, option)),
            ),
        ],
        onChanged: (v) => v == null ? null : onChanged(v),
      ),
    );
  }
}

/// A Moroccan mobile number: the fixed `+212` prefix, national digits after
/// it, left-to-right whatever the page's direction. Non-digits are stripped
/// as they are typed, so a pasted `06 12 34 56 78` lands as `612345678`.
class NationalPhoneField extends StatelessWidget {
  const NationalPhoneField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.helperText,
    this.autofocus = false,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final String? helperText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        initialValue: initialValue,
        autofocus: autofocus,
        keyboardType: TextInputType.phone,
        onChanged: (v) => onChanged(v.replaceAll(RegExp(r'\D'), '')),
        decoration: InputDecoration(
          prefixText: '+212 ',
          hintText: hintText ?? l10n.guardianPhoneHint,
          helperText: helperText,
          helperMaxLines: 2,
          isDense: true,
        ),
      ),
    );
  }
}

/// "أم" / "أب" / "وليّ" for a relationship value.
String relationshipLabel(AppL10n l10n, String relationship) =>
    switch (relationship) {
      'mother' => l10n.relMother,
      'father' => l10n.relFather,
      _ => l10n.relGuardian,
    };

/// The status chip a household shows: how far it is into using the app.
ToneChip familyStatusChip(AppL10n l10n, FamilyStatus status) =>
    switch (status) {
      FamilyStatus.active => ToneChip(
        label: l10n.familyStatusActive,
        tone: ChipTone.success,
        icon: Icons.check_rounded,
      ),
      FamilyStatus.partial => ToneChip(
        label: l10n.familyStatusPartial,
        tone: ChipTone.info,
        icon: Icons.contrast_rounded,
      ),
      FamilyStatus.pending => ToneChip(
        label: l10n.familyStatusPending,
        tone: ChipTone.warning,
        icon: Icons.schedule_rounded,
      ),
    };
