import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CheckAbilityGuard } from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { ChildDetailView, ChildListItem, ChildrenService } from './children.service';
import { ConsentService, ConsentRequirementView } from './consent.service';
import { SubmitConsentDto } from './dto/consent.dto';
import {
  ExecutiveChildrenService,
  ExecutiveChildView,
  GuardianPhoneView,
  HealthView,
} from './executive-children.service';

@Controller()
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
export class ChildrenController {
  constructor(
    private readonly children: ChildrenService,
    private readonly consent: ConsentService,
    private readonly executive: ExecutiveChildrenService,
  ) {}

  @Get('children')
  async list(
    @CurrentUser() user: AuthenticatedUser,
    @Query('group_id') groupId?: string,
    @Query('category_id') categoryId?: string,
    @Query('q') query?: string,
    @Query('unassigned') unassigned?: string,
    @Query('cursor') cursor?: string,
  ): Promise<{
    data: ChildListItem[];
    page: { cursor: string | null; has_more: boolean };
  }> {
    const { items, nextCursor } = await this.children.list(user, {
      groupId,
      categoryId,
      query,
      unassigned: unassigned === 'true',
      cursor,
      limit: 50,
    });
    return {
      data: items,
      page: { cursor: nextCursor, has_more: nextCursor !== null },
    };
  }

  @Get('children/:childId')
  async detail(
    @CurrentUser() user: AuthenticatedUser,
    @Param('childId', ParseUUIDPipe) childId: string,
  ): Promise<ChildDetailView | ExecutiveChildView> {
    // An executive gets the oversight profile — guardians, consents, groups —
    // with the health text withheld; they read that through the logged
    // route below (`AUD-03`). A guardian or educator gets the profile as
    // before, health included, by relationship.
    if (user.hasOversight) return this.executive.detail(user, childId);
    return this.children.detail(user, childId);
  }

  /** A deliberate, recorded read of a child's health information (`AUD-03`). */
  @Get('children/:childId/health')
  health(
    @CurrentUser() user: AuthenticatedUser,
    @Param('childId', ParseUUIDPipe) childId: string,
  ): Promise<HealthView> {
    return this.executive.health(user, childId);
  }

  /** A recorded reveal of a guardian's phone number (`MSG-06`). */
  @Get('children/:childId/guardians/:guardianId/phone')
  guardianPhone(
    @CurrentUser() user: AuthenticatedUser,
    @Param('childId', ParseUUIDPipe) childId: string,
    @Param('guardianId', ParseUUIDPipe) guardianId: string,
  ): Promise<GuardianPhoneView> {
    return this.executive.guardianPhone(user, childId, guardianId);
  }

  @Get('consent')
  async consentRequirement(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ConsentRequirementView> {
    return this.consent.requirement(user);
  }

  @Post('consent')
  @HttpCode(HttpStatus.NO_CONTENT)
  async submitConsent(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: SubmitConsentDto,
  ): Promise<void> {
    // Every field is validated by the DTO now, including each entry's level,
    // so there is nothing left for the controller to check by hand.
    await this.consent.submit(
      user,
      body.privacy_policy_accepted,
      body.image_rights,
    );
  }
}
