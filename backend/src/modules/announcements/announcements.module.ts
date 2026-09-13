import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { AnnouncementsController } from './announcements.controller';

@Module({
  imports: [IdentityModule],
  controllers: [AnnouncementsController],
})
export class AnnouncementsModule {}
