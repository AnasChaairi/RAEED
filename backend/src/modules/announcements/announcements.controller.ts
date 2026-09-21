import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import {
  CheckAbility,
  CheckAbilityGuard,
} from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import {
  AnnouncementsService,
  AnnouncementView,
  ExecutiveAnnouncementView,
  ReachView,
} from './announcements.service';
import { CreateAnnouncementDto } from './dto/announcement.dto';

@Controller('announcements')
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
export class AnnouncementsController {
  constructor(private readonly announcements: AnnouncementsService) {}

  @Get()
  @CheckAbility('read', 'Announcement')
  async list(
    @CurrentUser() user: AuthenticatedUser,
    @Query('cursor') _cursor?: string,
  ): Promise<{
    data: AnnouncementView[] | ExecutiveAnnouncementView[];
    page: { cursor: string | null; has_more: boolean };
  }> {
    return {
      data: await this.announcements.list(user),
      page: { cursor: null, has_more: false },
    };
  }

  /** Reach counts for the composer's audience picker. */
  @Get('reach')
  @CheckAbility('create', 'Announcement')
  reach(@CurrentUser() user: AuthenticatedUser): Promise<ReachView> {
    return this.announcements.reach(user);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('create', 'Announcement')
  publish(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreateAnnouncementDto,
  ): Promise<{ id: string }> {
    return this.announcements.publish(user, body);
  }
}
