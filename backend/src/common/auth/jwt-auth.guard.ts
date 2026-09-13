import {
  CanActivate,
  ExecutionContext,
  Injectable,
  SetMetadata,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';

import { ScopeService } from '../abilities/scope.service';
import { loadConfig } from '../config/env';
import { AuthenticatedRequest } from './current-user.decorator';

export const IS_PUBLIC = 'raeed:public';

/**
 * Marks a route as reachable without a token.
 *
 * Only the OTP endpoints and `/auth/refresh` carry this
 * (`specs/04-api/conventions.md`), plus the health check. Everything else is
 * guarded by default, because a route that forgets to opt *in* to
 * authentication is a route that leaks; a route that forgets to opt *out*
 * merely returns 401 and gets noticed immediately.
 */
export const Public = (): MethodDecorator & ClassDecorator =>
  SetMetadata(IS_PUBLIC, true);

/**
 * Verifies the access token and resolves the caller's live scope.
 *
 * The token carries a user id. Roles and reachable children/groups are loaded
 * from the database on every request rather than read from claims — so
 * unlinking a guardian or deactivating an account takes effect on the next
 * call, not whenever a 15-minute token happens to expire.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  private readonly config = loadConfig();

  constructor(
    private readonly reflector: Reflector,
    private readonly jwt: JwtService,
    private readonly scope: ScopeService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const request = context.switchToHttp().getRequest<
      AuthenticatedRequest & { headers: Record<string, string | undefined> }
    >();

    const header = request.headers.authorization ?? '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw new UnauthorizedException('Missing bearer token.');

    let payload: { sub: string; device_id?: string };
    try {
      payload = await this.jwt.verifyAsync(token, {
        secret: this.config.jwt.accessSecret,
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired token.');
    }

    const user = await this.scope.resolve(payload.sub);
    if (!user) {
      // The account was deleted or deactivated while the token was still
      // inside its 15-minute window (`ACC-07`).
      throw new UnauthorizedException('This account is no longer active.');
    }

    request.user = user;
    request.deviceId = payload.device_id;
    return true;
  }
}
