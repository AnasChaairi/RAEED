import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';

/** One mark in a `PATCH /sessions/{id}/attendance` batch. */
export class AttendanceRecordInputDto {
  @IsUUID()
  child_id: string;

  @IsIn(['present', 'absent', 'late', 'excused'])
  status: 'present' | 'absent' | 'late' | 'excused';

  /**
   * **The moment of the tap on the device**, not the moment of the request.
   *
   * This is the value the conflict rule compares against the stored
   * `recorded_at` (`specs/03-domain-model/entities.md`). A client that stamped
   * it at sync time would make every offline write look freshly authoritative
   * and silently overwrite whoever marked the child in the meantime — so it is
   * required, never defaulted server-side.
   */
  @IsISO8601({ strict: true })
  recorded_at_client: string;
}

export class PatchAttendanceDto {
  @IsArray()
  @ArrayMinSize(1)
  // A whole group in one request is the normal case (an educator submitting a
  // sheet marked offline); a thousand is not, and an unbounded batch is an
  // unbounded transaction.
  @ArrayMaxSize(200)
  @ValidateNested({ each: true })
  @Type(() => AttendanceRecordInputDto)
  records: AttendanceRecordInputDto[];
}

/** `POST /presence-confirmations/{id}/answers`. */
export class PresenceAnswerInputDto {
  @IsUUID()
  child_id: string;

  @IsIn(['yes', 'no', 'late'])
  answer: 'yes' | 'no' | 'late';

  @IsOptional()
  @IsIn(['illness', 'travel', 'exam', 'other'])
  reason?: 'illness' | 'travel' | 'exam' | 'other';

  /** Free text, accepted only alongside `other`. */
  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}
