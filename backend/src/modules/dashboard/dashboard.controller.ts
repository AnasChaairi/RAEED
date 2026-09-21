import { Controller, Get, UseGuards } from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import {
  CheckAbility,
  CheckAbilityGuard,
} from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { DashboardOverviewView, DashboardService } from './dashboard.service';

@Controller('dashboard')
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
export class DashboardController {
  constructor(private readonly dashboard: DashboardService) {}

  /** `GET /dashboard/overview` — executives and admins only (`DSH-01`). */
  @Get('overview')
  @CheckAbility('read', 'Dashboard')
  overview(@CurrentUser() user: AuthenticatedUser): Promise<DashboardOverviewView> {
    return this.dashboard.overview(user);
  }
}
