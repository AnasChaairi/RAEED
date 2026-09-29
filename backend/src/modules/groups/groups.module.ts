import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { SessionsModule } from '../sessions/sessions.module';
import { GroupsController } from './groups.controller';
import { GroupsService } from './groups.service';

@Module({
  imports: [IdentityModule, SessionsModule],
  controllers: [GroupsController],
  providers: [GroupsService],
  exports: [GroupsService],
})
export class GroupsModule {}
