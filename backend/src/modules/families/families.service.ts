import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource, EntityManager } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { defineAbilityFor, subject } from '../../common/abilities/define-ability';
import { ApiError } from '../../common/http/api-error';
import { IdentityService } from '../identity/identity.service';
import { PasswordService } from '../identity/password.service';
import {
  CreateFamilyDto,
  NewChildDto,
  NewGuardianDto,
  UpdateChildDto,
  UpdateGuardianDto,
} from './dto/family.dto';

export type AccountStatus = 'active' | 'pending';

export interface FamilyGuardianView {
  id: string;
  display_name: string;
  /** To this household's children — one value per guardian, per family. */
  relationship: string;
  /** The last two digits, masked; the number itself is a recorded reveal. */
  phone_hint: string | null;
  account: AccountStatus;
}

export interface FamilyChildView {
  id: string;
  full_name: string;
  dob: string | null;
  group: { id: string; name: string } | null;
}

export interface FamilyView {
  /** Stable across requests: the sorted guardian ids, joined. */
  id: string;
  label: string;
  guardians: FamilyGuardianView[];
  children: FamilyChildView[];
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

/** `POST /families/{id}/guardians` — the household as it now is, and who to hand what. */
export interface GuardianLinkedView {
  family: FamilyView;
  credential: GuardianCredentialView;
}

/** `POST /families/{id}/children`. */
export interface ChildAddedView {
  family: FamilyView;
  child_id: string;
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
  dob: string | null;
  group_id: string | null;
  group_name: string | null;
  guardian_id: string;
  display_name: string;
  relationship: string;
  phone_hint: string | null;
  account: AccountStatus;
}

/** A guardian as the upsert leaves them: linked account, and a first password if it is new. */
interface UpsertedGuardian {
  id: string;
  display_name: string;
  password: string | null;
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
      `select c.id as child_id, c.full_name, to_char(c.dob, 'YYYY-MM-DD') as dob,
              g.id as group_id, g.name as group_name,
              u.id as guardian_id, coalesce(u.display_name, '') as display_name,
              pc.relationship_type as relationship,
              case when u.phone is null then null else '•• ' || right(u.phone, 2) end as phone_hint,
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
          relationship: link.relationship,
          phone_hint: link.phone_hint,
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
        dob: first.dob,
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
      const credentials: GuardianCredentialView[] = [];
      for (const guardian of input.guardians) {
        const upserted = await this.upsertGuardian(tx, guardian);
        credentials.push({
          id: upserted.id,
          display_name: upserted.display_name,
          password: upserted.password,
        });
      }
      const guardianIds = credentials.map((credential) => credential.id);
      const invitations = credentials.filter((credential) => credential.password !== null).length;
      const links = guardianIds.map((id, index) => ({
        id,
        relationship: input.guardians[index].relationship.trim(),
      }));

      const childIds: string[] = [];
      for (const child of input.children) {
        childIds.push(await this.insertChild(tx, child, links));
      }

      await this.audit(tx, user, 'family.create', 'child', childIds[0], {
        guardian_ids: guardianIds,
        child_ids: childIds,
        invitations,
      });

      return { guardian_ids: guardianIds, child_ids: childIds, invitations, guardians: credentials };
    });
  }

  /** One household, as `GET /families` would list it. */
  async get(user: AuthenticatedUser, guardianIds: string[]): Promise<FamilyView> {
    this.assertOversight(user);
    return this.loadFamily(user, guardianIds);
  }

  /**
   * Edits a guardian: name, phone, relationship to this household's
   * children. Only what is sent changes.
   *
   * The phone is the sign-in identifier, so changing it signs the guardian
   * out on every device at once (`ACC-07` in spirit: a session opened under
   * the old number must not outlive it); the password is kept, and they sign
   * in again on the new number. The record names which fields changed and
   * never the number itself — raw phones stay out of every log
   * (`specs/10-security-and-privacy.md`).
   */
  async updateGuardian(
    user: AuthenticatedUser,
    guardianIds: string[],
    guardianId: string,
    input: UpdateGuardianDto,
  ): Promise<FamilyView> {
    this.assertOversight(user);
    const family = await this.loadFamily(user, guardianIds);
    if (!family.guardians.some((guardian) => guardian.id === guardianId)) {
      throw ApiError.scopeForbidden('No such guardian in this family.');
    }
    const childIds = family.children.map((child) => child.id);

    await this.dataSource.transaction(async (tx) => {
      const changed: string[] = [];
      let devicesRevoked = 0;
      if (input.display_name !== undefined) {
        await tx.query(
          `update app_user set display_name = $2, updated_at = now() where id = $1`,
          [guardianId, input.display_name.trim()],
        );
        changed.push('display_name');
      }
      if (input.phone !== undefined) {
        const taken: Array<{ id: string }> = await tx.query(
          'select id from app_user where phone = $1 and id <> $2',
          [input.phone, guardianId],
        );
        if (taken.length > 0) throw ApiError.guardianPhoneTaken();
        const current: Array<{ phone: string | null }> = await tx.query(
          'select phone from app_user where id = $1',
          [guardianId],
        );
        if (current[0]?.phone !== input.phone) {
          await tx.query(
            `update app_user set phone = $2, updated_at = now() where id = $1`,
            [guardianId, input.phone],
          );
          devicesRevoked = await this.identity.revokeAllDevices(tx, guardianId);
          changed.push('phone');
        }
      }
      if (input.relationship !== undefined) {
        // An attribute of the link, not a link event: the guardian did not
        // leave and come back, so the row is corrected in place.
        await tx.query(
          `update parent_child set relationship_type = $3
            where guardian_user_id = $1 and child_id = any($2::uuid[]) and unlinked_at is null`,
          [guardianId, childIds, input.relationship.trim()],
        );
        changed.push('relationship');
      }
      if (changed.length > 0) {
        await this.audit(tx, user, 'guardian.update', 'app_user', guardianId, {
          changed,
          child_ids: childIds,
          devices_revoked: devicesRevoked,
        });
      }
    });

    return this.loadFamily(user, guardianIds);
  }

  /**
   * Links a guardian to every child of the household (`ACC-05`). A phone that
   * already has an account is linked, not duplicated, and keeps its password;
   * a new account gets a first password, returned once. The household's id
   * changes — it is the guardian set — so the response carries the family as
   * it now is.
   */
  async addGuardian(
    user: AuthenticatedUser,
    guardianIds: string[],
    input: NewGuardianDto,
  ): Promise<GuardianLinkedView> {
    this.assertOversight(user);
    const family = await this.loadFamily(user, guardianIds);
    const childIds = family.children.map((child) => child.id);

    const linked = await this.dataSource.transaction(async (tx) => {
      const upserted = await this.upsertGuardian(tx, input);
      // A guardian of one child here is a guardian of all of them — that is
      // what makes it one household — so this check is exact.
      if (family.guardians.some((guardian) => guardian.id === upserted.id)) {
        throw ApiError.guardianAlreadyLinked();
      }
      await tx.query(
        `insert into parent_child (guardian_user_id, child_id, relationship_type)
         select $1, child_id, $3 from unnest($2::uuid[]) as child_id`,
        [upserted.id, childIds, input.relationship.trim()],
      );
      await this.audit(tx, user, 'guardian.link', 'app_user', upserted.id, {
        child_ids: childIds,
        invitation: upserted.password !== null,
      });
      return upserted;
    });

    const nextIds = [...guardianIds, linked.id].sort((a, b) => a.localeCompare(b));
    return {
      family: await this.loadFamily(user, nextIds),
      credential: { id: linked.id, display_name: linked.display_name, password: linked.password },
    };
  }

  /**
   * Unlinks a guardian from every child of the household (`ACC-05`). The link
   * rows are closed, never deleted, and the account stays — deactivating a
   * person is a separate act. Refused when any child would be left with no
   * guardian at all; the check runs inside the transaction because the
   * household may have changed since the executive last looked at it.
   */
  async unlinkGuardian(
    user: AuthenticatedUser,
    guardianIds: string[],
    guardianId: string,
  ): Promise<FamilyView> {
    this.assertOversight(user);
    const family = await this.loadFamily(user, guardianIds);
    if (!family.guardians.some((guardian) => guardian.id === guardianId)) {
      throw ApiError.scopeForbidden('No such guardian in this family.');
    }
    const childIds = family.children.map((child) => child.id);

    await this.dataSource.transaction(async (tx) => {
      const orphans: Array<{ child_id: string }> = await tx.query(
        `select pc.child_id from parent_child pc
          where pc.child_id = any($1::uuid[]) and pc.unlinked_at is null
          group by pc.child_id
         having count(*) filter (where pc.guardian_user_id <> $2) = 0`,
        [childIds, guardianId],
      );
      if (orphans.length > 0) {
        throw ApiError.childrenLastGuardian(orphans.map((row) => row.child_id));
      }
      await tx.query(
        `update parent_child set unlinked_at = now()
          where guardian_user_id = $2 and child_id = any($1::uuid[]) and unlinked_at is null`,
        [childIds, guardianId],
      );
      await this.audit(tx, user, 'guardian.unlink', 'app_user', guardianId, { child_ids: childIds });
    });

    return this.loadFamily(
      user,
      guardianIds.filter((id) => id !== guardianId),
    );
  }

  /** Adds a child to the household, linked to every current guardian. */
  async addChild(
    user: AuthenticatedUser,
    guardianIds: string[],
    input: NewChildDto,
  ): Promise<ChildAddedView> {
    this.assertOversight(user);
    const family = await this.loadFamily(user, guardianIds);
    if (input.group_id) await this.assertMayAssign(user, input.group_id);

    const childId = await this.dataSource.transaction(async (tx) => {
      const id = await this.insertChild(
        tx,
        input,
        family.guardians.map((guardian) => ({ id: guardian.id, relationship: guardian.relationship })),
      );
      await this.audit(tx, user, 'child.create', 'child', id, {
        guardian_ids: guardianIds,
        group_id: input.group_id ?? null,
      });
      return id;
    });

    return { family: await this.loadFamily(user, guardianIds), child_id: childId };
  }

  /** Corrects a child's name or date of birth. Every write to `child` is recorded. */
  async updateChild(
    user: AuthenticatedUser,
    guardianIds: string[],
    childId: string,
    input: UpdateChildDto,
  ): Promise<FamilyView> {
    this.assertOversight(user);
    const family = await this.loadFamily(user, guardianIds);
    if (!family.children.some((child) => child.id === childId)) {
      throw ApiError.scopeForbidden('No such child in this family.');
    }
    const changed = [
      ...(input.full_name !== undefined ? ['full_name'] : []),
      ...(input.dob !== undefined ? ['dob'] : []),
    ];
    if (changed.length === 0) return family;

    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `update child
            set full_name = coalesce($2, full_name), dob = coalesce($3, dob), updated_at = now()
          where id = $1 and deleted_at is null`,
        [childId, input.full_name?.trim() ?? null, input.dob ?? null],
      );
      await this.audit(tx, user, 'child.update', 'child', childId, { changed });
    });

    return this.loadFamily(user, guardianIds);
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

  /**
   * The household with exactly these guardians, or nothing the caller may
   * see. Reuses the list derivation so a mutation returns precisely what the
   * Families tab would show — the same scope, the same shape.
   */
  private async loadFamily(user: AuthenticatedUser, guardianIds: string[]): Promise<FamilyView> {
    const id = [...guardianIds].sort((a, b) => a.localeCompare(b)).join(',');
    const family = (await this.list(user)).find((candidate) => candidate.id === id);
    if (!family) throw ApiError.scopeForbidden('No such family, or not yours.');
    return family;
  }

  /**
   * Links a phone to an account: reuses the one it already has, else creates
   * it with a first password (returned once, never stored in clear, `ACC-02`).
   * Either way the account holds the parent role afterwards.
   */
  private async upsertGuardian(tx: EntityManager, guardian: NewGuardianDto): Promise<UpsertedGuardian> {
    const displayName = guardian.display_name.trim();
    const existing: Array<{ id: string }> = await tx.query(
      'select id from app_user where phone = $1',
      [guardian.phone],
    );
    let id = existing[0]?.id;
    let password: string | null = null;
    if (!id) {
      const rows: Array<{ id: string }> = await tx.query(
        `insert into app_user (phone, display_name, preferred_locale)
         values ($1, $2, 'ar') returning id`,
        [guardian.phone, displayName],
      );
      id = rows[0].id;
      password = this.passwords.generate();
      await this.identity.setPassword(tx, id, password);
    } else {
      await tx.query(
        `update app_user set display_name = coalesce(display_name, $2) where id = $1`,
        [id, displayName],
      );
    }
    await tx.query(
      `insert into role_assignment (user_id, role)
       select $1, 'parent'
        where not exists (select 1 from role_assignment where user_id = $1 and role = 'parent')`,
      [id],
    );
    return { id, display_name: displayName, password };
  }

  /**
   * A child row, its links to [guardians], its main group when one was
   * chosen, and its thread — every child gets one the moment they exist, so
   * a guardian's first message has somewhere to go. No health information:
   * the guardian enters that from their own account (`CHD-04`).
   */
  private async insertChild(
    tx: EntityManager,
    child: NewChildDto,
    guardians: Array<{ id: string; relationship: string }>,
  ): Promise<string> {
    const rows: Array<{ id: string }> = await tx.query(
      `insert into child (full_name, dob) values ($1, $2) returning id`,
      [child.full_name.trim(), child.dob],
    );
    const childId = rows[0].id;
    for (const guardian of guardians) {
      await tx.query(
        `insert into parent_child (guardian_user_id, child_id, relationship_type)
         values ($1, $2, $3)`,
        [guardian.id, childId, guardian.relationship],
      );
    }
    if (child.group_id) {
      await tx.query(
        `insert into child_group (child_id, group_id, is_main) values ($1, $2, true)`,
        [childId, child.group_id],
      );
    }
    await tx.query(
      `insert into conversation (type, ref_child_id) values ('child', $1)`,
      [childId],
    );
    return childId;
  }

  private async audit(
    tx: EntityManager,
    user: AuthenticatedUser,
    action: string,
    resourceType: 'child' | 'app_user',
    resourceId: string,
    meta: Record<string, unknown>,
  ): Promise<void> {
    // The action is a code constant, inlined so the statement itself names
    // what it records — grep-able in the query log the way the other modules' are.
    await tx.query(
      `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
       values ($1, '${action}', $2, $3, $4::jsonb)`,
      [user.id, resourceType, resourceId, JSON.stringify(meta)],
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
