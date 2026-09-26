/// A Hijri date from a Gregorian one, by the tabular (arithmetical) Islamic
/// calendar.
///
/// The tabular calendar can differ from the observed Umm al-Qura date by a
/// day around the start of a month. That is acceptable for the date line on
/// the educator's Today screen — it is orientation, not the basis of any
/// decision — and it needs no table or network. When the association wants
/// the observed calendar, the server's `HIJRI_OFFSET_DAYS` corrects it.
library;

import 'package:meta/meta.dart';

@immutable
class HijriDate {
  const HijriDate({required this.year, required this.month, required this.day});

  /// Converts the calendar date of [date] (its local year/month/day).
  factory HijriDate.fromGregorian(DateTime date, {int offsetDays = 0}) {
    final shifted = date.add(Duration(days: offsetDays));
    final jd = _julianDay(shifted.year, shifted.month, shifted.day);
    // Fliegel–Van Flandern style inverse for the tabular Hijri calendar
    // (epoch 1 Muharram 1 AH = JD 1948439.5, civil variant).
    final l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    final l2 = l - 10631 * n + 354;
    final j =
        ((10985 - l2) ~/ 5316) * ((50 * l2) ~/ 17719) +
        (l2 ~/ 5670) * ((43 * l2) ~/ 15238);
    final l3 =
        l2 -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l3) ~/ 709;
    final day = l3 - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDate(year: year, month: month, day: day);
  }

  final int year;

  /// 1 = Muharram … 12 = Dhu al-Hijjah.
  final int month;
  final int day;

  static int _julianDay(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  static const List<String> _monthsAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];
  static const List<String> _monthsLatin = [
    'Muharram',
    'Safar',
    'Rabi‘ al-awwal',
    'Rabi‘ al-thani',
    'Jumada al-ula',
    'Jumada al-akhira',
    'Rajab',
    'Sha‘ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qa‘da',
    'Dhu al-Hijja',
  ];

  /// "15 ربيع الأول 1448" / "15 Rabi‘ al-awwal 1448".
  String format(String languageCode) {
    final months = languageCode == 'ar' ? _monthsAr : _monthsLatin;
    return '$day ${months[(month - 1).clamp(0, 11)]} $year';
  }

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-$month-$day AH';
}
