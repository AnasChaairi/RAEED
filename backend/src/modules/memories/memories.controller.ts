import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import {
  CheckAbility,
  CheckAbilityGuard,
} from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { AlbumView, MemoriesService, ReviewQueueView } from './memories.service';

@Controller('memories')
@UseGuards(JwtAuthGuard, CheckAbilityGuard)
export class MemoriesController {
  constructor(private readonly memories: MemoriesService) {}

  @Get('review-queue')
  @CheckAbility('update', 'MemoriesPost')
  reviewQueue(@CurrentUser() user: AuthenticatedUser): Promise<ReviewQueueView> {
    return this.memories.reviewQueue(user);
  }

  @Get('albums')
  @CheckAbility('read', 'MemoriesPost')
  async albums(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: AlbumView[]; page: { cursor: null; has_more: false } }> {
    return {
      data: await this.memories.albums(user),
      page: { cursor: null, has_more: false },
    };
  }

  @Post('posts/:postId/approve')
  @HttpCode(HttpStatus.NO_CONTENT)
  @CheckAbility('update', 'MemoriesPost')
  approve(
    @CurrentUser() user: AuthenticatedUser,
    @Param('postId', ParseUUIDPipe) postId: string,
  ): Promise<void> {
    return this.memories.approve(user, postId);
  }

  @Post('posts/:postId/hide')
  @HttpCode(HttpStatus.NO_CONTENT)
  @CheckAbility('update', 'MemoriesPost')
  hide(
    @CurrentUser() user: AuthenticatedUser,
    @Param('postId', ParseUUIDPipe) postId: string,
  ): Promise<void> {
    return this.memories.hide(user, postId);
  }
}
