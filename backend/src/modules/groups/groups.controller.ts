import { Controller, Get, Param, ParseUUIDPipe, UseGuards } from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import {
  CheckAbility,
  CheckAbilityGuard,
} from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { GroupSessionView, GroupsService, GroupView } from './groups.service';

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

  @Get(':groupId')
  detail(
    @CurrentUser() user: AuthenticatedUser,
    @Param('groupId', ParseUUIDPipe) groupId: string,
  ): Promise<GroupView> {
    return this.groups.detail(user, groupId);
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
