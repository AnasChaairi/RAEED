import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import 'recorded_marker.dart';

/// The three confirm weights the brief specifies, visually distinct:
/// destructive-but-reversible (hide, archive), irreversible (deactivate),
/// and high-reach (an urgent announcement).
enum ConfirmWeight { reversible, irreversible, highReach }

/// A bottom-sheet confirmation with a kind label, a title, a body, the
/// recorded-action marker and a single primary action.
class ExecutiveConfirmSheet extends StatelessWidget {
  const ExecutiveConfirmSheet({
    required this.weight,
    required this.kind,
    required this.title,
    required this.body,
    required this.recordedText,
    required this.confirmLabel,
    super.key,
  });

  final ConfirmWeight weight;
  final String kind;
  final String title;
  final String body;
  final String recordedText;
  final String confirmLabel;

  /// Opens the sheet and resolves to true when confirmed.
  static Future<bool> show(
    BuildContext context, {
    required ConfirmWeight weight,
    required String kind,
    required String title,
    required String body,
    required String recordedText,
    required String confirmLabel,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExecutiveConfirmSheet(
        weight: weight,
        kind: kind,
        title: title,
        body: body,
        recordedText: recordedText,
        confirmLabel: confirmLabel,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final (accent, onAccent, soft) = switch (weight) {
      ConfirmWeight.reversible => (
        palette.primary,
        palette.primaryOn,
        palette.primarySoft,
      ),
      ConfirmWeight.irreversible => (
        palette.danger,
        palette.surface,
        palette.dangerSoft,
      ),
      ConfirmWeight.highReach => (
        palette.accentDecorative,
        palette.accentOn,
        palette.accentSoft,
      ),
    };

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RaeedRadius.xl2),
          ),
          border: Border(top: BorderSide(color: accent, width: 6)),
          boxShadow: context.elevationSm,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RaeedSpacing.xl,
              RaeedSpacing.md,
              RaeedSpacing.xl,
              RaeedSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RaeedSpacing.md,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(RaeedRadius.pill),
                  ),
                  child: Text(
                    kind,
                    style: context.type.caption.copyWith(
                      // Text on the amber ground uses the text-safe gold, not
                      // the decorative fill.
                      color: weight == ConfirmWeight.highReach
                          ? palette.accent
                          : accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: RaeedSpacing.sm),
                Text(
                  title,
                  style: context.type.h2.copyWith(color: palette.ink),
                ),
                const SizedBox(height: RaeedSpacing.sm),
                Text(
                  body,
                  style: context.type.bodySmall.copyWith(color: palette.ink),
                ),
                const SizedBox(height: RaeedSpacing.md),
                RecordedMarker(text: recordedText, inset: true),
                const SizedBox(height: RaeedSpacing.lg),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: onAccent,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
                const SizedBox(height: RaeedSpacing.sm),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.dialogCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
