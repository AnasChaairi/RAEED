import { Body, Controller, Get, HttpCode, HttpStatus, Post, UseGuards } from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CheckAbility, CheckAbilityGuard } from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { CreateFamilyDto, InvitationDto } from './dto/family.dto';
import { EducatorView, FamiliesService, FamilyCreatedView, FamilyView } from './families.service';

@Controller()
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
export class FamiliesController {
  constructor(private readonly families: FamiliesService) {}

  @Get('families')
  @CheckAbility('manage', 'Child')
  async list(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: FamilyView[]; page: { cursor: null; has_more: false } }> {
    return { data: await this.families.list(user), page: { cursor: null, has_more: false } };
  }

  @Post('families')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('manage', 'Child')
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreateFamilyDto,
  ): Promise<FamilyCreatedView> {
    return this.families.create(user, body);
  }

  @Post('invitations')
  @HttpCode(HttpStatus.OK)
  @CheckAbility('manage', 'Child')
  resend(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: InvitationDto,
  ): Promise<{ user_id: string; password: string }> {
    return this.families.resendInvitation(user, body.user_id);
  }

  @Get('educators')
  @CheckAbility('manage', 'Group')
  async educators(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: EducatorView[]; page: { cursor: null; has_more: false } }> {
    return { data: await this.families.educators(user), page: { cursor: null, has_more: false } };
  }
}
