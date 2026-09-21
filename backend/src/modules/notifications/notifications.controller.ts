import { Controller, Get, HttpCode, HttpStatus, Post, UseGuards } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';

export interface NotificationView {
  id: string;
  kind: 'critical' | 'request' | 'memories' | 'security' | 'other';
  title: string;
  body: string | null;
  destination: string | null;
  sent_at: string;
  read_at: string | null;
}

/**
 * The in-app notification centre (`specs/09-notifications-spec.md`): the
 * source of truth for what a user was told, independent of push delivery.
 * Rows are the caller's own and nobody else's — there is no oversight read
 * of another person's notifications.
 */
@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  @Get()
  async list(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: NotificationView[]; page: { cursor: null; has_more: false } }> {
    const rows: Array<
      Omit<NotificationView, 'sent_at' | 'read_at'> & {
        sent_at: Date;
        read_at: Date | null;
      }
    > = await this.dataSource.query(
      `select id, kind, title, body, destination, sent_at, read_at
         from notification
        where user_id = $1
        order by sent_at desc, id
        limit 100`,
      [user.id],
    );
    return {
      data: rows.map((row) => ({
        ...row,
        sent_at: row.sent_at.toISOString(),
        read_at: row.read_at ? row.read_at.toISOString() : null,
      })),
      page: { cursor: null, has_more: false },
    };
  }

  @Post('read-all')
  @HttpCode(HttpStatus.NO_CONTENT)
  async readAll(@CurrentUser() user: AuthenticatedUser): Promise<void> {
    await this.dataSource.query(
      'update notification set read_at = now() where user_id = $1 and read_at is null',
      [user.id],
    );
  }
}
