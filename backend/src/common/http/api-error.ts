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
  AUTH_OTP_INVALID: 'auth.otp_invalid',
  AUTH_OTP_RATE_LIMITED: 'auth.otp_rate_limited',
  SCOPE_FORBIDDEN: 'scope.forbidden',
  ATTENDANCE_CONFLICT: 'attendance.conflict',
  ATTENDANCE_UNKNOWN_CHILD: 'attendance.unknown_child',
  MEMORIES_CONSENT_BLOCKED: 'memories.consent_blocked',
  CHILDREN_LAST_GUARDIAN: 'children.last_guardian',
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

  /** 401 — wrong or expired one-time code. */
  static otpInvalid(): ApiError {
    return new ApiError(
      ApiErrorCode.AUTH_OTP_INVALID,
      'That code is wrong or has expired.',
      HttpStatus.UNAUTHORIZED,
    );
  }

  /** 429 — too many OTP requests for this number. */
  static otpRateLimited(retryAfterSeconds: number): ApiError {
    return new ApiError(
      ApiErrorCode.AUTH_OTP_RATE_LIMITED,
      'Too many codes requested for this number.',
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
