import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { MediaModule } from '../media/media.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { EducatorTodayService } from './educator-today.service';
import { HomeworkService } from './homework.service';
import { PresenceScheduler } from './presence-scheduler';
import { SessionsController } from './sessions.controller';
import { SessionsService } from './sessions.service';

/**
 * Sessions generated from the weekly schedule, their content and homework,
 * and the educator's Today (EDU-M-01, EDU-M-04, EDU-M-05).
 */
@Module({
  imports: [IdentityModule, NotificationsModule, MediaModule],
  controllers: [SessionsController],
  providers: [SessionsService, HomeworkService, EducatorTodayService, PresenceScheduler],
  exports: [SessionsService],
})
export class SessionsModule {}
