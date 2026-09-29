import { IsISO8601, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

/** `POST /branches`. */
export class CreateBranchDto {
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  address?: string;
}

/** `POST /categories` — a name only; age range and gender wait for open decision #1. */
export class CreateCategoryDto {
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  name: string;
}

/** `POST /seasons` — opens active; the previous active season stays until archived. */
export class CreateSeasonDto {
  @IsString()
  @MinLength(2)
  @MaxLength(40)
  label: string;

  @IsISO8601({ strict: true })
  start_date: string;

  @IsISO8601({ strict: true })
  end_date: string;
}
