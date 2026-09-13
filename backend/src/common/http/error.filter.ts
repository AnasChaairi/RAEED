import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';

import { ApiErrorCode } from './api-error';

/**
 * Gives every failure the same envelope (`specs/04-api/conventions.md`).
 *
 * Two rules matter here and both are about what does *not* leave the process:
 *
 * - An unexpected error never reaches the client as its own message. A stack
 *   trace or a database error can carry a child's name, a health note or a
 *   phone number straight into a response body; those are exactly what
 *   `specs/10-security-and-privacy.md` forbids exporting. The client gets a
 *   generic message and the server keeps the detail.
 * - The server-side log records the failure but never the request body, for
 *   the same reason.
 */
@Catch()
export class ErrorEnvelopeFilter implements ExceptionFilter {
  private readonly logger = new Logger('http');

  catch(exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<Response>();
    const request = host.switchToHttp().getRequest<{
      method: string;
      url: string;
    }>();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse();

      // Already enveloped by ApiError.
      if (isEnvelope(body)) {
        response.status(status).json(body);
        return;
      }

      // A built-in Nest exception (guards, pipes, 404s). Wrap it so the client
      // sees one shape regardless of who threw.
      response.status(status).json({
        error: {
          code: codeForStatus(status),
          message: messageOf(body, exception.message),
          details: {},
        },
      });
      return;
    }

    // Genuinely unexpected. Log it with the route but without the payload.
    this.logger.error(
      `Unhandled error on ${request.method} ${request.url}`,
      exception instanceof Error ? exception.stack : String(exception),
    );

    response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      error: {
        code: 'server.error',
        message: 'Something went wrong.',
        details: {},
      },
    });
  }
}

function isEnvelope(body: unknown): body is { error: unknown } {
  return (
    typeof body === 'object' &&
    body !== null &&
    'error' in body &&
    typeof (body as { error: unknown }).error === 'object'
  );
}

function messageOf(body: unknown, fallback: string): string {
  if (typeof body === 'string') return body;
  if (
    typeof body === 'object' &&
    body !== null &&
    'message' in body &&
    typeof (body as { message: unknown }).message === 'string'
  ) {
    return (body as { message: string }).message;
  }
  return fallback;
}

/**
 * Maps a bare HTTP status onto a catalog code.
 *
 * 403 becomes `scope.forbidden` specifically: the ability guard is the only
 * thing that produces a 403, and the client treats that code as terminal —
 * no retry offered — which is the correct behaviour for a scope refusal.
 */
function codeForStatus(status: number): string {
  switch (status) {
    case HttpStatus.UNAUTHORIZED:
      return 'auth.unauthenticated';
    case HttpStatus.FORBIDDEN:
      return ApiErrorCode.SCOPE_FORBIDDEN;
    case HttpStatus.NOT_FOUND:
      return 'resource.not_found';
    case HttpStatus.UNPROCESSABLE_ENTITY:
      return ApiErrorCode.VALIDATION_FAILED;
    case HttpStatus.TOO_MANY_REQUESTS:
      return 'rate.limited';
    default:
      return 'server.error';
  }
}
