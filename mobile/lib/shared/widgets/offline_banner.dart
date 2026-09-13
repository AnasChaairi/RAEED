import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/design_tokens.gen.dart';
import '../../core/theme/raeed_theme.dart';

/// Why a screen is showing something other than fresh server data.
enum StaleDataReason {
  /// The device has no connectivity.
  offline,

  /// The device is online but the refresh failed.
  refreshFailed,
}

/// A quiet strip explaining that the content below is not fresh.
///
/// Deliberately not a dialog or a snackbar. `specs/06-mobile-app-spec.md` calls
/// for cached cards plus "a subtle 'couldn't refresh' banner" — the content is
/// still useful, and interrupting someone to tell them their slightly stale
/// data is slightly stale would be worse than the staleness.
///
/// On the attendance screen specifically this must never read as an error:
/// marking attendance offline is a supported flow, not a failure, and the
/// banner there says the work is saved and will sync.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.reason, this.messageOverride, super.key});

  /// Why the data is stale.
  final StaleDataReason reason;

  /// Replaces the default wording — used by the attendance screen, where the
  /// honest message is "saved on this device, will sync", not "couldn't
  /// refresh".
  final String? messageOverride;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    final message =
        messageOverride ??
        switch (reason) {
          StaleDataReason.offline => l10n.offlineBannerMessage,
          StaleDataReason.refreshFailed => l10n.offlineRefreshFailed,
        };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        color: palette.surfaceAlt,
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.lg,
          vertical: RaeedSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              reason == StaleDataReason.offline
                  ? Icons.wifi_off_rounded
                  : Icons.sync_problem_rounded,
              size: 18,
              color: palette.inkDim,
            ),
            const SizedBox(width: RaeedSpacing.md),
            Expanded(
              child: Text(
                message,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
