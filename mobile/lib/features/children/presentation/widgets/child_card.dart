import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../application/child_status_pill.dart';
import '../../domain/child.dart';
import '../../domain/child_age.dart';
import 'health_alert_badge.dart';
import 'status_pill_chip.dart';

/// One child on the parent home screen.
///
/// The screen spec's components, in order of what a parent looks for: photo,
/// name, age, group, next session, today's status pill. The pill sits last and
/// widest because it is the thing being scanned for.
class ChildCard extends StatelessWidget {
  const ChildCard({
    required this.child,
    required this.now,
    this.onTap,
    this.onStatusTap,
    this.onHealthTap,
    super.key,
  });

  /// The child to render.
  final Child child;

  /// Injected rather than read from the clock, so the status a test asserts is
  /// the status it set up.
  final DateTime now;

  /// Opens the child's profile.
  final VoidCallback? onTap;

  /// Opens presence confirmation or attendance detail.
  final VoidCallback? onStatusTap;

  /// Opens the full health record.
  final VoidCallback? onHealthTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final pill = resolveStatusPill(child, now);

    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        // A fresh alert outlines the whole card, not only the pill: on a list
        // of four children the card is what the eye lands on first.
        side: BorderSide(
          color: pill.isAlert ? palette.danger : palette.border,
          width: pill.isAlert ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(RaeedSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChildAvatar(child: child),
                  const SizedBox(width: RaeedSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                child.fullName,
                                style: context.type.h3.copyWith(
                                  color: palette.ink,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (child.healthAlert) ...[
                              const SizedBox(width: RaeedSpacing.xs),
                              // Icon only. The health text itself never appears
                              // in a list view — see HealthAlertBadge.
                              HealthAlertBadge(onTap: onHealthTap),
                            ],
                          ],
                        ),
                        const SizedBox(height: RaeedSpacing.xs),
                        Text(
                          _subtitle(l10n),
                          style: context.type.bodySmall.copyWith(
                            color: palette.inkDim,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RaeedSpacing.md),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: StatusPillChip(
                  pill: pill,
                  onTap: pill.isActionable ? onStatusTap : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Age and group on one line — both are context for the name above, not
  /// facts a parent hunts for.
  String _subtitle(AppL10n l10n) {
    final dob = child.dateOfBirth;
    final age = dob == null ? null : ageInYearsOn(dob, now);
    final parts = <String>[
      if (age != null) l10n.childAgeYears(age),
      if (child.group != null) child.group!.name,
    ];
    return parts.join(' · ');
  }
}

/// The child's photo, or their initial when there is none.
class _ChildAvatar extends StatelessWidget {
  const _ChildAvatar({required this.child});

  final Child child;

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final photoUrl = child.photoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(RaeedRadius.md),
      child: SizedBox(
        width: _size,
        height: _size,
        child: photoUrl == null || photoUrl.isEmpty
            ? _InitialAvatar(child: child)
            : CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                // Photos of children are served behind short-lived signed URLs
                // (specs/10-security-and-privacy.md). A failed load is normal
                // once one expires, so it degrades to the initial rather than
                // showing a broken-image glyph.
                placeholder: (_, _) => ColoredBox(color: palette.surfaceAlt),
                errorWidget: (_, _, _) => _InitialAvatar(child: child),
              ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final initial = child.fullName.trim().isEmpty
        ? '؟'
        : child.fullName.trim().characters.first;

    return ColoredBox(
      color: palette.primarySoft,
      child: Center(
        child: Text(
          initial,
          style: context.type.h3.copyWith(color: palette.primary),
        ),
      ),
    );
  }
}
