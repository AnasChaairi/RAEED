import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import 'executive_card.dart';

/// What a non-admin executive sees on an admin-only section.
///
/// Shown when the server refused the read with `scope.forbidden` — so the
/// attempt really was made and recorded, and the card can truthfully say so.
class AdminOnlyCard extends StatelessWidget {
  const AdminOnlyCard({required this.roleLabel, super.key});

  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      child: ExecutiveCard(
        radius: RaeedRadius.xl2,
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.xl,
          vertical: RaeedSpacing.xl2 + 4,
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: palette.accent,
              ),
            ),
            const SizedBox(height: RaeedSpacing.md),
            Text(
              l10n.adminOnlyTitle,
              style: context.type.h3.copyWith(color: palette.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RaeedSpacing.xs),
            Text(
              l10n.adminOnlyBody(roleLabel),
              style: context.type.bodySmall.copyWith(color: palette.inkDim),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RaeedSpacing.xs),
            Text(
              l10n.adminOnlyLogged,
              style: context.type.caption.copyWith(color: palette.inkDim),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// The small "إداري" tag on admin-only entries.
class AdminTag extends StatelessWidget {
  const AdminTag({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.sm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(RaeedRadius.pill),
      ),
      child: Text(
        AppL10n.of(context).adminTag,
        style: context.type.caption.copyWith(
          color: palette.accent,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
      ),
    );
  }
}
