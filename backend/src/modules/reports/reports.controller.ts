import { Body, Controller, Get, HttpCode, HttpStatus, Post, UseGuards } from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CheckAbility, CheckAbilityGuard } from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { CreateExportDto } from './dto/export.dto';
import {
  EducatorActivityRow,
  EngagementView,
  ExportView,
  RateRow,
  ReportsService,
} from './reports.service';

@Controller('reports')
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
@CheckAbility('read', 'Dashboard')
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}

  @Get('attendance')
  attendance(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ by_educator: RateRow[]; by_category: RateRow[] }> {
    return this.reports.attendance(user);
  }

  @Get('educators')
  async educators(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: EducatorActivityRow[] }> {
    return { data: await this.reports.educators(user) };
  }

  @Get('engagement')
  engagement(@CurrentUser() user: AuthenticatedUser): Promise<EngagementView> {
    return this.reports.engagement(user);
  }

  @Post('exports')
  @HttpCode(HttpStatus.CREATED)
  export(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreateExportDto,
  ): Promise<ExportView> {
    return this.reports.export(user, body);
  }
}
