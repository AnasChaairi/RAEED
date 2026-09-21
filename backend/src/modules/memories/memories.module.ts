import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { MemoriesController } from './memories.controller';
import { MemoriesService } from './memories.service';

@Module({
  imports: [IdentityModule],
  controllers: [MemoriesController],
  providers: [MemoriesService],
})
export class MemoriesModule {}
