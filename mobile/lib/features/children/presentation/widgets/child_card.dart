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

/// One child on the parent home screen, as the design draws it.
///
/// A rounded card with the photo, the name and its health badge, the group
/// underneath, and a status pill pulled to the trailing edge — then a hairline
/// and a footer line carrying whatever is next. The footer is the part a parent
/// reads second: the pill says *where the child is*, the footer says *what is
/// coming*.
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

  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onHealthTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pill = resolveStatusPill(child, now);

    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaeedRadius.xl2),
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
              _Headline(
                child: child,
                now: now,
                pill: pill,
                onStatusTap: onStatusTap,
              ),
              if (child.nextSession != null) ...[
                const SizedBox(height: RaeedSpacing.md),
                Divider(height: 1, color: palette.surfaceAlt),
                const SizedBox(height: RaeedSpacing.md),
                _FooterLine(child: child),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The avatar, the name block, and the status pill.
///
/// The pill sits at the trailing edge while the row can hold it, and drops to
/// its own line when it cannot. It is never ellipsized: "غياب غير مبرَّر" is the
/// one label in the product a parent must be able to read in full, and a
/// truncated safety-critical status is worse than a taller card. The break is
/// driven by the space actually available rather than by a scale threshold, so
/// a narrow phone at 100% and a wide one at 130% each get the right answer.
class _Headline extends StatelessWidget {
  const _Headline({
    required this.child,
    required this.now,
    required this.pill,
    this.onStatusTap,
  });

  final Child child;
  final DateTime now;
  final StatusPill pill;
  final VoidCallback? onStatusTap;

  /// What the name needs before the pill may share its line: roughly eight
  /// Arabic characters, below which the name is no longer a name.
  static const double _minNameWidth = 96;

  /// What a pill needs to be worth placing inline at all.
  static const double _minPillWidth = 104;

  /// Body size, used only to read the user's scaling out of the text scaler —
  /// which is a curve on recent platforms, not a single factor.
  static const double _referenceFontSize = 14;

  @override
  Widget build(BuildContext context) {
    final chip = StatusPillChip(
      pill: pill,
      onTap: pill.isActionable ? onStatusTap : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale =
            MediaQuery.textScalerOf(context).scale(_referenceFontSize) /
            _referenceFontSize;
        final trailing =
            constraints.maxWidth -
            _ChildAvatar.size -
            RaeedSpacing.md -
            RaeedSpacing.sm -
            _minNameWidth * scale;

        final leading = Row(
          children: [
            _ChildAvatar(child: child),
            const SizedBox(width: RaeedSpacing.md),
            Expanded(
              child: _NameAndGroup(child: child, now: now),
            ),
            if (trailing >= _minPillWidth * scale) ...[
              const SizedBox(width: RaeedSpacing.sm),
              // Capped rather than flexed: the cap is what keeps the row inside
              // its constraints, and anything left over goes to the name.
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: trailing),
                child: chip,
              ),
            ],
          ],
        );

        if (trailing >= _minPillWidth * scale) return leading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(height: RaeedSpacing.sm),
            chip,
          ],
        );
      },
    );
  }
}

class _NameAndGroup extends StatelessWidget {
  const _NameAndGroup({required this.child, required this.now});

  final Child child;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final dob = child.dateOfBirth;
    final age = dob == null ? null : ageInYearsOn(dob, now);

    final subtitle = [
      if (age != null) l10n.childAgeYears(age),
      if (child.group != null) child.group!.name,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                child.fullName,
                style: context.type.h3.copyWith(color: palette.ink),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (child.healthAlert) ...[
              const SizedBox(width: RaeedSpacing.xs),
              // The design puts the allergy itself in this slot. It stays a
              // badge here: RAEED-12 requires the health-alert badge to be
              // icon-only in list views, and a home screen is read in waiting
              // rooms and corridors. The full record is one tap away, on the
              // profile.
              const HealthAlertBadge(size: 14),
            ],
          ],
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: RaeedSpacing.xs),
          Text(
            subtitle,
            style: context.type.caption.copyWith(color: palette.inkDim),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// The hairline-separated footer: what is next for this child.
class _FooterLine extends StatelessWidget {
  const _FooterLine({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final session = child.nextSession;
    if (session == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.childNextSession(_when(context, session.startsAt)),
            style: context.type
                .tabular(context.type.caption)
                .copyWith(color: palette.inkDim),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (session.title != null) ...[
          const SizedBox(width: RaeedSpacing.sm),
          Flexible(
            child: Text(
              session.title!,
              style: context.type.caption.copyWith(color: palette.primary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// Time of day for today, otherwise the weekday and time.
  String _when(BuildContext context, DateTime at) {
    final local = at.toLocal();
    final now = DateTime.now();
    final isToday =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final time =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return isToday ? time : '${_weekday(context, local)} $time';
  }

  String _weekday(BuildContext context, DateTime at) =>
      MaterialLocalizations.of(context).formatShortDate(at);
}

/// The child's photo, or their initial when there is none.
class _ChildAvatar extends StatelessWidget {
  const _ChildAvatar({required this.child});

  final Child child;

  /// Read by [_Headline] when it budgets the row.
  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final photoUrl = child.photoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(RaeedRadius.xl),
      child: SizedBox(
        width: size,
        height: size,
        child: photoUrl == null || photoUrl.isEmpty
            ? _InitialAvatar(child: child)
            : CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                // Photos are served behind short-lived signed URLs, so a failed
                // load is normal once one expires — it degrades to the initial
                // rather than a broken-image glyph.
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
          style: context.type.h2.copyWith(color: palette.primary),
        ),
      ),
    );
  }
}
