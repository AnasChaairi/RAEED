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
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CheckAbility, CheckAbilityGuard } from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import {
  CreateFamilyDto,
  InvitationDto,
  NewChildDto,
  NewGuardianDto,
  UpdateChildDto,
  UpdateGuardianDto,
} from './dto/family.dto';
import {
  ChildAddedView,
  EducatorView,
  FamiliesService,
  FamilyCreatedView,
  FamilyView,
  GuardianLinkedView,
} from './families.service';
import { ParseFamilyIdPipe } from './family-id.pipe';

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

  // --- One household (EXEC-M-10b). The id is the guardian set, so every
  // mutation answers with the family as it now is.

  @Get('families/:familyId')
  @CheckAbility('manage', 'Child')
  get(
    @CurrentUser() user: AuthenticatedUser,
    @Param('familyId', ParseFamilyIdPipe) guardianIds: string[],
  ): Promise<FamilyView> {
    return this.families.get(user, guardianIds);
  }

  @Post('families/:familyId/guardians')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('manage', 'Child')
  addGuardian(
    @CurrentUser() user: AuthenticatedUser,
    @Param('familyId', ParseFamilyIdPipe) guardianIds: string[],
    @Body() body: NewGuardianDto,
  ): Promise<GuardianLinkedView> {
    return this.families.addGuardian(user, guardianIds, body);
  }

  @Patch('families/:familyId/guardians/:guardianId')
  @CheckAbility('manage', 'Child')
  updateGuardian(
    @CurrentUser() user: AuthenticatedUser,
    @Param('familyId', ParseFamilyIdPipe) guardianIds: string[],
    @Param('guardianId', ParseUUIDPipe) guardianId: string,
    @Body() body: UpdateGuardianDto,
  ): Promise<FamilyView> {
    return this.families.updateGuardian(user, guardianIds, guardianId, body);
  }

  @Delete('families/:familyId/guardians/:guardianId')
  @HttpCode(HttpStatus.OK)
  @CheckAbility('manage', 'Child')
  unlinkGuardian(
    @CurrentUser() user: AuthenticatedUser,
    @Param('familyId', ParseFamilyIdPipe) guardianIds: string[],
    @Param('guardianId', ParseUUIDPipe) guardianId: string,
  ): Promise<FamilyView> {
    return this.families.unlinkGuardian(user, guardianIds, guardianId);
  }

  @Post('families/:familyId/children')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('manage', 'Child')
  addChild(
    @CurrentUser() user: AuthenticatedUser,
    @Param('familyId', ParseFamilyIdPipe) guardianIds: string[],
    @Body() body: NewChildDto,
  ): Promise<ChildAddedView> {
    return this.families.addChild(user, guardianIds, body);
  }

  @Patch('families/:familyId/children/:childId')
  @CheckAbility('manage', 'Child')
  updateChild(
    @CurrentUser() user: AuthenticatedUser,
    @Param('familyId', ParseFamilyIdPipe) guardianIds: string[],
    @Param('childId', ParseUUIDPipe) childId: string,
    @Body() body: UpdateChildDto,
  ): Promise<FamilyView> {
    return this.families.updateChild(user, guardianIds, childId, body);
  }

  @Get('educators')
  @CheckAbility('manage', 'Group')
  async educators(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: EducatorView[]; page: { cursor: null; has_more: false } }> {
    return { data: await this.families.educators(user), page: { cursor: null, has_more: false } };
  }
}
