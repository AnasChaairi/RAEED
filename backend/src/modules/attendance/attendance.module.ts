import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { AttendanceController } from './attendance.controller';
import { AttendanceService } from './attendance.service';
import { PresenceService } from './presence.service';

/**
 * `attendance` — presence_confirmation, presence_answer, attendance_record,
 * and the critical-alert trigger (`specs/07-backend-spec.md`).
 *
 * The safety-critical module. It owns the conflict rule and the decision of
 * what counts as an unexplained absence; the notifications module owns what
 * happens to the job once it is on the queue.
 */
@Module({
  imports: [IdentityModule],
  controllers: [AttendanceController],
  providers: [AttendanceService, PresenceService],
  exports: [AttendanceService, PresenceService],
})
export class AttendanceModule {}
