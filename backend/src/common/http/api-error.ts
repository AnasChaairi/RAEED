import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * The error-code catalog from `specs/04-api/conventions.md`.
 *
 * The mobile app branches on these codes and never on the message
 * (`mobile/lib/core/error/api_error_code.dart`), so a code is part of the
 * contract in a way the wording is not. Adding one here means adding it there
 * too — and the app degrades an unrecognised code rather than crashing, so the
 * two can ship out of step.
 */
export const ApiErrorCode = {
  AUTH_INVALID_CREDENTIALS: 'auth.invalid_credentials',
  AUTH_RATE_LIMITED: 'auth.rate_limited',
  SCOPE_FORBIDDEN: 'scope.forbidden',
  ATTENDANCE_CONFLICT: 'attendance.conflict',
  ATTENDANCE_UNKNOWN_CHILD: 'attendance.unknown_child',
  MEMORIES_CONSENT_BLOCKED: 'memories.consent_blocked',
  CHILDREN_LAST_GUARDIAN: 'children.last_guardian',
  GUARDIANS_PHONE_TAKEN: 'guardians.phone_taken',
  GUARDIANS_ALREADY_LINKED: 'guardians.already_linked',
  GROUPS_NO_ACTIVE_SEASON: 'groups.no_active_season',
  GROUPS_NO_BRANCH: 'groups.no_branch',
  PRESENCE_REMINDER_ALREADY_SENT: 'presence.reminder_already_sent',
  SESSION_SUMMARY_ALREADY_SENT: 'session.summary_already_sent',
  VALIDATION_FAILED: 'validation.failed',
} as const;

export type ApiErrorCodeValue =
  (typeof ApiErrorCode)[keyof typeof ApiErrorCode];

/**
 * An error that serialises to the envelope every failure shares.
 *
 * Throwing this rather than Nest's built-in exceptions is what keeps the
 * envelope uniform: a bare `ForbiddenException` would reach the client as
 * Nest's own shape, and the app's parser would fall back to `unknown` — losing
 * exactly the distinction (scope failure vs. transient) that decides whether
 * the UI offers a retry.
 */
export class ApiError extends HttpException {
  constructor(
    readonly code: ApiErrorCodeValue,
    message: string,
    status: HttpStatus,
    readonly details: Record<string, unknown> = {},
  ) {
    super({ error: { code, message, details } }, status);
  }

  /** 403 — authenticated, but outside the caller's ability scope. */
  static scopeForbidden(message = 'Outside your permitted scope.'): ApiError {
    return new ApiError(
      ApiErrorCode.SCOPE_FORBIDDEN,
      message,
      HttpStatus.FORBIDDEN,
    );
  }

  /**
   * 401 — the phone number and password do not match an active account.
   *
   * One message for every cause (`ACC-02`): whether the number exists is not
   * something an unauthenticated caller gets to learn from the wording.
   */
  static invalidCredentials(): ApiError {
    return new ApiError(
      ApiErrorCode.AUTH_INVALID_CREDENTIALS,
      'The phone number or password is not correct.',
      HttpStatus.UNAUTHORIZED,
    );
  }

  /** 429 — too many failed sign-in attempts for this number or address. */
  static rateLimited(retryAfterSeconds: number): ApiError {
    return new ApiError(
      ApiErrorCode.AUTH_RATE_LIMITED,
      'Too many failed sign-in attempts. Try again later.',
      HttpStatus.TOO_MANY_REQUESTS,
      { retry_after_seconds: retryAfterSeconds },
    );
  }

  /**
   * 409 — the incoming `recorded_at_client` predates the stored `recorded_at`.
   *
   * Carries both sides, because the client has to show the educator what they
   * marked *and* what is recorded instead: the whole point of the rule is that
   * neither side is silently discarded.
   */
  static attendanceConflict(details: {
    child_id: string;
    current: {
      status: string;
      recorded_at: string;
      /**
       * Who holds the winning mark.
       *
       * Absent for now: `app_user` has no display-name column
       * (`specs/03-domain-model/schema.sql`), and the phone number is the only
       * other identifier — which MSG-06 forbids returning to a non-executive
       * role. The client renders the conflict without it rather than being
       * handed something it must not show.
       */
      recorded_by_name?: string;
    };
  }): ApiError {
    return new ApiError(
      ApiErrorCode.ATTENDANCE_CONFLICT,
      'This child was already marked from another device.',
      HttpStatus.CONFLICT,
      details,
    );
  }

