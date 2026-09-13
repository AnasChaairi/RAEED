import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';

/// The common frame for the three pre-session screens.
///
/// Login, OTP and consent are the only screens a user sees before the app has
/// any of their data, so they share a deliberately plain, centred layout with
/// the brand mark. Factoring it out keeps the three from drifting apart, which
/// matters here more than elsewhere: this sequence is the first thing a family
/// sees, and an inconsistency between consecutive steps reads as a broken app.
///
/// Scrolls rather than fitting: at 130%+ text scaling with a keyboard open,
/// none of these screens fits a small phone, and a scroll view is the honest
/// answer rather than a squeezed layout.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    this.error,
    this.showLogo = true,
    this.onBack,
    super.key,
  });

  /// The screen's heading.
  final String title;

  /// One line of explanation under the heading.
  final String? subtitle;

  /// A failure to surface above the form, if any.
  ///
  /// Rendered inline rather than as a snackbar: on these screens the error is
  /// about the thing the user is looking at, and a message that slides away
  /// after four seconds is the wrong place for "that code was wrong".
  final Object? error;

  /// Whether to show the brand mark.
  final bool showLogo;

  /// Invoked by the back affordance, when the screen has one.
  final VoidCallback? onBack;

  /// The form itself.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: onBack == null
          ? null
          : AppBar(
              backgroundColor: palette.bg,
              // Mirrors under Directionality, as chevrons must in Arabic.
              leading: BackButton(onPressed: onBack),
            ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: RaeedSpacing.xl2,
              vertical: RaeedSpacing.xl2,
            ),
            child: ConstrainedBox(
              // Keeps the form from stretching to full width on a tablet,
              // where a 700px-wide text field looks like a mistake.
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - RaeedSpacing.xl3,
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showLogo) ...[
                    const _BrandMark(),
                    const SizedBox(height: RaeedSpacing.xl3),
                  ],
                  Text(
                    title,
                    style: context.type.h1.copyWith(color: palette.ink),
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: RaeedSpacing.sm),
                    Text(
                      subtitle!,
                      style: context.type.body.copyWith(color: palette.inkDim),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: RaeedSpacing.xl3),
                  if (error != null) ...[
                    _InlineError(error: error!),
                    const SizedBox(height: RaeedSpacing.lg),
                  ],
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The star motif from the logo, in the brand gold.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Semantics(
      label: l10n.appName,
      child: Icon(
        Icons.star_rounded,
        size: 48,
        color: context.palette.accentDecorative,
      ),
    );
  }
}

/// An inline failure banner.
class _InlineError extends StatelessWidget {
  const _InlineError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final failure = presentFailure(error, AppL10n.of(context));

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(RaeedSpacing.lg),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(RaeedRadius.md),
          border: Border.all(color: palette.danger),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 18, color: palette.danger),
            const SizedBox(width: RaeedSpacing.md),
            Expanded(
              child: Text(
                failure.body,
                style: context.type.bodySmall.copyWith(color: palette.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
