import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// The "this action is recorded" affordance (`AUD-03`).
///
/// Small, consistent, and shown at the moment an oversight action is taken —
/// in the correction sheet, the hide confirm, the urgent-send confirm —
/// never in a footer. The brief calls it non-shaming: it states a fact about
/// the system, not a warning about the person.
class RecordedMarker extends StatelessWidget {
  const RecordedMarker({this.text, this.inset = false, super.key});

  /// Overrides the generic wording with the action's own.
  final String? text;

  /// Draws it on `surfaceAlt`, for use inside a sheet.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.radio_button_checked, size: 14, color: palette.inkDim),
        const SizedBox(width: RaeedSpacing.sm),
        Expanded(
          child: Text(
            text ?? AppL10n.of(context).recordedActionMarker,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        ),
      ],
    );
    if (!inset) return row;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md,
        vertical: RaeedSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(RaeedRadius.md),
      ),
      child: row,
    );
  }
}