  /** 422 — the child is not enrolled in this session's group. */
  static attendanceUnknownChild(childId: string): ApiError {
    return new ApiError(
      ApiErrorCode.ATTENDANCE_UNKNOWN_CHILD,
      'That child is not enrolled in this session’s group.',
      HttpStatus.UNPROCESSABLE_ENTITY,
      { child_id: childId },
    );
  }

  /**
   * 422 — a tagged child's current image rights forbid this post (`WAL-06`).
   *
   * Raised at publish time and again at approval time, because consent can
   * change between the two; `details.child_ids` names the children whose
   * guardians said no, so the educator knows which photo to remove.
   */
  static memoriesConsentBlocked(childIds: string[]): ApiError {
    return new ApiError(
      ApiErrorCode.MEMORIES_CONSENT_BLOCKED,
      'A tagged child’s image rights do not allow this post.',
      HttpStatus.UNPROCESSABLE_ENTITY,
      { child_ids: childIds },
    );
  }

  /**
   * 409 — unlinking this guardian would leave a child with none (`ACC-05`).
   *
   * `details.child_ids` names them, so the executive sees which child still
   * needs another guardian before this one can go.
   */
  static childrenLastGuardian(childIds: string[]): ApiError {
    return new ApiError(
      ApiErrorCode.CHILDREN_LAST_GUARDIAN,
      'A child would be left without a guardian.',
      HttpStatus.CONFLICT,
      { child_ids: childIds },
    );
  }

  /** 409 — another account already signs in with that phone number. */
  static guardianPhoneTaken(): ApiError {
    return new ApiError(
      ApiErrorCode.GUARDIANS_PHONE_TAKEN,
      'Another account already uses this phone number.',
      HttpStatus.CONFLICT,
    );
  }

  /** 409 — the account is already a guardian of every child of the household. */
  static guardianAlreadyLinked(): ApiError {
    return new ApiError(
      ApiErrorCode.GUARDIANS_ALREADY_LINKED,
      'This account is already a guardian of these children.',
      HttpStatus.CONFLICT,
    );
  }

  /**
   * 422 — a group needs an active season and there is none.
   *
   * Its own code rather than a generic validation failure: nothing on the
   * form is wrong, and the app has to send the admin to Structure, not back
   * to the fields.
   */
  static groupsNoActiveSeason(): ApiError {
    return new ApiError(
      ApiErrorCode.GROUPS_NO_ACTIVE_SEASON,
      'No active season: open one before creating a group.',
      HttpStatus.UNPROCESSABLE_ENTITY,
    );
  }

  /** 422 — a group needs a branch and none exists yet. */
  static groupsNoBranch(): ApiError {
    return new ApiError(
      ApiErrorCode.GROUPS_NO_BRANCH,
      'No branch exists yet: add one before creating a group.',
      HttpStatus.UNPROCESSABLE_ENTITY,
    );
  }

  /** 409 — the one reminder a presence confirmation allows was already sent. */
  static presenceReminderAlreadySent(): ApiError {
    return new ApiError(
      ApiErrorCode.PRESENCE_REMINDER_ALREADY_SENT,
      'The reminder for this session was already sent.',
      HttpStatus.CONFLICT,
    );
  }

  /** 409 — the session summary goes out once. */
  static summaryAlreadySent(): ApiError {
    return new ApiError(
      ApiErrorCode.SESSION_SUMMARY_ALREADY_SENT,
      'The summary for this session was already sent.',
      HttpStatus.CONFLICT,
    );
  }

  /** 422 — DTO-level validation failure; `details` carries the field errors. */
  static validationFailed(details: Record<string, unknown>): ApiError {
    return new ApiError(
      ApiErrorCode.VALIDATION_FAILED,
      'Some fields are not valid.',
      HttpStatus.UNPROCESSABLE_ENTITY,
      details,
    );
  }
}
