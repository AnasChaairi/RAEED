import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../../shared/widgets/brand_gradient.dart';

/// The gradient header the design puts above the child cards.
///
/// Carries the greeting, the day in both calendars, and today's session times —
/// the three things a parent checks before they scroll. It curves into the
/// content below rather than sitting as a flat band, which is what stops the
/// cards reading as a second, unrelated screen.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.greetingName,
    required this.today,
    this.sessionSummary,
    this.unreadCount = 0,
    this.onNotificationsTap,
    super.key,
  });

  /// Who to greet. Empty falls back to the greeting alone.
  final String greetingName;

  /// The day being shown.
  final DateTime today;

  /// e.g. "10:00 و 15:30", or null when there is nothing on.
  final String? sessionSummary;

  /// Unread notifications; drives the dot on the bell.
  final int unreadCount;

  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return BrandGradient(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(RaeedRadius.xl2),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.xl2,
            RaeedSpacing.sm,
            RaeedSpacing.xl2,
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
                            color: palette.primaryOn.withValues(alpha: 0.7),
                          ),
                        ),
                        if (greetingName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            greetingName,
                            style: context.type.h2.copyWith(
                              color: palette.primaryOn,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _NotificationsButton(
                    unreadCount: unreadCount,
                    onTap: onNotificationsTap,
                  ),
                ],
              ),
              const SizedBox(height: RaeedSpacing.lg),
              _DateStrip(today: today, sessionSummary: sessionSummary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gregorian date with the Hijri date beneath it.
///
/// Gregorian is the system of record and Hijri displays alongside
/// (`specs/08-design-system/style-guide.md`); the gold is what marks the Hijri
/// line as the secondary reading rather than a competing one.
///
/// Digits are Western throughout, pinned to `ar_MA` — Morocco's own convention,
/// unlike the Mashriq. The design mocks up Eastern Arabic-Indic numerals; that
/// is the one thing here not taken from it.
class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.today, this.sessionSummary});

  final DateTime today;
  final String? sessionSummary;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.lg,
        vertical: RaeedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: palette.primaryOn.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(RaeedRadius.xl),
        border: Border.all(color: palette.primaryOn.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _gregorian(locale),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(
                        color: palette.primaryOn.withValues(alpha: 0.72),
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  _hijri(locale),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.accentDecorative),
                ),
              ],
            ),
          ),
          if (sessionSummary != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.homeTodaySessions,
                  style: context.type.caption.copyWith(
                    color: palette.primaryOn.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sessionSummary!,
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.primaryOn),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _gregorian(Locale locale) =>
      DateFormat('EEEE d MMMM y', _numberLocale(locale)).format(today);

  /// The Hijri date.
  ///
  /// `intl` ships no Hijri calendar, and the org-level `hijri_offset_days`
  /// setting that lets executives align to the officially announced date is a
  /// server value this screen does not have yet. Rather than render an
  /// arithmetic approximation that would be wrong by a day for much of the year
  /// — on a screen where the date is the point — the line stays empty until the
  /// backend supplies it.
  String _hijri(Locale locale) => '';

  /// Pinned to `ar_MA`, not generic `ar`: the Mashriq default would render
  /// Eastern Arabic-Indic digits, which Morocco does not use.
  static String _numberLocale(Locale locale) =>
      locale.languageCode == 'ar' ? 'ar_MA' : locale.toLanguageTag();
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.unreadCount, this.onTap});

  final int unreadCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Semantics(
      button: true,
      label: unreadCount > 0
          ? l10n.homeNotificationsWithUnread(unreadCount)
          : l10n.homeNotifications,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaeedRadius.lg),
        child: SizedBox(
          width: RaeedTouchTarget.minPx,
          height: RaeedTouchTarget.minPx,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: palette.primaryOn,
                  size: 22,
                ),
                if (unreadCount > 0)
                  PositionedDirectional(
                    top: -1,
                    end: -1,
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
