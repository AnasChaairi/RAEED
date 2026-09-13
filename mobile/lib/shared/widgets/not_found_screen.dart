import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/design_tokens.gen.dart';
import '../../core/theme/raeed_theme.dart';

/// Shown when a deep link does not resolve.
///
/// Reachable in normal use: a push notification opens an exact conversation or
/// session, and by the time someone taps it that session may have been
/// cancelled or the conversation archived. The wording says the link is stale
/// rather than blaming the user, and offers the one action that always works.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notFoundTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(RaeedSpacing.xl2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_off_rounded, size: 40, color: palette.inkDim),
              const SizedBox(height: RaeedSpacing.lg),
              Text(
                l10n.notFoundTitle,
                style: context.type.h3.copyWith(color: palette.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: RaeedSpacing.sm),
              Text(
                l10n.notFoundBody,
                style: context.type.body.copyWith(color: palette.inkDim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: RaeedSpacing.xl2),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.notFoundGoHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
