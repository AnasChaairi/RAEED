import {
  Body,
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
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { SendMessageDto } from './dto/message.dto';
import {
  ConversationDetailView,
  ConversationSummaryView,
  MessageView,
  MessagingService,
} from './messaging.service';

/**
 * Every route here checks scope against the loaded conversation inside the
 * service — membership is a relationship the guard cannot know before the
 * row is fetched.
 */
@Controller()
@UseGuards(JwtAuthGuard)
export class MessagingController {
  constructor(private readonly messaging: MessagingService) {}

  @Get('conversations')
  async list(
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ data: ConversationSummaryView[]; page: { cursor: null; has_more: false } }> {
    return {
      data: await this.messaging.list(user),
      page: { cursor: null, has_more: false },
    };
  }

  @Get('conversations/:conversationId')
  detail(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId', ParseUUIDPipe) conversationId: string,
  ): Promise<ConversationDetailView> {
    return this.messaging.detail(user, conversationId);
  }

  @Get('conversations/:conversationId/messages')
  async messages(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId', ParseUUIDPipe) conversationId: string,
  ): Promise<{ data: MessageView[]; page: { cursor: null; has_more: false } }> {
    return {
      data: await this.messaging.messages(user, conversationId),
      page: { cursor: null, has_more: false },
    };
  }

  @Post('conversations/:conversationId/messages')
  @HttpCode(HttpStatus.CREATED)
  send(
    @CurrentUser() user: AuthenticatedUser,
    @Param('conversationId', ParseUUIDPipe) conversationId: string,
    @Body() body: SendMessageDto,
  ): Promise<MessageView> {
    return this.messaging.send(user, conversationId, body.body);
  }

  @Post('messages/:messageId/hide')
  @HttpCode(HttpStatus.NO_CONTENT)
  hide(
    @CurrentUser() user: AuthenticatedUser,
    @Param('messageId', ParseUUIDPipe) messageId: string,
  ): Promise<void> {
    return this.messaging.hide(user, messageId);
  }

  @Post('message-reports/:reportId/dismiss')
  @HttpCode(HttpStatus.NO_CONTENT)
  dismiss(
    @CurrentUser() user: AuthenticatedUser,
    @Param('reportId', ParseUUIDPipe) reportId: string,
  ): Promise<void> {
    return this.messaging.dismissReport(user, reportId);
  }
}
