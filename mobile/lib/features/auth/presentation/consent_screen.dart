import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../../shared/widgets/skeleton.dart';
import '../domain/consent.dart';
import 'auth_providers.dart';
import 'auth_scaffold.dart';
import 'login_screen.dart' show AuthButtonSpinner;

/// Privacy-policy and per-child image-rights consent (`RAEED-5`, `ACC-06`).
///
/// The gate between signing in and seeing any child's data. The router holds
/// the user here until the server confirms both consents are recorded.
///
/// **Every child starts at "not allowed".** `specs/README.md` requires the most
/// private option to be the default for anything touching children's media,
/// and the Memories Wall refuses to publish a photo of a `not_allowed` child
/// (`WAL-06`). A default of "allowed" would mean a guardian who taps straight
/// through has silently published their child; this way, tapping straight
/// through silently protects them. The screen is explicit that the choice can
/// be changed later, so the restrictive default costs nothing but a later tap.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _privacyPolicyAccepted = false;

  /// Chosen level per child id. A child absent from this map has not been
  /// touched and is submitted at [ImageRightsLevel.mostRestrictive].
  final Map<String, ImageRightsLevel> _levels = {};

  bool _isSubmitting = false;
  Object? _submitError;

  Future<void> _submit(ConsentRequirement requirement) async {
    if (!_privacyPolicyAccepted || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await ref.read(captureConsentProvider)(
        requirement: requirement,
        submission: ConsentSubmission(
          privacyPolicyAccepted: true,
          imageRights: Map.of(_levels),
        ),
      );
      // The session unlocks inside the use case, only after the server has
      // accepted the write. The router takes it from here.
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _submitError = error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final requirement = ref.watch(consentRequirementProvider);

    return requirement.when(
      loading: () => const _ConsentSkeleton(),
      error: (error, _) => Scaffold(
        backgroundColor: context.palette.bg,
        body: SafeArea(
          child: RaeedErrorView(
            error: error,
            onRetry: () => ref.invalidate(consentRequirementProvider),
          ),
        ),
      ),
      data: (data) => AuthScaffold(
        title: l10n.consentTitle,
        subtitle: l10n.consentIntro,
        error: _submitError,
        children: [
          _PrivacyPolicySection(
            accepted: _privacyPolicyAccepted,
            enabled: !_isSubmitting,
            onChanged: (value) =>
                setState(() => _privacyPolicyAccepted = value),
          ),
          if (data.children.isNotEmpty) ...[
            const SizedBox(height: RaeedSpacing.xl3),
            Text(
              l10n.consentImageRightsTitle,
              style: context.type.h3.copyWith(color: context.palette.ink),
            ),
            const SizedBox(height: RaeedSpacing.md),
            for (final child in data.children) ...[
              _ChildImageRights(
                child: child,
                selected: _levels[child.id] ?? ImageRightsLevel.mostRestrictive,
                enabled: !_isSubmitting,
                onChanged: (level) => setState(() => _levels[child.id] = level),
              ),
              const SizedBox(height: RaeedSpacing.lg),
            ],
            Text(
              l10n.consentChangeLater,
              style: context.type.caption.copyWith(
                color: context.palette.inkDim,
              ),
            ),
          ],
          const SizedBox(height: RaeedSpacing.xl2),
          FilledButton(
            onPressed: _privacyPolicyAccepted && !_isSubmitting
                ? () => _submit(data)
                : null,
            child: _isSubmitting
                ? const AuthButtonSpinner()
                : Text(l10n.consentSubmit),
          ),
        ],
      ),
    );
  }
}

/// The privacy-policy acceptance, which gates the submit button.
class _PrivacyPolicySection extends StatelessWidget {
  const _PrivacyPolicySection({
    required this.accepted,
    required this.enabled,
    required this.onChanged,
  });

