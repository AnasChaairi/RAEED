import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { StructureController } from './structure.controller';
import { StructureService } from './structure.service';

@Module({
  imports: [IdentityModule],
  controllers: [StructureController],
  providers: [StructureService],
})
export class StructureModule {}
