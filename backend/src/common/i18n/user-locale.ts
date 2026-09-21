import { DataSource } from 'typeorm';

/** The three UI locales (`app_user.preferred_locale`). */
export type Locale = 'ar' | 'fr' | 'en';

/**
 * The association's timezone.
 *
 * "Today's sessions" and "this week's attendance" are questions about the
 * association's day, not the server's. Sessions are stored as instants; the
 * day boundaries are taken in Casablanca time so a 00:30 UTC session on a
 * Wednesday is Wednesday's, as everyone in the building would say.
 */
export const ORG_TIMEZONE = 'Africa/Casablanca';

/** Reads the caller's preferred locale, defaulting to Arabic. */
export async function loadLocale(
  dataSource: DataSource,
  userId: string,
): Promise<Locale> {
  const rows: Array<{ preferred_locale: string }> = await dataSource.query(
    'select preferred_locale from app_user where id = $1',
    [userId],
  );
  const locale = rows[0]?.preferred_locale;
  return locale === 'fr' || locale === 'en' ? locale : 'ar';
}

/** Picks the text for [locale] from a small template table. */
export function pick(
  locale: Locale,
  texts: { ar: string; fr: string; en: string },
): string {
  return texts[locale];
}

const WEEKDAYS: Record<Locale, string[]> = {
  ar: ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
  fr: ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'],
  en: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
};

/** A weekday name, `0` being Sunday as in `weekly_schedule_json`. */
export function weekdayName(locale: Locale, weekday: number): string {
  return WEEKDAYS[locale][((weekday % 7) + 7) % 7] ?? '';
}

/**
 * "السبت 10:00 · الأربعاء 16:00" from a group's `weekly_schedule_json`.
 *
 * Rendered server-side because the shape of that JSON is the server's to
 * change; the app shows a label, not a schedule it has to understand.
 */
export function scheduleLabel(
  locale: Locale,
  schedule: unknown,
): string | null {
  if (!Array.isArray(schedule)) return null;
  const parts: string[] = [];
  for (const slot of schedule) {
    if (typeof slot !== 'object' || slot === null) continue;
    const { weekday, starts_at: startsAt } = slot as {
      weekday?: unknown;
      starts_at?: unknown;
    };
    if (typeof weekday !== 'number' || typeof startsAt !== 'string') continue;
    parts.push(`${weekdayName(locale, weekday)} ${startsAt}`);
  }
  return parts.length === 0 ? null : parts.join(' · ');
}
