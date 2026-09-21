import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

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
