import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ORG_TIMEZONE } from '../../common/i18n/user-locale';
import {
  PresenceTallies,
  SessionDetailView,
  SessionListItem,
  SessionsService,
} from './sessions.service';

export interface TodayView {
  date: string;
  next_session:
    | (SessionListItem & {
        enrolled_count: number;
        presence: (PresenceTallies & { sent: boolean }) | null;
        attendance: SessionDetailView['attendance'];
      })
    | null;
  today_sessions: SessionListItem[];
  sessions_without_content: SessionListItem[];
  pinned_announcement: {
    id: string;
    title: string;
    body: string | null;
    ack_required: boolean;
    confirmed: boolean;
  } | null;
}

/**
 * The educator's Today (EDU-M-01): the next session with what the guardians
 * answered, today's list, the generated sessions still waiting for content,
 * and the pinned announcement from management.
 */
@Injectable()
export class EducatorTodayService {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly sessions: SessionsService,
  ) {}

  async today(user: AuthenticatedUser): Promise<TodayView> {
    const groupIds = await this.sessions.scopedGroupIds(user);
    const now = new Date();
    const weekAhead = new Date(now.getTime() + 7 * 24 * 3600 * 1000);
    await this.sessions.ensureGenerated(this.dataSource, groupIds, now, weekAhead);

    const [dayStart, dayEnd] = await this.localDayBounds();
    const todayRows =
      groupIds.length === 0
        ? []
        : await this.sessions.rows(
            's.group_id = any($1::uuid[]) and s.starts_at >= $2 and s.starts_at < $3',
            [groupIds, dayStart, dayEnd],
            'order by s.starts_at, s.id',
          );
    const nextRows =
      groupIds.length === 0
        ? []
        : await this.sessions.rows(
            "s.group_id = any($1::uuid[]) and s.ends_at > now() and s.status <> 'cancelled'",
            [groupIds],
            'order by s.starts_at, s.id limit 1',
          );
    const emptyRows =
      groupIds.length === 0
        ? []
        : await this.sessions.rows(
            `s.group_id = any($1::uuid[]) and s.starts_at >= now() and s.starts_at < $2
             and s.status = 'planned' and not s.is_customized and s.title is null`,
            [groupIds, weekAhead],
            'order by s.starts_at, s.id limit 5',
          );

    const next = nextRows[0];
    const nextSession = next
      ? {
          ...this.sessions.toItem(next),
          enrolled_count: (await this.sessions.audienceCounts(next.group_id)).enrolled,
          presence: await this.sessions.presenceTallies(next.id, next.group_id),
          attendance: await this.sessions.attendanceCounts(next.id),
        }
      : null;

    return {
      date: now.toISOString(),
      next_session: nextSession,
      today_sessions: todayRows.map((row) => this.sessions.toItem(row)),
      sessions_without_content: emptyRows.map((row) => this.sessions.toItem(row)),
      pinned_announcement: await this.pinnedAnnouncement(user, groupIds),
    };
  }

  private async pinnedAnnouncement(
    user: AuthenticatedUser,
    groupIds: string[],
  ): Promise<TodayView['pinned_announcement']> {
    const rows: Array<{ id: string; title: string; body: string | null; ack_required: boolean; confirmed: boolean }> =
      await this.dataSource.query(
        `select a.id, a.title, a.body, a.ack_required,
                exists (select 1 from announcement_read r
                         where r.announcement_id = a.id and r.user_id = $1 and r.confirmed_at is not null)
                  as confirmed
           from announcement a
          where a.deleted_at is null and a.pinned
            and a.publish_at <= now() and (a.expire_at is null or a.expire_at > now())
            and (a.audience_json->>'type' in ('all', 'educators')
                 or a.audience_json ? 'all'
                 or exists (select 1 from jsonb_array_elements_text(coalesce(a.audience_json->'group_ids', '[]'::jsonb)) gid
                             where gid = any($2::text[])))
          order by a.publish_at desc
          limit 1`,
        [user.id, groupIds],
      );
    return rows[0] ?? null;
  }

  /** Today's [start, end) in the organisation's zone, as instants. */
  private async localDayBounds(): Promise<[Date, Date]> {
    const rows: Array<{ day_start: Date; day_end: Date }> = await this.dataSource.query(
      `select (date_trunc('day', now() at time zone $1) at time zone $1) as day_start,
              ((date_trunc('day', now() at time zone $1) + interval '1 day') at time zone $1) as day_end`,
      [ORG_TIMEZONE],
    );
    return [rows[0].day_start, rows[0].day_end];
  }
}
