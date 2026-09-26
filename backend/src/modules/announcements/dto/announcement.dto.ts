import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

export type AudienceType = 'all' | 'parents' | 'educators' | 'categories' | 'groups';

/** `audience_json` as the composer sends it (`specs/03-domain-model/schema.sql`). */
export class AudienceDto {
  @IsIn(['all', 'parents', 'educators', 'categories', 'groups'])
  type: AudienceType;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(50)
  @IsUUID('all', { each: true })
  category_ids?: string[];

  /** The educator's audience (`ANN-03`): their own groups only. */
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(50)
  @IsUUID('all', { each: true })
  group_ids?: string[];
}

/** `POST /announcements`. */
export class CreateAnnouncementDto {
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  title: string;

  @IsOptional()
  @IsString()
  @MaxLength(5000)
  body?: string;

  @ValidateNested()
  @Type(() => AudienceDto)
  audience: AudienceDto;

  @IsOptional()
  @IsIn(['normal', 'urgent'])
  priority?: 'normal' | 'urgent';

  @IsOptional()
  @IsISO8601({ strict: true })
  expire_at?: string;

  /** Ask every recipient to confirm they read it (`ANN-06`). */
  @IsOptional()
  @IsBoolean()
  ack_required?: boolean;
}
