import { ArrayMaxSize, ArrayMinSize, IsArray, IsIn, IsOptional, IsUUID } from 'class-validator';

export const EXPORT_FIELDS = [
  'name',
  'dob',
  'group',
  'guardian',
  'phone',
  'consent',
  'allergies',
  'medications',
] as const;
export type ExportField = (typeof EXPORT_FIELDS)[number];

/** The fields that carry health information, off by default and flagged. */
export const HEALTH_FIELDS: ReadonlySet<ExportField> = new Set(['allergies', 'medications']);

/** `POST /reports/exports`. */
export class CreateExportDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(EXPORT_FIELDS.length)
  @IsIn(EXPORT_FIELDS, { each: true })
  fields: ExportField[];

  @IsOptional()
  @IsUUID()
  group_id?: string;
}
