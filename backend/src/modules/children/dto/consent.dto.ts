import { IsBoolean, IsObject } from 'class-validator';

import { ImageRightsLevel } from '../entities/consent-record.entity';

const LEVELS: ReadonlySet<string> = new Set([
  'allowed',
  'app_only',
  'not_allowed',
]);

/** `POST /consent`. */
export class SubmitConsentDto {
  @IsBoolean()
  privacy_policy_accepted: boolean;

  /**
   * Map of child id to level, carrying an entry for **every** child the screen
   * displayed — including ones left at the default.
   *
   * "The guardian looked at this and left it at not-allowed" and "the guardian
   * was never asked" must be distinguishable rows, and a missing entry is not
   * treated as permission.
   */
  @IsObject()
  image_rights: Record<string, ImageRightsLevel>;
}

/** Validates the map's values, which `@IsObject` alone cannot. */
export function assertValidLevels(
  imageRights: Record<string, string>,
): asserts imageRights is Record<string, ImageRightsLevel> {
  for (const [childId, level] of Object.entries(imageRights)) {
    if (!LEVELS.has(level)) {
      throw new Error(`image_rights.${childId} is not a valid level`);
    }
  }
}
