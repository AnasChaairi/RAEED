import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CheckAbility, CheckAbilityGuard } from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { ApiError } from '../../common/http/api-error';
import {
  AddMaterialDto,
  ChangeSessionDto,
  CreateHomeworkDto,
  CreateSessionDto,
  SendSummaryDto,
  UpdateSessionDto,
} from './dto/session.dto';
import { EducatorTodayService, TodayView } from './educator-today.service';
import { GroupHomeworkView, HomeworkService } from './homework.service';
import {
  HomeworkView,
  MaterialView,
  PresenceOverviewView,
  SessionDetailView,
  SessionListItem,
  SessionsService,
} from './sessions.service';

const MAX_RANGE_DAYS = 62;

/**
 * Sessions, their content, homework and the educator's Today. Reads need
 * `read Session`; writes `update Session` (an educator on their own groups,
 * oversight on all) — the service re-checks against the session's own group.
 */
@Controller()
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
@CheckAbility('read', 'Session')
export class SessionsController {
  constructor(
    private readonly sessions: SessionsService,
    private readonly homework: HomeworkService,
    private readonly today: EducatorTodayService,
  ) {}

  @Get('educator/today')
  educatorToday(@CurrentUser() user: AuthenticatedUser): Promise<TodayView> {
    return this.today.today(user);
  }

  @Get('sessions')
  async list(
    @CurrentUser() user: AuthenticatedUser,
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('group_id') groupId?: string,
  ): Promise<{ data: SessionListItem[]; page: { cursor: null; has_more: false } }> {
    const start = from ? new Date(from) : startOfToday();
    const end = to ? new Date(to) : new Date(start.getTime() + 7 * 24 * 3600 * 1000);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw ApiError.validationFailed({ from: 'ISO-8601 dates' });
    }
    if (end.getTime() - start.getTime() > MAX_RANGE_DAYS * 24 * 3600 * 1000) {
      throw ApiError.validationFailed({ to: `at most ${MAX_RANGE_DAYS} days after from` });
    }
    return {
      data: await this.sessions.list(user, { from: start, to: end, groupId }),
      page: { cursor: null, has_more: false },
    };
  }

  /** An activity the educator adds by hand for one of their groups (EDU-M-03). */
  @Post('sessions')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('create', 'Session')
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreateSessionDto,
  ): Promise<SessionDetailView> {
    return this.sessions.create(user, body);
  }

  @Get('sessions/:sessionId')
  detail(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
  ): Promise<SessionDetailView> {
    return this.sessions.detail(user, sessionId);
  }

  @Patch('sessions/:sessionId')
  @CheckAbility('update', 'Session')
  update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
    @Body() body: UpdateSessionDto,
  ): Promise<SessionDetailView> {
    return this.sessions.update(user, sessionId, body);
  }

  @Post('sessions/:sessionId/materials')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('update', 'Session')
  addMaterial(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
    @Body() body: AddMaterialDto,
  ): Promise<MaterialView> {
    return this.sessions.addMaterial(user, sessionId, body);
  }

  @Delete('materials/:materialId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @CheckAbility('update', 'Session')
  removeMaterial(
    @CurrentUser() user: AuthenticatedUser,
    @Param('materialId', ParseUUIDPipe) materialId: string,
  ): Promise<void> {
    return this.sessions.removeMaterial(user, materialId);
  }

  @Post('sessions/:sessionId/cancel')
  @HttpCode(HttpStatus.OK)
  @CheckAbility('update', 'Session')
  change(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
    @Body() body: ChangeSessionDto,
  ): Promise<{ notified_count: number; guardian_count: number }> {
    return this.sessions.change(user, sessionId, body);
  }

  @Post('sessions/:sessionId/summary')
  @HttpCode(HttpStatus.OK)
  @CheckAbility('update', 'Session')
  summary(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
    @Body() body: SendSummaryDto,
  ): Promise<{ sent_at: string; family_count: number }> {
    return this.sessions.sendSummary(user, sessionId, body);
  }

  @Get('sessions/:sessionId/presence')
  presence(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
  ): Promise<PresenceOverviewView> {
    return this.sessions.presence(user, sessionId);
  }

  @Post('sessions/:sessionId/presence/remind')
  @HttpCode(HttpStatus.OK)
  @CheckAbility('update', 'Session')
  remind(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
  ): Promise<{ reminded_count: number; sent_at: string }> {
    return this.sessions.remind(user, sessionId);
  }

  @Post('sessions/:sessionId/homework')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('create', 'Homework')
  createHomework(
    @CurrentUser() user: AuthenticatedUser,
    @Param('sessionId', ParseUUIDPipe) sessionId: string,
    @Body() body: CreateHomeworkDto,
  ): Promise<HomeworkView> {
    return this.homework.create(user, sessionId, body);
  }

  @Get('groups/:groupId/homework')
  @CheckAbility('read', 'Homework')
  async groupHomework(
    @CurrentUser() user: AuthenticatedUser,
    @Param('groupId', ParseUUIDPipe) groupId: string,
  ): Promise<{ data: GroupHomeworkView[]; page: { cursor: null; has_more: false } }> {
    return {
      data: await this.homework.listForGroup(user, groupId),
      page: { cursor: null, has_more: false },
    };
  }
}

function startOfToday(): Date {
  const now = new Date();
  now.setUTCHours(0, 0, 0, 0);
  return now;
}
