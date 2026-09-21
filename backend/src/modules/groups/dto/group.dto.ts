import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class ScheduleSlotDto {
  /** 0 = Sunday, as in `weekly_schedule_json`. */
  @IsInt()
  @Min(0)
  @Max(6)
  weekday: number;

  @Matches(/^\d{2}:\d{2}$/)
  starts_at: string;

  @Matches(/^\d{2}:\d{2}$/)
  ends_at: string;
}

/** `POST /groups`. */
export class CreateGroupDto {
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  name: string;

  @IsUUID()
  category_id: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(200)
  capacity?: number;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(7)
  @ValidateNested({ each: true })
  @Type(() => ScheduleSlotDto)
  weekly_schedule?: ScheduleSlotDto[];

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(10)
  @IsUUID('all', { each: true })
  educator_ids: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(100)
  @IsUUID('all', { each: true })
  child_ids?: string[];
}

/** `POST /groups/{id}/children`. */
export class AssignChildrenDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @IsUUID('all', { each: true })
  child_ids: string[];
}
