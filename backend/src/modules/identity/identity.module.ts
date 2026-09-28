import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';

import { ScopeService } from '../../common/abilities/scope.service';
import { IdentityController } from './identity.controller';
import { IdentityService } from './identity.service';
import { LoginThrottle } from './login-throttle.service';
import { PasswordService } from './password.service';
import { TokenService } from './token.service';

/**
 * `identity` — passwords, JWT issuance, role assignment, devices
 * (`specs/07-backend-spec.md`).
 *
 * Exports ScopeService and JwtModule because `JwtAuthGuard` runs in every other
 * module and needs both to verify a token and resolve the caller's live scope.
 * IdentityService and PasswordService are exported for the provisioning path:
 * an executive creating a family hands each new guardian a generated
 * password, and the hashing has exactly one implementation.
 */
@Module({
  imports: [JwtModule.register({})],
  controllers: [IdentityController],
  providers: [IdentityService, PasswordService, LoginThrottle, TokenService, ScopeService],
  exports: [ScopeService, TokenService, JwtModule, IdentityService, PasswordService],
})
export class IdentityModule {}
