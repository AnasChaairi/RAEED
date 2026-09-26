import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { AbsenceAlertWorker } from './absence-alert.worker';
import { NotificationsController } from './notifications.controller';
import { NotifyService } from './notify.service';
import { PushDispatcher } from './push.dispatcher';

/**
 * `notifications` — the shared queue infrastructure and its workers
 * (`specs/07-backend-spec.md`).
 *
 * The attendance module decides *whether* an absence is unexplained; this
 * module owns what happens to the job afterwards. Keeping that split means the
 * safety rule and the delivery mechanism can be tested separately, and a
 * change to FCM cannot alter when an alert fires.
 */
@Module({
  imports: [IdentityModule],
  controllers: [NotificationsController],
  providers: [PushDispatcher, AbsenceAlertWorker, NotifyService],
  exports: [PushDispatcher, NotifyService],
})
export class NotificationsModule {}
