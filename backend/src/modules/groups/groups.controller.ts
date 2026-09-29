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
import {
  CheckAbility,
  CheckAbilityGuard,
} from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { AssignChildrenDto, CreateGroupDto, UpdateGroupScheduleDto } from './dto/group.dto';
import { GroupSessionView, GroupsService, GroupView, RosterChildView } from './groups.service';

@Controller('groups')
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
@CheckAbility('read', 'Group')
export class GroupsController {
  constructor(private readonly groups: GroupsService) {}

  @Get()
  async list(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: GroupView[]; page: { cursor: null; has_more: false } }> {
    return {
      data: await this.groups.list(user),
      page: { cursor: null, has_more: false },
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('create', 'Group')
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreateGroupDto,
  ): Promise<GroupView> {
    return this.groups.create(user, body);
  }

  @Post(':groupId/children')
  @HttpCode(HttpStatus.OK)
  @CheckAbility('update', 'Group')
  assign(
    @CurrentUser() user: AuthenticatedUser,
    @Param('groupId', ParseUUIDPipe) groupId: string,
    @Body() body: AssignChildrenDto,
  ): Promise<{ enrolled_count: number; capacity: number | null }> {
    return this.groups.assign(user, groupId, body);
  }

  /** The roster as the educator sees it (EDU-M-06): flags, not text. */
  @Get(':groupId/roster')
  async roster(
    @CurrentUser() user: AuthenticatedUser,
    @Param('groupId', ParseUUIDPipe) groupId: string,
  ): Promise<{ data: RosterChildView[]; page: { cursor: null; has_more: false } }> {
    return {
      data: await this.groups.roster(user, groupId),
      page: { cursor: null, has_more: false },
    };
  }

  @Get(':groupId')
  detail(
    @CurrentUser() user: AuthenticatedUser,
    @Param('groupId', ParseUUIDPipe) groupId: string,
  ): Promise<GroupView> {
    return this.groups.detail(user, groupId);
  }

  @Patch(':groupId')
  @CheckAbility('update', 'Group')
  updateSchedule(
    @CurrentUser() user: AuthenticatedUser,
    @Param('groupId', ParseUUIDPipe) groupId: string,
    @Body() body: UpdateGroupScheduleDto,
  ): Promise<GroupView> {
    return this.groups.updateSchedule(user, groupId, body);
  }

  @Get(':groupId/sessions')
  async sessions(
    @CurrentUser() user: AuthenticatedUser,
    @Param('groupId', ParseUUIDPipe) groupId: string,
  ): Promise<{
    data: GroupSessionView[];
    page: { cursor: null; has_more: false };
  }> {
    return {
      data: await this.groups.sessions(user, groupId),
      page: { cursor: null, has_more: false },
    };
  }
}
