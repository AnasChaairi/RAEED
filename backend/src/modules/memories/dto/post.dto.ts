import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class PostMediaDto {
  /** A key from `POST /media`. */
  @IsString()
  @MinLength(1)
  @MaxLength(300)
  storage_key: string;

  @IsIn(['photo', 'video'])
  media_kind: 'photo' | 'video';
}

/** `POST /memories/posts` (`MemoriesPostInput`). */
export class CreatePostDto {
  @IsUUID()
  album_id: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  caption?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(12)
  @ValidateNested({ each: true })
  @Type(() => PostMediaDto)
  media: PostMediaDto[];

  /** The children who appear; each is checked against their current image rights (`WAL-06`). */
  @IsArray()
  @ArrayMaxSize(60)
  @IsUUID('all', { each: true })
  tagged_child_ids: string[];
}
