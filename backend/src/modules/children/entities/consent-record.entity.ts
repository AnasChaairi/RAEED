import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

export type ConsentType = 'privacy_policy' | 'image_rights';
export type ImageRightsLevel = 'allowed' | 'app_only' | 'not_allowed';

/**
 * `consent_record` — append-only consent history.
 *
 * "Current" consent for a `(child_id, type)` is the row with the latest
 * `effective_at`; nothing is ever updated in place, because `AUD-02` and the
 * Memories Wall's re-check-on-downgrade both need the full history.
 *
 * Two guardians of one child can write independent rows and disagree. The
 * resolution is **most-restrictive-wins** and it lives in application code, not
 * in the schema (`specs/03-domain-model/entities.md`) — if any guardian's
 * current `image_rights` row says `not_allowed`, that is the answer, and the
 * disagreement is flagged to executives.
 */
@Entity({ name: 'consent_record' })
export class ConsentRecord {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'guardian_id', type: 'uuid' })
  guardianId: string;

  /** Null for `privacy_policy`, which is account-level. */
  @Column({ name: 'child_id', type: 'uuid', nullable: true })
  childId: string | null;

  @Column({ type: 'text' })
  type: ConsentType;

  @Column({ type: 'text', nullable: true })
  level: ImageRightsLevel | null;

  @Column({ type: 'int' })
  version: number;

  @Column({ name: 'effective_at', type: 'timestamptz' })
  effectiveAt: Date;

  @Column({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}
