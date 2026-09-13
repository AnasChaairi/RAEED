import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';

import { ScopeService } from '../../common/abilities/scope.service';
import { IdentityController } from './identity.controller';
import { IdentityService } from './identity.service';
import { OtpService } from './otp.service';
import { TokenService } from './token.service';

/**
 * `identity` — OTP, JWT issuance, role assignment, devices
 * (`specs/07-backend-spec.md`).
 *
 * Exports ScopeService and JwtModule because `JwtAuthGuard` runs in every other
 * module and needs both to verify a token and resolve the caller's live scope.
 * That guard is the only thing crossing this boundary, and it crosses through
 * an exported surface rather than by reaching for a repository.
 */
@Module({
  imports: [JwtModule.register({})],
  controllers: [IdentityController],
  providers: [IdentityService, OtpService, TokenService, ScopeService],
  exports: [ScopeService, TokenService, JwtModule],
})
export class IdentityModule {}
