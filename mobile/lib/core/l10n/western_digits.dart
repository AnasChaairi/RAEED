import 'package:intl/intl.dart';

/// Pins Western digits (0–9) for Arabic date formatting.
///
/// `intl` ships no `ar_MA` date data, so every `DateFormat` asked for
/// Moroccan Arabic falls back to `ar` — whose default is Eastern
/// Arabic-Indic numerals (٠–٩). Morocco does not use them, and
/// `specs/08-design-system/style-guide.md` requires Western digits
/// throughout. Called once at startup, before any date is formatted.
void useWesternDigitsForArabic() {
  for (final locale in const ['ar', 'ar_MA']) {
    DateFormat.useNativeDigitsByDefaultFor(locale, false);
  }
}
