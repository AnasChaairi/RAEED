/// Age derivation.
///
/// Its own file, and a pure function, because the Parent Home card shows an age
/// and nothing else in the app should ever recompute one differently. A child's
/// age decides which فئة (category) they belong in, so an off-by-one here is
/// not cosmetic.
library;

/// The number of whole years between [dob] and [on].
///
/// Counts completed birthdays, so a child turns 7 on their birthday and not the
/// day before. Both arguments are reduced to calendar days first: comparing the
/// raw timestamps would make a child born at 18:00 a year younger for the first
/// eighteen hours of every birthday.
///
/// Returns null when [dob] is in the future — a data-entry mistake that should
/// render as "unknown" rather than as a negative age.
int? ageInYearsOn(DateTime dob, DateTime on) {
  final birth = DateTime(dob.year, dob.month, dob.day);
  final today = DateTime(on.year, on.month, on.day);
  if (birth.isAfter(today)) return null;

  var years = today.year - birth.year;
  final hadBirthdayThisYear =
      today.month > birth.month ||
      (today.month == birth.month && today.day >= birth.day);
  if (!hadBirthdayThisYear) years -= 1;
  return years;
}
