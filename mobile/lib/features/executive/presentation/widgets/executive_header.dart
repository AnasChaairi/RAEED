import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/hijri_date.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../../shared/widgets/brand_gradient.dart';
import '../relative_time.dart';

/// The gradient header of the executive dashboard.
///
/// The same band Parent Home uses — greeting, both calendars, what is on
/// today, the bell — with the role named in gold beside the name, because an
/// executive who is also an educator needs to see at a glance which surface
/// they are on, and a "more" button that reaches settings and the role
/// switcher.
class ExecutiveHeader extends StatelessWidget {
  const ExecutiveHeader({
    required this.displayName,
    required this.roleLabel,
    required this.today,
    this.sessionsToday,
    this.liveCount = 0,
    this.upcomingCount = 0,
    this.hasUnread = false,
    this.onNotificationsTap,
    this.onMoreTap,
    super.key,
  });

  final String displayName;
  final String roleLabel;
  final DateTime today;

  /// Null while the overview is loading.
  final int? sessionsToday;
  final int liveCount;
  final int upcomingCount;
  final bool hasUnread;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final on = palette.primaryOn;

    return BrandGradient(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(RaeedRadius.xl2),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.xl,
            RaeedSpacing.sm,
            RaeedSpacing.xl,
            RaeedSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGreeting,
                          style: context.type.bodySmall.copyWith(
                            color: on.withValues(alpha: 0.72),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: displayName,
                                style: context.type.h2.copyWith(color: on),
                              ),
                              TextSpan(
                                text: ' · ',
                                style: context.type.h2.copyWith(
                                  color: on.withValues(alpha: 0.6),
                                ),
                              ),
                              TextSpan(
                                text: roleLabel,
                                style: context.type.label.copyWith(
                                  color: palette.accentDecorative,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.notifications_none_rounded,
                    label: l10n.homeNotifications,
                    dot: hasUnread,
                    onTap: onNotificationsTap,
                  ),
                  const SizedBox(width: RaeedSpacing.sm),
                  _HeaderButton(
                    icon: Icons.more_horiz_rounded,
                    label: l10n.execMore,
                    onTap: onMoreTap,
                  ),
                ],
              ),
              const SizedBox(height: RaeedSpacing.lg),
              _DateStrip(
                today: today,
                sessionsToday: sessionsToday,
                liveCount: liveCount,
                upcomingCount: upcomingCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gregorian on top, the Hijri line beneath in gold, today's session count
/// at the trailing edge.
///
/// The Hijri line comes from the tabular calendar (`HijriDate`); the
/// org-level offset that aligns it to the announced date is still a server
/// setting to come.
class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.today,
    required this.sessionsToday,
    required this.liveCount,
    required this.upcomingCount,
  });

  final DateTime today;
  final int? sessionsToday;
  final int liveCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final on = palette.primaryOn;
    final caption = context.type.tabular(context.type.caption);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.lg,
        vertical: RaeedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: on.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(RaeedRadius.xl),
        border: Border.all(color: on.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'EEEE d MMMM y',
                    numberLocale(locale),
                  ).format(today),
                  style: caption.copyWith(color: on.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 3),
                Text(
                  HijriDate.fromGregorian(today).format(locale.languageCode),
                  style: caption.copyWith(color: palette.accentDecorative),
                ),
              ],
            ),
          ),
          if (sessionsToday != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.dashSessionsToday(sessionsToday!),
                  style: caption.copyWith(color: on.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.dashSessionsBreakdown(liveCount, upcomingCount),
                  style: caption.copyWith(
                    color: on,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    this.dot = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool dot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: palette.primaryOn.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.lg),
          child: SizedBox(
            width: RaeedTouchTarget.minPx,
            height: RaeedTouchTarget.minPx,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: palette.primaryOn, size: 22),
                if (dot)
                  PositionedDirectional(
                    top: 9,
                    end: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: palette.accentDecorative,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.primary, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
