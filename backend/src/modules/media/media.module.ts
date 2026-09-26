import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { MediaController } from './media.controller';
import { MediaService } from './media.service';

@Module({
  imports: [IdentityModule],
  controllers: [MediaController],
  providers: [MediaService],
  exports: [MediaService],
})
export class MediaModule {}
