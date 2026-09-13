import { Column, Entity, PrimaryColumn } from 'typeorm';

/**
 * `child_group` — time-bounded group membership.
 *
 * Moving a child between groups closes the old row and opens a new one
 * (`ORG-04`), never an update in place. A child genuinely between groups at a
 * season boundary has no current row, and that is a state to render rather
 * than a payload to reject.
 */
@Entity({ name: 'child_group' })
export class ChildGroup {
  @PrimaryColumn({ name: 'child_id', type: 'uuid' })
  childId: string;

  @PrimaryColumn({ name: 'group_id', type: 'uuid' })
  groupId: string;

  @PrimaryColumn({ name: 'valid_from', type: 'timestamptz' })
  validFrom: Date;

  @Column({ name: 'is_main', type: 'boolean', default: true })
  isMain: boolean;

  @Column({ name: 'valid_to', type: 'timestamptz', nullable: true })
  validTo: Date | null;
}
