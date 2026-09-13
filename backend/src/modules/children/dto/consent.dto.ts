import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsUUID,
  ValidateNested,
} from 'class-validator';

import { ImageRightsLevel } from '../entities/consent-record.entity';

/** One child's image-rights choice. */
export class ImageRightsEntryDto {
  @IsUUID()
  child_id: string;

  @IsIn(['allowed', 'app_only', 'not_allowed'])
  level: ImageRightsLevel;
}

/**
 * `POST /consent`.
 *
 * `image_rights` is a **list**, not a map keyed by child id. The list is the
 * better contract for two reasons: each entry is a typed object OpenAPI can
 * describe and class-validator can check per field, rather than a free-form
 * `additionalProperties` map whose values nothing validates; and the ordering
 * the screen displayed is preserved, which matters when a guardian is asked to
 * confirm what they just chose.
 *
 * It carries an entry for **every** child the screen displayed, including ones
 * left at the default. "The guardian looked at this and left it at
 * not-allowed" and "the guardian was never asked" must be distinguishable rows
 * in `consent_record`, and a missing entry is never read as permission.
 */
export class SubmitConsentDto {
  @IsBoolean()
  privacy_policy_accepted: boolean;

  @IsArray()
  // A guardian has a handful of children, not a hundred. An unbounded list is
  // an unbounded transaction.
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => ImageRightsEntryDto)
  image_rights: ImageRightsEntryDto[];
}
