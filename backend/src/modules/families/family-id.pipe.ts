import { Injectable, PipeTransform } from '@nestjs/common';

import { ApiError } from '../../common/http/api-error';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * A family id is its guardian set: the guardian ids, sorted and joined by
 * commas, exactly as `GET /families` returns it. This turns the path segment
 * back into that set — validated, deduplicated, sorted the way the list sorts
 * — so a service never sees an id it cannot re-derive.
 */
@Injectable()
export class ParseFamilyIdPipe implements PipeTransform<string, string[]> {
  transform(value: string): string[] {
    const ids = [...new Set((value ?? '').split(',').map((id) => id.trim().toLowerCase()))];
    if (ids.length === 0 || ids.length > 6 || ids.some((id) => !UUID.test(id))) {
      throw ApiError.validationFailed({ familyId: 'one to six guardian ids, joined by commas' });
    }
    return ids.sort((a, b) => a.localeCompare(b));
  }
}
