import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CheckAbility, CheckAbilityGuard } from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { CreateBranchDto } from './dto/structure.dto';
import { BranchView, CategoryView, SeasonView, StructureService } from './structure.service';

/**
 * Structure is the admin's (`specs/05-authorization.md`: manage on Season /
 * Category); reading the category names is open to every signed-in user,
 * since the app filters lists by them and they are printed on every group.
 */
@Controller()
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
export class StructureController {
  constructor(private readonly structure: StructureService) {}

  @Get('seasons')
  @CheckAbility('manage', 'Season')
  async seasons(): Promise<{ data: SeasonView[] }> {
    return { data: await this.structure.seasons() };
  }

  @Post('seasons/:seasonId/archive')
  @HttpCode(HttpStatus.NO_CONTENT)
  @CheckAbility('manage', 'Season')
  archive(
    @CurrentUser() user: AuthenticatedUser,
    @Param('seasonId', ParseUUIDPipe) seasonId: string,
  ): Promise<void> {
    return this.structure.archiveSeason(user, seasonId);
  }

  @Get('categories')
  async categories(): Promise<{ data: CategoryView[] }> {
    return { data: await this.structure.categories() };
  }

  @Get('branches')
  @CheckAbility('manage', 'Season')
  async branches(): Promise<{ data: BranchView[] }> {
    return { data: await this.structure.branches() };
  }

  @Post('branches')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('manage', 'Season')
  createBranch(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreateBranchDto,
  ): Promise<BranchView> {
    return this.structure.createBranch(user, body);
  }
}
