import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError } from '../../common/http/api-error';
import { CreateBranchDto } from './dto/structure.dto';

export interface SeasonView {
  id: string;
  label: string;
  start_date: string;
  end_date: string;
  status: 'active' | 'archived';
  group_count: number;
  child_count: number;
}

export interface CategoryView {
  id: string;
  name: string;
  /** Null until the board decides (open decision #1). */
  min_age: number | null;
  max_age: number | null;
  gender: 'boys' | 'girls' | 'mixed' | null;
  child_count: number;
  group_count: number;
}

export interface BranchView {
  id: string;
  name: string;
  address: string | null;
  executive_names: string[];
}

/**
 * Seasons, categories and branches (EXEC-M-12) — the admin's structure.
 *
 * Seasons archive and never delete: a closed season's groups and marks stay
 * readable. Categories carry their age range and gender as stored, which is
 * null until the board decides (open decision #1) — the app renders "not
 * set", never a plausible-looking value.
 */
@Injectable()
export class StructureService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  seasons(): Promise<SeasonView[]> {
    return this.dataSource.query(
      `select se.id, se.label,
              to_char(se.start_date, 'YYYY-MM-DD') as start_date,
              to_char(se.end_date, 'YYYY-MM-DD') as end_date,
              se.status,
              (select count(*) from "group" g where g.season_id = se.id and g.deleted_at is null)::int
                as group_count,
              (select count(distinct cg.child_id)
                 from child_group cg
                 join "group" g on g.id = cg.group_id and g.season_id = se.id
                 join child c on c.id = cg.child_id and c.deleted_at is null)::int as child_count
         from season se
        order by se.start_date desc`,
    );
  }

  async archiveSeason(user: AuthenticatedUser, seasonId: string): Promise<void> {
    const rows: Array<{ id: string; status: string }> = await this.dataSource.query(
      'select id, status from season where id = $1',
      [seasonId],
    );
    if (rows.length === 0) throw ApiError.scopeForbidden('No such season.');
    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update season set status = 'archived', updated_at = now() where id = $1`,
        [seasonId],
      );
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'season.archive', 'season', $2, $3::jsonb)`,
        [user.id, seasonId, JSON.stringify({ from: rows[0].status })],
      );
    });
  }

  categories(): Promise<CategoryView[]> {
    return this.dataSource.query(
      `select cat.id, cat.name_ar as name, cat.min_age, cat.max_age, cat.gender,
              (select count(distinct cg.child_id)
                 from "group" g
                 join season se on se.id = g.season_id and se.status = 'active'
                 join child_group cg on cg.group_id = g.id and cg.valid_to is null
                 join child c on c.id = cg.child_id and c.deleted_at is null
                where g.category_id = cat.id and g.deleted_at is null)::int as child_count,
              (select count(*) from "group" g
                 join season se on se.id = g.season_id and se.status = 'active'
                where g.category_id = cat.id and g.deleted_at is null)::int as group_count
         from category cat
        where cat.deleted_at is null
        order by cat.created_at`,
    );
  }

  branches(): Promise<BranchView[]> {
    return this.dataSource.query(
      `select b.id, b.name, b.address,
              coalesce((select array_agg(coalesce(u.display_name, '') order by u.display_name)
                          from role_assignment ra
                          join app_user u on u.id = ra.user_id
                         where ra.role in ('executive', 'admin')
                           and (ra.branch_id = b.id or ra.branch_id is null)), '{}'::text[])
                as executive_names
         from branch b
        where b.deleted_at is null
        order by b.created_at`,
    );
  }

  async createBranch(user: AuthenticatedUser, input: CreateBranchDto): Promise<BranchView> {
    const id = await this.dataSource.transaction(async (tx) => {
      const rows: Array<{ id: string }> = await tx.query(
        'insert into branch (name, address) values ($1, $2) returning id',
        [input.name.trim(), input.address?.trim() || null],
      );
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id)
         values ($1, 'branch.create', 'branch', $2)`,
        [user.id, rows[0].id],
      );
      return rows[0].id;
    });
    const branches = await this.branches();
    return branches.find((branch) => branch.id === id)!;
  }
}
