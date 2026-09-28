import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/family.dart';

/// Shows the executive the first password of each new account, once.
///
/// There is no SMS channel, so the executive is the delivery: they read the
/// password out or write it down for the guardian. The dialog is the only
/// place the value ever appears — it is not stored, not put in a route, not
/// in a snackbar that could be screenshotted by accident later — and it can
/// only be dismissed deliberately.
Future<void> showPasswordHandover(
  BuildContext context, {
  required List<GuardianCredential> guardians,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PasswordHandoverDialog(guardians: guardians),
  );
}

class PasswordHandoverDialog extends StatelessWidget {
  const PasswordHandoverDialog({super.key, required this.guardians});

  final List<GuardianCredential> guardians;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return AlertDialog(
      title: Text(l10n.handoverTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.handoverIntro,
            style: context.type.bodySmall.copyWith(color: palette.inkDim),
          ),
          const SizedBox(height: RaeedSpacing.lg),
          for (final guardian in guardians) ...[
            Text(
              guardian.displayName,
              style: context.type.label.copyWith(
                color: palette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: RaeedSpacing.xs),
            if (guardian.password case final password?)
              Container(
                key: Key('handover-${guardian.id}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: RaeedSpacing.lg,
                  vertical: RaeedSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(RaeedRadius.md),
                  border: Border.all(color: palette.border),
                ),
                child: SelectableText(
                  password,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: context.type
                      .tabular(context.type.h2)
                      .copyWith(color: palette.ink, letterSpacing: 4),
                ),
              )
            else
              Text(
                l10n.handoverExisting,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
            const SizedBox(height: RaeedSpacing.md),
          ],
        ],
      ),
      actions: [
        FilledButton(
          key: const Key('handover-done'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.handoverDone),
        ),
      ],
    );
  }
}
