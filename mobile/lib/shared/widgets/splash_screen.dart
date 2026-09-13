import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.gen.dart';
import '../../core/theme/raeed_theme.dart';

/// Shown while the session is being restored from secure storage.
///
/// This exists so the router never has to guess. A returning user's tokens
/// take a moment to read out of the Keychain/Keystore; redirecting during that
/// window would bounce them to the login screen on every cold start, and
/// they'd watch it flash away a beat later.
///
/// It is deliberately quiet — the brand mark and a progress indicator, no
/// message. A user is here for a few hundred milliseconds, and text that
/// appears and vanishes is worse than none.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Scaffold(
      backgroundColor: palette.bg,
      body: Semantics(
        label: l10n.appName,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The star motif from the logo, in the brand gold. Decorative —
              // the Semantics wrapper above already names the app.
              Icon(
                Icons.star_rounded,
                size: 56,
                color: palette.accentDecorative,
              ),
              const SizedBox(height: RaeedSpacing.lg),
              Text(
                l10n.appName,
                style: context.type.h1.copyWith(color: palette.ink),
              ),
              const SizedBox(height: RaeedSpacing.xl3),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
