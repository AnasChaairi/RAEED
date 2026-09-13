import {
  CanActivate,
  ExecutionContext,
  Injectable,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

import { ApiError } from '../http/api-error';
import { AuthenticatedRequest } from '../auth/current-user.decorator';
import { AbilityAction, AbilitySubject, defineAbilityFor } from './define-ability';

export const ABILITY_RULE = 'raeed:ability';

export interface AbilityRule {
  readonly action: AbilityAction;
  readonly subject: AbilitySubject;
}

/**
 * Declares the permission a route needs (`specs/07-backend-spec.md`).
 *
 * Used as `@CheckAbility('read', 'Dashboard')`. It answers the *type-level*
 * question — could this caller ever do this — which is enough for routes that
 * do not name a resource.
 *
 * Routes that act on a specific child, group or session must additionally check
 * the loaded resource, because scope is a relationship and the guard cannot
 * know one before the row is fetched. Those services call `ability.can(...)`
 * against the resolved row and throw `ApiError.scopeForbidden()`; the
 * repository-level helpers make that hard to forget.
 */
export const CheckAbility = (
  action: AbilityAction,
  subject: AbilitySubject,
): MethodDecorator & ClassDecorator =>
  SetMetadata(ABILITY_RULE, { action, subject } satisfies AbilityRule);

@Injectable()
export class CheckAbilityGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const rule = this.reflector.getAllAndOverride<AbilityRule | undefined>(
      ABILITY_RULE,
      [context.getHandler(), context.getClass()],
    );
    if (!rule) return true;

    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const user = request.user;
    if (!user) throw ApiError.scopeForbidden();

    const ability = defineAbilityFor(user);
    if (!ability.can(rule.action, rule.subject)) {
      // 403 rather than 404. `specs/11-testing-strategy.md` flags this as a
      // decision to make consistently: RAEED tells an authenticated caller
      // "not yours" rather than "does not exist", so a parent who mistypes a
      // link gets a message they can act on. Resource *existence* is not
      // itself sensitive here — the contents are, and those stay unreachable.
      throw ApiError.scopeForbidden();
    }
    return true;
  }
}
