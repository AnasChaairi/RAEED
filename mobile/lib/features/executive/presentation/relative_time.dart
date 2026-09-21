import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';

/// Digits are Western throughout, pinned to `ar_MA` — Morocco's convention,
/// unlike the Mashriq's Eastern Arabic-Indic numerals.
String numberLocale(Locale locale) =>
    locale.languageCode == 'ar' ? 'ar_MA' : locale.toLanguageTag();

/// "قبل 40 دقيقة", "أمس" — how long ago [at] was, as of [now].
///
/// Past a week it gives the date: "three weeks ago" hides the day an absence
/// happened, which is the fact an executive is looking for.
String relativeTime(
  AppL10n l10n,
  Locale locale,
  DateTime at, {
  required DateTime now,
}) {
  final difference = now.toUtc().difference(at.toUtc());
  if (difference.inMinutes < 1) return l10n.timeJustNow;
  if (difference.inHours < 1) return l10n.timeAgoMinutes(difference.inMinutes);
  if (difference.inDays < 1) return l10n.timeAgoHours(difference.inHours);
  if (difference.inDays < 7) return l10n.timeAgoDays(difference.inDays);
  return DateFormat('d MMMM', numberLocale(locale)).format(at.toLocal());
}

/// "10:00".
String clockTime(Locale locale, DateTime at) =>
    DateFormat('HH:mm', numberLocale(locale)).format(at.toLocal());

/// "السبت 20 سبتمبر".
String dayAndMonth(Locale locale, DateTime at) =>
    DateFormat('EEEE d MMMM', numberLocale(locale)).format(at.toLocal());

/// "20 سبتمبر".
String shortDate(Locale locale, DateTime at) =>
    DateFormat('d MMMM', numberLocale(locale)).format(at.toLocal());

/// "0:23" for a voice note.
String duration(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  return '$minutes:${rest.toString().padLeft(2, '0')}';
}
