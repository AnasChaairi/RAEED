import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.gen.dart';
import '../../core/theme/raeed_theme.dart';
import '../errors/failure_presenter.dart';

/// The app's one error state.
///
/// Every screen shows failures through this, so a parent sees the same shape
/// whether attendance, messaging or the Memories Wall failed. Retry is offered
/// only when retrying could actually help — see [PresentedFailure.isRetryable].
class RaeedErrorView extends StatelessWidget {
  const RaeedErrorView({required this.error, this.onRetry, super.key});

  /// The thrown error, translated for display by [presentFailure].
  final Object error;

  /// Invoked when the user asks to try again. Ignored for failures that
  /// retrying cannot fix.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final failure = presentFailure(error, l10n);
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RaeedSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative: the heading immediately below says the same thing,
            // and a screen reader announcing both would be noise.
            Icon(
              _iconFor(failure),
              size: 40,
              color: failure.isRetryable ? palette.inkDim : palette.warning,
            ),
            const SizedBox(height: RaeedSpacing.lg),
            Text(
              failure.title,
              style: context.type.h3.copyWith(color: palette.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RaeedSpacing.sm),
            Text(
              failure.body,
              style: context.type.body.copyWith(color: palette.inkDim),
              textAlign: TextAlign.center,
            ),
            if (failure.isRetryable && onRetry != null) ...[
              const SizedBox(height: RaeedSpacing.xl2),
              OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(PresentedFailure failure) =>
      failure.isRetryable ? Icons.cloud_off_outlined : Icons.lock_outline;
}
