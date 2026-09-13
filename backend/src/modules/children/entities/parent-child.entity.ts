import { Column, Entity, PrimaryColumn } from 'typeorm';

/**
 * `parent_child` — append-only guardianship.
 *
 * Unlinking sets `unlinked_at` rather than deleting the row, so the history of
 * who could see a child survives (`specs/03-domain-model/entities.md`). Every
 * parent-scope ability check traverses this table with
 * `unlinked_at is null`.
 */
@Entity({ name: 'parent_child' })
export class ParentChild {
  @PrimaryColumn({ name: 'guardian_user_id', type: 'uuid' })
  guardianUserId: string;

  @PrimaryColumn({ name: 'child_id', type: 'uuid' })
  childId: string;

  @PrimaryColumn({ name: 'linked_at', type: 'timestamptz' })
  linkedAt: Date;

  @Column({ name: 'relationship_type', type: 'text' })
  relationshipType: string;

  /** Only Executives/Admin may set this (`ACC-05`). */
  @Column({ name: 'unlinked_at', type: 'timestamptz', nullable: true })
  unlinkedAt: Date | null;
}