  final bool accepted;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    // Material, not a decorated Container: ListTile paints its background and
    // ink splashes on the nearest Material ancestor, and a DecoratedBox in
    // between swallows them — Flutter asserts on exactly this.
    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        side: BorderSide(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            value: accepted,
            onChanged: enabled ? (value) => onChanged(value ?? false) : null,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsetsDirectional.only(
              start: RaeedSpacing.sm,
              end: RaeedSpacing.lg,
            ),
            title: Text(
              l10n.consentPrivacyPolicyAccept,
              style: context.type.body.copyWith(color: palette.ink),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: RaeedSpacing.lg,
              end: RaeedSpacing.lg,
              bottom: RaeedSpacing.sm,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                // Opening the policy is deliberately a separate, always-enabled
                // action: someone must be able to read what they are agreeing
                // to without first agreeing to it.
                onPressed: () => _showPolicy(context),
                child: Text(l10n.consentPrivacyPolicyRead),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPolicy(BuildContext context) {
    final l10n = AppL10n.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(RaeedSpacing.xl2),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                l10n.consentTitle,
                style: sheetContext.type.h2.copyWith(
                  color: sheetContext.palette.ink,
                ),
              ),
              const SizedBox(height: RaeedSpacing.lg),
              Text(
                l10n.consentIntro,
                style: sheetContext.type.body.copyWith(
                  color: sheetContext.palette.inkDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The three-way image-rights choice for one child.
class _ChildImageRights extends StatelessWidget {
  const _ChildImageRights({
    required this.child,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final ConsentChild child;
  final ImageRightsLevel selected;
  final bool enabled;
  final ValueChanged<ImageRightsLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        side: BorderSide(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RaeedSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.consentImageRightsForChild(child.fullName),
              style: context.type.h3.copyWith(color: palette.ink),
            ),
            const SizedBox(height: RaeedSpacing.md),
            // RadioGroup owns the selection; the tiles below only declare
            // their value. This is the non-deprecated shape as of Flutter 3.32.
            RadioGroup<ImageRightsLevel>(
              groupValue: selected,
              // RadioGroup.onChanged is non-nullable, so "disabled" is enforced
              // here rather than by passing null — a tap while the submission is
              // in flight must not change a consent level under the request that
              // is already carrying it.
              onChanged: (value) {
                if (enabled && value != null) onChanged(value);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final level in ImageRightsLevel.values)
                    RadioListTile<ImageRightsLevel>(
                      value: level,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        _label(l10n, level),
                        style: context.type.body.copyWith(color: palette.ink),
                      ),
                      subtitle: Text(
                        _help(l10n, level),
                        style: context.type.caption.copyWith(
                          color: palette.inkDim,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(AppL10n l10n, ImageRightsLevel level) => switch (level) {
    ImageRightsLevel.allowed => l10n.consentImageRightsAllowed,
    ImageRightsLevel.appOnly => l10n.consentImageRightsAppOnly,
    ImageRightsLevel.notAllowed => l10n.consentImageRightsNotAllowed,
  };

  String _help(AppL10n l10n, ImageRightsLevel level) => switch (level) {
    ImageRightsLevel.allowed => l10n.consentImageRightsAllowedHelp,
    ImageRightsLevel.appOnly => l10n.consentImageRightsAppOnlyHelp,
    ImageRightsLevel.notAllowed => l10n.consentImageRightsNotAllowedHelp,
  };
}

/// Skeleton while the requirement loads — never a bare spinner.
class _ConsentSkeleton extends StatelessWidget {
  const _ConsentSkeleton();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.bg,
    body: const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(RaeedSpacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: RaeedSpacing.xl3),
            SkeletonLine(widthFactor: 0.6, height: 26),
            SizedBox(height: RaeedSpacing.lg),
            SkeletonLine(height: 16),
            SizedBox(height: RaeedSpacing.xs),
            SkeletonLine(widthFactor: 0.8, height: 16),
            SizedBox(height: RaeedSpacing.xl3),
            SkeletonBox(width: double.infinity, height: 96),
            SizedBox(height: RaeedSpacing.lg),
            SkeletonBox(width: double.infinity, height: 180),
          ],
        ),
      ),
    ),
  );
}
