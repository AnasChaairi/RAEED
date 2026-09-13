import { createParamDecorator, ExecutionContext } from '@nestjs/common';

import { AuthenticatedUser } from '../abilities/authenticated-user';

/** The request, once the auth guard has resolved the caller onto it. */
export interface AuthenticatedRequest {
  user?: AuthenticatedUser;
  deviceId?: string;
}

/**
 * Injects the resolved caller.
 *
 * Always populated on a guarded route — the guard rejects before the handler
 * runs — so handlers take it non-nullable rather than defensively checking.
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext): AuthenticatedUser => {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    if (!request.user) {
      throw new Error(
        'CurrentUser used on a route with no auth guard — add @UseGuards(JwtAuthGuard).',
      );
    }
    return request.user;
  },
);
