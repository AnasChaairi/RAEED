import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';

interface AnnouncementView {
  id: string;
  title: string;
  body: string | null;
  priority: 'normal' | 'urgent';
  pinned: boolean;
  publish_at: string;
}

/**
 * Announcements visible to the caller.
 *
 * Audience targeting (`audience_json` — branch/category/group) is evaluated
 * here as association-wide only for now; per-group targeting lands with the
 * announcements epic. Read-only: the composer is Epic E.
 */
@Controller('announcements')
@UseGuards(JwtAuthGuard)
export class AnnouncementsController {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  @Get()
  async list(
    @CurrentUser() _user: AuthenticatedUser,
    @Query('cursor') _cursor?: string,
  ): Promise<{
    data: AnnouncementView[];
    page: { cursor: string | null; has_more: boolean };
  }> {
    const rows: AnnouncementView[] = await this.dataSource.query(
      `select id, title, body, priority, pinned,
              to_char(publish_at at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as publish_at
         from announcement
        where deleted_at is null
          and publish_at <= now()
          and (expire_at is null or expire_at > now())
        order by pinned desc, publish_at desc
        limit 20`,
    );
    return { data: rows, page: { cursor: null, has_more: false } };
  }
}
