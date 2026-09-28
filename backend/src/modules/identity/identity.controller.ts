import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Ip,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard, Public } from '../../common/auth/jwt-auth.guard';
import { ApiError } from '../../common/http/api-error';
import {
  AvailabilityDto,
  ChangePasswordDto,
  LoginDto,
  RefreshDto,
  RegisterDeviceDto,
} from './dto/auth.dto';
import { CurrentUserView, IdentityService } from './identity.service';

/**
 * Auth routes (`specs/04-api/openapi.yaml`).
 *
 * `login` and `refresh` are `security: []` in the contract and carry
 * `@Public()`. Everything else on this controller is guarded — the guard is
 * applied at class level so a new route is protected by omission rather than
 * by remembering.
 */
@Controller('auth')
@UseGuards(JwtAuthGuard)
export class IdentityController {
  constructor(private readonly identity: IdentityService) {}

  @Post('login')
  @Public()
  @HttpCode(HttpStatus.OK)
  async login(
    @Body() body: LoginDto,
    @Ip() clientIp: string,
  ): Promise<{
    access_token: string;
    refresh_token: string;
  }> {
    const pair = await this.identity.login(
      body.phone,
      body.password,
      body.device_id,
      clientIp,
    );
    return {
      access_token: pair.accessToken,
      refresh_token: pair.refreshToken,
    };
  }

  @Post('refresh')
  @Public()
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() body: RefreshDto): Promise<{
    access_token: string;
    refresh_token: string;
  }> {
    const pair = await this.identity.refresh(body.refresh_token, body.device_id);
    return {
      access_token: pair.accessToken,
      refresh_token: pair.refreshToken,
    };
  }

  @Get('me')
  async me(@CurrentUser() user: AuthenticatedUser): Promise<CurrentUserView> {
    return this.identity.currentUser(user);
  }

  @Patch('me/password')
  @HttpCode(HttpStatus.NO_CONTENT)
  async changePassword(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: ChangePasswordDto,
  ): Promise<void> {
    await this.identity.changePassword(user, body.current_password, body.new_password);
  }

  @Patch('me/availability')
  setAvailability(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: AvailabilityDto,
  ): Promise<{ start: string; end: string }> {
    return this.identity.setAvailability(user, body);
  }

  @Post('devices')
  @HttpCode(HttpStatus.NO_CONTENT)
  async registerDevice(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: RegisterDeviceDto,
  ): Promise<void> {
    await this.identity.updateDevice(
      user,
      body.device_id,
      body.push_token ?? null,
      body.platform ?? null,
    );
  }

  @Delete('sessions/:deviceId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async revokeSession(
    @CurrentUser() user: AuthenticatedUser,
    @Param('deviceId') deviceId: string,
  ): Promise<void> {
    // A user may revoke only their own devices here. An Admin forcing a
    // deactivated staff member off is a separate, audit-logged admin route —
    // conflating the two would let any authenticated user pass someone else's
    // device id and sign them out.
    if (!deviceId) throw ApiError.scopeForbidden();
    await this.identity.revokeDevice(user, deviceId);
  }
}
