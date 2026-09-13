import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/brand_gradient.dart';

/// The frame the design gives the pre-session screens.
///
/// Sign-in sits on the full brand gradient with the wordmark above a floating
/// white card; consent is an ordinary light screen with a step indicator. Both
/// live here so the two cannot drift apart — this sequence is the first thing a
/// family sees, and an inconsistency between consecutive steps reads as a
/// broken app.
///
/// Scrolls rather than fitting. At 130%+ text scaling with a keyboard open none
/// of these screens fits a small phone, and a scroll view is the honest answer
/// rather than a squeezed layout.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    this.error,
    this.onBack,
    this.tagline,
    this.progress,
    this.footer,
    super.key,
  }) : _isImmersive = false;

  /// Sign-in: the wordmark on the gradient, form in a floating card.
  const AuthScaffold.immersive({
    required this.title,
    required this.children,
    this.subtitle,
    this.error,
    this.onBack,
    this.tagline,
    this.footer,
    super.key,
  }) : progress = null,
       _isImmersive = true;

  final String title;
  final String? subtitle;

  /// A failure to surface above the form.
  ///
  /// Inline rather than a snackbar: on these screens the error is about the
  /// thing being looked at, and a message that slides away after four seconds
  /// is the wrong place for "that code was wrong".
  final Object? error;

  /// Invoked by the back affordance, when the screen has one.
  final VoidCallback? onBack;

  /// The association's motto, under the wordmark.
  final String? tagline;

  /// Step progress, 0–1. Drawn as the design's gradient bar.
  final double? progress;

  /// Pinned below the scrolling content — the consent screen's action.
  final Widget? footer;

  final List<Widget> children;

  final bool _isImmersive;

  @override
  Widget build(BuildContext context) =>
      _isImmersive ? _buildImmersive(context) : _buildPlain(context);

  // --- Sign-in -------------------------------------------------------------

  Widget _buildImmersive(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.primary,
      body: BrandGradient(
        variant: BrandGradientVariant.immersive,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.xl2,
                vertical: RaeedSpacing.xl2,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - RaeedSpacing.xl3,
                  maxWidth: 420,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandWordmark()),
                    if (tagline != null) ...[
                      const SizedBox(height: RaeedSpacing.sm),
                      Text(
                        tagline!,
                        textAlign: TextAlign.center,
                        style: context.type.bodySmall.copyWith(
                          // On the gradient, not on a palette surface — a
                          // translucent white is the only correct value here.
                          color: palette.primaryOn.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                    const SizedBox(height: RaeedSpacing.xl3),
                    _FormCard(
                      title: title,
                      subtitle: subtitle,
                      error: error,
                      onBack: onBack,
                      children: children,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Consent and anything else -------------------------------------------

  Widget _buildPlain(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            if (progress != null || onBack != null)
              _StepHeader(progress: progress, onBack: onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  RaeedSpacing.xl2,
                  RaeedSpacing.lg,
                  RaeedSpacing.xl2,
                  RaeedSpacing.xl2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.type.h1.copyWith(color: palette.ink),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: RaeedSpacing.sm),
                      Text(
                        subtitle!,
                        style: context.type.bodySmall.copyWith(
                          color: palette.inkDim,
                        ),
                      ),
                    ],
                    const SizedBox(height: RaeedSpacing.xl2),
                    if (error != null) ...[
                      InlineError(error: error!),
                      const SizedBox(height: RaeedSpacing.lg),
                    ],
                    ...children,
                  ],
                ),
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  RaeedSpacing.xl2,
                  RaeedSpacing.md,
                  RaeedSpacing.xl2,
                  RaeedSpacing.xl2,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// The white card the sign-in form floats in.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.children,
    this.subtitle,
    this.error,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Object? error;
  final VoidCallback? onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(RaeedSpacing.xl),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(RaeedRadius.xl2),
        boxShadow: context.elevationSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (onBack != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: RaeedSpacing.xs,
                  ),
                  // Mirrors under Directionality, as a back chevron must.
                  child: IconButton(
                    onPressed: onBack,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_back),
                    color: palette.primary,
                    tooltip: AppL10n.of(context).commonBack,
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: context.type.h3.copyWith(color: palette.ink),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: RaeedSpacing.xs),
            Text(
              subtitle!,
              style: context.type.bodySmall.copyWith(color: palette.inkDim),
            ),
          ],
          const SizedBox(height: RaeedSpacing.lg),
          if (error != null) ...[
            InlineError(error: error!),
            const SizedBox(height: RaeedSpacing.lg),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// The design's step indicator: a back arrow, "step N of M", and a gradient bar.
class _StepHeader extends StatelessWidget {
  const _StepHeader({this.progress, this.onBack});

  final double? progress;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.sm,
        RaeedSpacing.xl2,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onBack != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                color: palette.inkDim,
                tooltip: AppL10n.of(context).commonBack,
              ),
            ),
          if (progress != null) ...[
            const SizedBox(height: RaeedSpacing.sm),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: RaeedSpacing.md),
              child: _ProgressBar(value: progress!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RaeedRadius.sm),
        child: SizedBox(
          height: 5,
          child: Stack(
            children: [
              ColoredBox(
                color: palette.surfaceAlt,
                child: const SizedBox.expand(),
              ),
              FractionallySizedBox(
                widthFactor: value.clamp(0, 1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: BrandGradient.gradientFor(
                      context,
                      BrandGradientVariant.header,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An inline failure banner, shared by both layouts.
class InlineError extends StatelessWidget {
  const InlineError({required this.error, super.key});

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
