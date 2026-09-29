import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class NewGuardianDto {
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  display_name: string;

  /** E.164 Moroccan mobile. */
  @Matches(/^\+212[5-7]\d{8}$/)
  phone: string;

  @IsString()
  @MaxLength(40)
  relationship: string;
}

export class NewChildDto {
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  full_name: string;

  @IsISO8601({ strict: true })
  dob: string;

  @IsOptional()
  @IsUUID()
  group_id?: string;
}

/** `POST /families` — guardians and their children, in one recorded act. */
export class CreateFamilyDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(6)
  @ValidateNested({ each: true })
  @Type(() => NewGuardianDto)
  guardians: NewGuardianDto[];

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(12)
  @ValidateNested({ each: true })
  @Type(() => NewChildDto)
  children: NewChildDto[];
}

/** `POST /invitations` — hand a guardian a fresh password. */
export class InvitationDto {
  @IsUUID()
  user_id: string;
}

/** `PATCH /families/{id}/guardians/{gid}` — only what is sent changes. */
export class UpdateGuardianDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  display_name?: string;

  /** E.164 Moroccan mobile. Changing it signs the guardian out everywhere. */
  @IsOptional()
  @Matches(/^\+212[5-7]\d{8}$/)
  phone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  relationship?: string;
}

/** `PATCH /families/{id}/children/{cid}` — a name or birth-date correction. */
export class UpdateChildDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  full_name?: string;

  @IsOptional()
  @IsISO8601({ strict: true })
  dob?: string;
}
