import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import {
  AttendanceSheetView,
  AttendanceService,
} from './attendance.service';
import { PatchAttendanceDto, PresenceAnswerInputDto } from './dto/attendance.dto';
import { PendingConfirmationView, PresenceService } from './presence.service';

@Controller()
@UseGuards(JwtAuthGuard)
export class AttendanceController {
  constructor(
    private readonly attendance: AttendanceService,
    private readonly presence: PresenceService,
  ) {}

  @Get('sessions/:sessionId/attendance')
  async sheet(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
  ): Promise<AttendanceSheetView> {
    return this.attendance.sheet(user, sessionId);
  }

  /**
   * Submits the sheet.
   *
   * Any unexplained absence enqueues its alert on the critical queue *before*
   * this returns (`specs/04-api/openapi.yaml`), which is what makes "instant"
   * a property of the write rather than of a background sweep.
   */
  @Patch('sessions/:sessionId/attendance')
  @HttpCode(HttpStatus.OK)
  async patch(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
    @Body() body: PatchAttendanceDto,
  ): Promise<{ applied: string[]; alerts_enqueued: string[] }> {
    const result = await this.attendance.apply(user, sessionId, body.records);
    return {
      applied: result.applied,
      alerts_enqueued: result.alertsEnqueued,
    };
  }

  @Get('presence-confirmations/pending')
  async pending(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: PendingConfirmationView[] }> {
    return { data: await this.presence.pending(user) };
  }

  @Post('presence-confirmations/:confirmationId/answers')
  @HttpCode(HttpStatus.OK)
  async answer(
    @CurrentUser() user: AuthenticatedUser,
    @Param('confirmationId', ParseUUIDPipe) confirmationId: string,
    @Body() body: PresenceAnswerInputDto,
  ): Promise<{ recorded: true }> {
    await this.presence.answer(user, confirmationId, body);
    return { recorded: true };
  }
}
