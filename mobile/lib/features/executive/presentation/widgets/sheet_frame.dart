import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// The frame every edit sheet on the family page shares: the handle, a
/// title, the fields, the recorded-action line, an inline error that keeps
/// the sheet open, and cancel / save.
///
/// Save is disabled until [canSave]; while [saving] both buttons are, so a
/// double tap cannot send a change twice.
class SheetFrame extends StatelessWidget {
  const SheetFrame({
    required this.title,
    required this.children,
    required this.recordedText,
    required this.canSave,
    required this.saving,
    required this.onSave,
    this.error,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final String recordedText;
  final bool canSave;
  final bool saving;
  final VoidCallback onSave;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RaeedRadius.xl2),
        ),
        boxShadow: context.elevationSm,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            RaeedSpacing.xl,
            RaeedSpacing.md,
            RaeedSpacing.xl,
            RaeedSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: RaeedSpacing.md),
                Text(
                  title,
                  style: context.type.h3.copyWith(color: palette.ink),
                ),
                const SizedBox(height: RaeedSpacing.md),
                ...children,
                const SizedBox(height: RaeedSpacing.md),
                Text(
                  recordedText,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
                if (error != null) ...[
                  const SizedBox(height: RaeedSpacing.sm),
                  Text(
                    error!,
                    key: const Key('sheet-error'),
                    style: context.type.caption.copyWith(color: palette.danger),
                  ),
                ],
                const SizedBox(height: RaeedSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const Key('sheet-save'),
                        onPressed: canSave && !saving ? onSave : null,
                        child: saving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.primaryOn,
                                ),
                              )
                            : Text(l10n.saveAction),
                      ),
                    ),
                    const SizedBox(width: RaeedSpacing.sm),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          RaeedTouchTarget.primaryActionsPx,
                        ),
                        foregroundColor: palette.ink,
                      ),
                      onPressed: saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(l10n.cancelAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
