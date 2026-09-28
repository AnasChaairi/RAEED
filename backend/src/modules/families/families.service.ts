import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';
import { IdentityService } from '../identity/identity.service';
import { PasswordService } from '../identity/password.service';
import { CreateFamilyDto } from './dto/family.dto';

export type AccountStatus = 'active' | 'pending';

export interface FamilyView {
  /** Stable across requests: the sorted guardian ids, joined. */
  id: string;
  label: string;
  guardians: Array<{ id: string; display_name: string; account: AccountStatus }>;
  children: Array<{ id: string; full_name: string; group: { id: string; name: string } | null }>;
  /** active: every guardian signed in · partial: some · pending: none yet. */
  status: 'active' | 'partial' | 'pending';
}

/** One guardian's first password, returned once to the executive who created the account. */
export interface GuardianCredentialView {
  id: string;
  display_name: string;
  /** Null when the phone already had an account: its password is unchanged. */
  password: string | null;
}

export interface FamilyCreatedView {
  guardian_ids: string[];
  child_ids: string[];
  invitations: number;
  guardians: GuardianCredentialView[];
}

export interface EducatorView {
  id: string;
  display_name: string;
  group_count: number;
}

interface LinkRow {
  child_id: string;
  full_name: string;
  group_id: string | null;
  group_name: string | null;
  guardian_id: string;
  display_name: string;
  account: AccountStatus;
}

/**
 * Households, derived rather than stored.
 *
 * The schema has no family entity on purpose: what it records is which
 * guardians are linked to which children (`parent_child`), and a household
 * is the set of children who share exactly the same current guardians. That
 * keeps a guardian who moves between households, or a child with a
 * guardian outside the household, representable without a second table
 * that would drift from the links.
 */
