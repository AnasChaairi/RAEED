import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// Flags that a child has health information, **without saying what it is**.
///
/// `specs/13-roadmap-and-tickets.md` (RAEED-12) requires the health-alert badge
/// to be "icon-only in list views", and `specs/06-mobile-app-spec.md` repeats
/// it for the attendance screen: "health-alert badge (icon only — full text on
/// tap-through)".
///
/// This is a safeguarding rule, not a layout preference. A parent's home screen
/// and an educator's attendance list are both read in public — a waiting room,
/// a corridor, a classroom with parents at the door. A child's allergy or
/// condition rendered inline is readable by anyone glancing at the phone, and
/// unlike a name it is information the child did not choose to share. The full
/// record lives one deliberate tap away, where every executive read of it is
/// separately audit-logged (`AUD-03`).
///
/// The screen-reader label says a health alert exists and that it can be
/// opened — it does not read out the health information either, for the same
/// reason: a screen reader in a shared space is a loudspeaker.
class HealthAlertBadge extends StatelessWidget {
  const HealthAlertBadge({this.onTap, this.size = 18, super.key});

  /// Opens the full record. Null in contexts where tap-through is not offered.
  final VoidCallback? onTap;

  /// Icon size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = AppL10n.of(context).healthAlertBadgeLabel;

    final badge = Container(
      padding: const EdgeInsets.all(RaeedSpacing.xs),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.medical_information_outlined,
        size: size,
        color: palette.accent,
      ),
    );

    if (onTap == null) {
      return Semantics(label: label, child: badge);
    }

    return Semantics(
      label: label,
      button: true,
      child: InkResponse(
        onTap: onTap,
        // The icon is small by design; the hit area is not.
        radius: RaeedTouchTarget.minPx / 2,
        child: SizedBox(
          width: RaeedTouchTarget.minPx,
          height: RaeedTouchTarget.minPx,
          child: Center(child: badge),
        ),
      ),
    );
  }
}
