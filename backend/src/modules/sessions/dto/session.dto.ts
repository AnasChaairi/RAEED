import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export type MaterialVisibility = 'before_session' | 'after_session' | 'staff_only';
export type MaterialKind = 'document' | 'image' | 'audio' | 'video' | 'link';

export class MaterialVisibilityDto {
  @IsUUID()
  id: string;

  @IsIn(['before_session', 'after_session', 'staff_only'])
  visibility: MaterialVisibility;
}

/** `PATCH /sessions/{id}` — the content an educator adds to a generated slot. */
export class UpdateSessionDto {
  @IsOptional()
  @IsString()
  @MaxLength(200)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  theme?: string;

  @IsOptional()
  @IsString()
  @MaxLength(4000)
  objectives?: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => MaterialVisibilityDto)
  materials?: MaterialVisibilityDto[];
}

/** `POST /sessions/{id}/materials`. */
export class AddMaterialDto {
  @IsIn(['document', 'image', 'audio', 'video', 'link'])
  kind: MaterialKind;

  /** An upload's key from `POST /media`, or the URL itself for a link. */
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  storage_key: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  title?: string;

  @IsOptional()
  @IsIn(['before_session', 'after_session', 'staff_only'])
  visibility?: MaterialVisibility;

  @IsOptional()
  @IsInt()
  @Min(0)
  size_bytes?: number;
}

/** `POST /sessions/{id}/cancel` — cancel outright, or move to a new slot. */
export class ChangeSessionDto {
  @IsIn(['cancel', 'reschedule'])
  mode: 'cancel' | 'reschedule';

  @IsString()
  @MinLength(1)
  @MaxLength(500)
  reason: string;

  @IsOptional()
  @IsISO8601({ strict: true })
  starts_at?: string;

  @IsOptional()
  @IsISO8601({ strict: true })
  ends_at?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  place?: string;
}

/** `POST /sessions/{id}/summary`. */
export class SendSummaryDto {
  @IsString()
  @MinLength(1)
  @MaxLength(4000)
  body: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(12)
  @IsString({ each: true })
  media_keys?: string[];
}

/** `POST /sessions/{id}/homework`. */
export class CreateHomeworkDto {
  @IsOptional()
  @IsString()
  @MaxLength(200)
  title?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(4000)
  instructions: string;

  @IsISO8601({ strict: true })
  due_at: string;

  /** Omitted or null = the whole group (`HWK-01`). */
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(60)
  @IsUUID('all', { each: true })
  target_child_ids?: string[] | null;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  attachment_storage_key?: string;
}

export const SESSION_KINDS = ['session', 'sport', 'workshop'] as const;
export type SessionKind = (typeof SESSION_KINDS)[number];

/** `POST /sessions` — an activity the educator adds by hand for one of their groups. */
export class CreateSessionDto {
  @IsUUID()
  group_id: string;

  @IsIn(SESSION_KINDS)
  kind: SessionKind;

  @IsISO8601({ strict: true })
  starts_at: string;

  @IsISO8601({ strict: true })
  ends_at: string;

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  place?: string;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  theme?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  objectives?: string;
}
