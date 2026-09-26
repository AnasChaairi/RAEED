import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { buildDataSourceOptions } from './database/data-source';
import { QueueModule } from './common/queue/queues';
import { RedisModule } from './common/redis/redis.module';
import { HealthController } from './modules/health/health.controller';
import { AnnouncementsModule } from './modules/announcements/announcements.module';
import { AttendanceModule } from './modules/attendance/attendance.module';
import { AuditModule } from './modules/audit/audit.module';
import { ChildrenModule } from './modules/children/children.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { FamiliesModule } from './modules/families/families.module';
import { GroupsModule } from './modules/groups/groups.module';
import { IdentityModule } from './modules/identity/identity.module';
import { MediaModule } from './modules/media/media.module';
import { MemoriesModule } from './modules/memories/memories.module';
import { MessagingModule } from './modules/messaging/messaging.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { ReportsModule } from './modules/reports/reports.module';
import { SessionsModule } from './modules/sessions/sessions.module';
import { StructureModule } from './modules/structure/structure.module';

/**
 * The modular monolith's root (`specs/02-architecture.md`).
 *
 * One deployable, one database, no microservices — module boundaries are
 * enforced by review and lint rules rather than by network hops. Each feature
 * module below is importable by another only through its exported service,
 * never through a shared repository.
 */
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot(buildDataSourceOptions()),
    RedisModule,
    QueueModule,
    IdentityModule,
    ChildrenModule,
    AnnouncementsModule,
    AttendanceModule,
    NotificationsModule,
    GroupsModule,
    DashboardModule,
    MessagingModule,
    MemoriesModule,
    FamiliesModule,
    ReportsModule,
    StructureModule,
    AuditModule,
    MediaModule,
    SessionsModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
