import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import {
  CheckAbility,
  CheckAbilityGuard,
} from '../../common/abilities/check-ability.guard';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { ApiError } from '../../common/http/api-error';
import { CreatePostDto } from './dto/post.dto';
import { AlbumView, MemoriesService, MyPostView, ReviewQueueView } from './memories.service';

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

  /** The caller's own posts (`?mine=true` is the only listing an educator has). */
  @Get('posts')
  @CheckAbility('read', 'MemoriesPost')
  async posts(
    @CurrentUser() user: AuthenticatedUser,
    @Query('mine') mine?: string,
  ): Promise<{ data: MyPostView[]; page: { cursor: null; has_more: false } }> {
    if (mine !== 'true') throw ApiError.validationFailed({ mine: 'only mine=true is supported' });
    return { data: await this.memories.myPosts(user), page: { cursor: null, has_more: false } };
  }

  @Post('posts')
  @HttpCode(HttpStatus.CREATED)
  @CheckAbility('create', 'MemoriesPost')
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() body: CreatePostDto,
  ): Promise<MyPostView> {
    return this.memories.create(user, body);
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
