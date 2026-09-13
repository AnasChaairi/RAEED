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

@Controller()
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
export class ChildrenController {
  constructor(
    private readonly children: ChildrenService,
    private readonly consent: ConsentService,
  ) {}

  @Get('children')
  async list(
    @CurrentUser() user: AuthenticatedUser,
    @Query('group_id') groupId?: string,
    @Query('cursor') cursor?: string,
  ): Promise<{
    data: ChildListItem[];
    page: { cursor: string | null; has_more: boolean };
  }> {
    const { items, nextCursor } = await this.children.list(user, {
      groupId,
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
  ): Promise<ChildDetailView> {
    // Every read of a child's health information is separately audit-logged
    // (`AUD-03`). The audit interceptor covering this route lands with the
    // audit module; until then the read is still scope-checked against the
    // loaded row inside the service.
    return this.children.detail(user, childId);
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
