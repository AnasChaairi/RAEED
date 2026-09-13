import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError } from '../../common/http/api-error';
import { ImageRightsEntryDto } from './dto/consent.dto';
import { ImageRightsLevel } from './entities/consent-record.entity';

export interface ConsentRequirementView {
  privacy_policy_accepted: boolean;
  children: Array<{
    id: string;
    full_name: string;
    current_level: ImageRightsLevel | null;
  }>;
}

/**
 * Consent capture (`ACC-06`), the gate between signing in and seeing any
 * child's data.
 *
 * Every write appends. `consent_record` is never updated in place, because
 * `AUD-02` and the Memories Wall's re-check-on-downgrade both need the full
 * history — including the moment a guardian narrowed what may be published.
 */
@Injectable()
export class ConsentService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  /**
   * What is still outstanding for this caller.
   *
   * Resolved server-side on every call, never cached: two guardians of one
   * child can disagree, and a client that remembered "already consented"
   * would walk straight past a later downgrade.
   */
  async requirement(user: AuthenticatedUser): Promise<ConsentRequirementView> {
    const [privacy]: Array<{ accepted: boolean }> = await this.dataSource.query(
      `select exists(
         select 1 from consent_record
          where guardian_id = $1 and type = 'privacy_policy'
       ) as accepted`,
      [user.id],
    );

    // Only children this guardian actually guards. An educator who is not also
    // a parent has none, and still accepts the privacy policy.
    const children: Array<{
      id: string;
      full_name: string;
      current_level: ImageRightsLevel | null;
    }> = await this.dataSource.query(
      `select c.id, c.full_name,
              (select cr.level
                 from consent_record cr
                where cr.child_id = c.id
                  and cr.guardian_id = $1
                  and cr.type = 'image_rights'
                order by cr.effective_at desc
                limit 1) as current_level
         from parent_child pc
         join child c on c.id = pc.child_id
        where pc.guardian_user_id = $1
          and pc.unlinked_at is null
          and c.deleted_at is null
        order by c.full_name`,
      [user.id],
    );

    return {
      privacy_policy_accepted: privacy?.accepted ?? false,
      children,
    };
  }

  /**
   * Records the privacy-policy acceptance and a level per child.
   *
   * Children the caller does not guard are rejected outright rather than
   * ignored: silently dropping one would let a client believe it had set a
   * level that was never recorded, and on the Memories Wall that gap decides
   * whether a photo may be published.
   */
  async submit(
    user: AuthenticatedUser,
    privacyPolicyAccepted: boolean,
    imageRights: ImageRightsEntryDto[],
  ): Promise<void> {
    if (!privacyPolicyAccepted) {
      throw ApiError.validationFailed({
        privacy_policy_accepted: ['must be accepted'],
      });
    }

    const unguarded = imageRights
      .map((entry) => entry.child_id)
      .filter((childId) => !user.guards(childId));
    if (unguarded.length > 0) {
      throw ApiError.scopeForbidden(
        'Consent can only be recorded for your own children.',
      );
    }

    await this.dataSource.transaction(async (tx) => {
      await tx.query(
        `insert into consent_record (guardian_id, type, version)
         values ($1, 'privacy_policy',
                 coalesce((select max(version) + 1 from consent_record
                            where guardian_id = $1 and type = 'privacy_policy'), 1))`,
        [user.id],
      );

      for (const { child_id: childId, level } of imageRights) {
        await tx.query(
          `insert into consent_record (guardian_id, child_id, type, level, version)
           values ($1, $2, 'image_rights', $3,
                   coalesce((select max(version) + 1 from consent_record
                              where guardian_id = $1 and child_id = $2
                                and type = 'image_rights'), 1))`,
          [user.id, childId, level],
        );
      }
    });
  }
}
