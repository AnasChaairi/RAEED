/**
 * The SQL for a user's display name, as an expression usable in a select
 * list.
 *
 * Centralised so that no query ever falls back to the phone number when the
 * name is missing: `MSG-06` forbids showing a phone to anyone but an
 * executive, and an empty string is the honest rendering of an account whose
 * name has not been entered yet.
 */
export function displayNameOf(userIdExpression: string): string {
  // The alias is deliberately unusual: a caller's own `u` alias must not be
  // shadowed, or `u.id = u.id` would match every user.
  return `(select coalesce(dn_.display_name, '') from app_user dn_ where dn_.id = ${userIdExpression})`;
}
