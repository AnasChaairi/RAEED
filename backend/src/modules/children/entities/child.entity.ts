import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

/**
 * `child` — the record everything in RAEED is ultimately about, and the one
 * the child themselves is not a user of.
 */
@Entity({ name: 'child' })
export class Child {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'full_name', type: 'text' })
  fullName: string;

  @Column({ type: 'date' })
  dob: string;

  @Column({ name: 'photo_url', type: 'text', nullable: true })
  photoUrl: string | null;

  @Column({ name: 'school_level', type: 'text', nullable: true })
  schoolLevel: string | null;

  /**
   * One versioned JSON column rather than a column per health field.
   *
   * Health data changes shape more often than the rest of the schema, and every
   * *access* is audit-logged regardless of column layout (`AUD-03`) — so a
   * rigid design buys nothing. The exact keys are open decision #2, pending the
   * CNDP filing; until then the working draft is
   * `{ allergies?, conditions?, medications?, dietary_notes? }`.
   *
   * Never selected into a list response. `specs/04-api/openapi.yaml` gives the
   * list a boolean `health_alert` instead, because a list view is read in
   * public.
   */
  @Column({ name: 'health_json', type: 'jsonb', default: () => "'{}'" })
  healthJson: Record<string, unknown>;

  @Column({ name: 'health_json_version', type: 'int', default: 1 })
  healthJsonVersion: number;

  @Column({ name: 'special_needs_notes', type: 'text', nullable: true })
  specialNeedsNotes: string | null;

  @Column({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @Column({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  @Column({ name: 'deleted_at', type: 'timestamptz', nullable: true })
  deletedAt: Date | null;

  /** Whether any health information is recorded, without revealing what. */
  get hasHealthAlert(): boolean {
    return Object.keys(this.healthJson ?? {}).length > 0;
  }
}
