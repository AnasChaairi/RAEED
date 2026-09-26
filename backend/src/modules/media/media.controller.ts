import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { ApiError } from '../../common/http/api-error';
import { MAX_UPLOAD_BYTES, MediaService, MediaView, UploadedFileLike } from './media.service';

/**
 * Uploads and serves media. Signed-in only, both ways: a child's photo is
 * never a public URL, whatever the album's moderation mode.
 */
@Controller('media')
@UseGuards(JwtAuthGuard)
export class MediaController {
  constructor(private readonly media: MediaService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('file', { limits: { fileSize: MAX_UPLOAD_BYTES } }))
  upload(
    @CurrentUser() user: AuthenticatedUser,
    @UploadedFile() file: UploadedFileLike | undefined,
  ): Promise<MediaView> {
    if (!file) throw ApiError.validationFailed({ file: 'missing' });
    return this.media.store(user, file);
  }

  @Get(':owner/:name')
  async serve(
    @Param('owner') owner: string,
    @Param('name') name: string,
    @Res() response: Response,
  ): Promise<void> {
    const { stream, contentType } = await this.media.open(`${owner}/${name}`);
    response.setHeader('Content-Type', contentType);
    response.setHeader('Cache-Control', 'private, max-age=3600');
    stream.pipe(response);
  }
}
