import { IsIn, IsString, MaxLength, MinLength } from 'class-validator';

/** `POST /conversations/{id}/messages` — text only for now. */
export class SendMessageDto {
  @IsIn(['text'])
  kind: 'text';

  @IsString()
  @MinLength(1)
  @MaxLength(4000)
  body: string;
}
