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
 * Exports ScopeService because the auth guard in every other module needs to
 * resolve a caller's scope; that is the one service crossing this boundary,
 * and it is exported deliberately rather than by reaching for a repository.
 */
@Module({
  imports: [JwtModule.register({})],
  controllers: [IdentityController],
  providers: [IdentityService, OtpService, TokenService, ScopeService],
  exports: [ScopeService, TokenService],
})
export class IdentityModule {}
