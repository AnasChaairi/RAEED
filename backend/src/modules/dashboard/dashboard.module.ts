import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';

/**
 * Read-only, and built on the same tables and scope rules as every
 * operational module — no direct-to-database reporting path
 * (`specs/07-backend-spec.md`).
 */
@Module({
  imports: [IdentityModule],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
