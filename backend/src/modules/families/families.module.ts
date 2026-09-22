import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { FamiliesController } from './families.controller';
import { FamiliesService } from './families.service';

@Module({
  imports: [IdentityModule],
  controllers: [FamiliesController],
  providers: [FamiliesService],
})
export class FamiliesModule {}