@Injectable()
export class FamiliesService {

  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
    private readonly identity: IdentityService,
    private readonly passwords: PasswordService,
  ) {}

  async list(user: AuthenticatedUser): Promise<FamilyView[]> {
    this.assertOversight(user);
    const params: unknown[] = [];
    const scope = user.branchId
      ? (params.push(user.branchId), `and (g.id is null or g.branch_id = $${params.length})`)
      : '';

    const rows: LinkRow[] = await this.dataSource.query(
      `select c.id as child_id, c.full_name, g.id as group_id, g.name as group_name,
              u.id as guardian_id, coalesce(u.display_name, '') as display_name,
              case when exists (select 1 from user_device d
                                 where d.user_id = u.id and d.revoked_at is null
                                   and d.last_seen_at is not null)
                   then 'active' else 'pending' end as account
         from child c
         join parent_child pc on pc.child_id = c.id and pc.unlinked_at is null
         join app_user u on u.id = pc.guardian_user_id
         left join child_group cg on cg.child_id = c.id and cg.valid_to is null and cg.is_main
         left join "group" g on g.id = cg.group_id
        where c.deleted_at is null ${scope}
        order by c.full_name, u.id`,
      params,
    );

    const byChild = new Map<string, LinkRow[]>();
    for (const row of rows) {
      byChild.set(row.child_id, [...(byChild.get(row.child_id) ?? []), row]);
    }

    const families = new Map<string, FamilyView>();
    for (const links of byChild.values()) {
      const guardians = [...links]
        .sort((a, b) => a.guardian_id.localeCompare(b.guardian_id))
        .map((link) => ({
          id: link.guardian_id,
          display_name: link.display_name,
          account: link.account,
        }));
      const id = guardians.map((guardian) => guardian.id).join(',');
      const first = links[0];
      const family =
        families.get(id) ??
        (() => {
          const created: FamilyView = {
            id,
            label: familyLabel(guardians, first.full_name),
            guardians,
            children: [],
            status: familyStatus(guardians),
          };
          families.set(id, created);
          return created;
        })();
      family.children.push({
        id: first.child_id,
        full_name: first.full_name,
        group: first.group_id && first.group_name ? { id: first.group_id, name: first.group_name } : null,
      });
    }

    return [...families.values()].sort((a, b) => a.label.localeCompare(b.label, 'ar'));
  }

  /**
   * Creates a household: guardians, children and their links, in one
   * transaction, recorded as one act.
   *
   * A guardian whose phone already has an account is linked rather than
   * duplicated — that is how a second child joins an existing family.
   * Children carry no health information here: the guardian enters that
   * from their own account, so the person the data is about is the one who
   * typed it (`CHD-04`).
   */
  async create(
    user: AuthenticatedUser,
    input: CreateFamilyDto,
  ): Promise<FamilyCreatedView> {
    this.assertOversight(user);
    for (const child of input.children) {
      if (child.group_id) await this.assertMayAssign(user, child.group_id);
    }

    return this.dataSource.transaction(async (tx) => {
      const guardianIds: string[] = [];
      const credentials: GuardianCredentialView[] = [];
      let invitations = 0;
      for (const guardian of input.guardians) {
        const existing: Array<{ id: string }> = await tx.query(
          'select id from app_user where phone = $1',
          [guardian.phone],
        );
        let id = existing[0]?.id;
        if (!id) {
          const rows: Array<{ id: string }> = await tx.query(
            `insert into app_user (phone, display_name, preferred_locale)
             values ($1, $2, 'ar') returning id`,
            [guardian.phone, guardian.display_name.trim()],
          );
          id = rows[0].id;
          invitations += 1;
          // A new account is handed its first password by the executive who
          // created it (ACC-02). It is returned once, here, and never stored
          // in clear.
          const password = this.passwords.generate();
          await this.identity.setPassword(tx, id, password);
          credentials.push({ id, display_name: guardian.display_name.trim(), password });
        } else {
          credentials.push({ id, display_name: guardian.display_name.trim(), password: null });
          await tx.query(
            `update app_user set display_name = coalesce(display_name, $2) where id = $1`,
            [id, guardian.display_name.trim()],
          );
        }
        await tx.query(
          `insert into role_assignment (user_id, role)
           select $1, 'parent'
            where not exists (select 1 from role_assignment where user_id = $1 and role = 'parent')`,
          [id],
        );
        guardianIds.push(id);
      }

      const childIds: string[] = [];
      for (const child of input.children) {
        const rows: Array<{ id: string }> = await tx.query(
          `insert into child (full_name, dob) values ($1, $2) returning id`,
          [child.full_name.trim(), child.dob],
        );
        const childId = rows[0].id;
        childIds.push(childId);
        for (let index = 0; index < guardianIds.length; index += 1) {
          await tx.query(
            `insert into parent_child (guardian_user_id, child_id, relationship_type)
             values ($1, $2, $3)`,
            [guardianIds[index], childId, input.guardians[index].relationship.trim()],
          );
        }
        if (child.group_id) {
          await tx.query(
            `insert into child_group (child_id, group_id, is_main) values ($1, $2, true)`,
            [childId, child.group_id],
          );
        }
        // Every child gets a thread the moment they exist, so a guardian's
        // first message has somewhere to go.
        await tx.query(
          `insert into conversation (type, ref_child_id) values ('child', $1)`,
          [childId],
        );
      }

      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
         values ($1, 'family.create', 'child', $2, $3::jsonb)`,
        [
          user.id,
          childIds[0],
          JSON.stringify({ guardian_ids: guardianIds, child_ids: childIds, invitations }),
        ],
      );

      return { guardian_ids: guardianIds, child_ids: childIds, invitations, guardians: credentials };
    });
  }

  /**
   * Issues a guardian a fresh password — the "invitation" when there is no
   * SMS: the executive hands it over in person. Recorded, and the old
   * password stops working at once.
   */
  async resendInvitation(
    user: AuthenticatedUser,
    guardianId: string,
  ): Promise<{ user_id: string; password: string }> {
    this.assertOversight(user);
    const rows: Array<{ id: string }> = await this.dataSource.query(
      `select u.id from app_user u
         join role_assignment ra on ra.user_id = u.id and ra.role = 'parent'
        where u.id = $1 and u.is_active`,
      [guardianId],
    );
    if (rows.length === 0) throw ApiError.scopeForbidden('No such guardian.');
    const password = this.passwords.generate();
    await this.dataSource.transaction(async (tx) => {
      await this.identity.setPassword(tx, guardianId, password);
      await tx.query(
        `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id)
         values ($1, 'invitation.resend', 'app_user', $2)`,
        [user.id, guardianId],
      );
    });
    return { user_id: guardianId, password };
  }

  /** Educators, for the new-group form. */
  async educators(user: AuthenticatedUser): Promise<EducatorView[]> {
    this.assertOversight(user);
    return this.dataSource.query(
      `select u.id, coalesce(u.display_name, '') as display_name,
              (select count(*) from group_educator ge
                 join "group" g on g.id = ge.group_id and g.deleted_at is null
                where ge.educator_user_id = u.id and ge.unassigned_at is null)::int as group_count
         from app_user u
         join role_assignment ra on ra.user_id = u.id and ra.role = 'educator'
        where u.is_active
        order by u.display_name nulls last, u.id`,
    );
  }

  private assertOversight(user: AuthenticatedUser): void {
    if (!user.hasOversight) throw ApiError.scopeForbidden();
  }

  private async assertMayAssign(user: AuthenticatedUser, groupId: string): Promise<void> {
    const rows: Array<{ id: string; branch_id: string }> = await this.dataSource.query(
      'select id, branch_id from "group" where id = $1 and deleted_at is null',
      [groupId],
    );
    const group = rows[0];
    if (!group) throw ApiError.scopeForbidden('No such group, or not yours.');
    const ability = defineAbilityFor(user);
    if (!ability.can('update', subject('Group', { id: group.id, branchId: group.branch_id }))) {
      throw ApiError.scopeForbidden();
    }
  }
}

/** "الأسرة الإدريسي" from the children's shared family name, else the guardians'. */
function familyLabel(
  guardians: Array<{ display_name: string }>,
  childName: string,
): string {
  const surname = childName.trim().split(/\s+/).slice(1).join(' ');
  if (surname) return surname;
  return guardians.map((guardian) => guardian.display_name).filter(Boolean).join(' · ');
}

function familyStatus(guardians: Array<{ account: AccountStatus }>): FamilyView['status'] {
  const active = guardians.filter((guardian) => guardian.account === 'active').length;
  if (active === guardians.length) return 'active';
  return active > 0 ? 'partial' : 'pending';
}
