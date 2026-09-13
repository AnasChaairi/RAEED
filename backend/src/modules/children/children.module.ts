import { Module } from '@nestjs/common';

import { IdentityModule } from '../identity/identity.module';
import { ChildrenController } from './children.controller';
import { ChildrenService } from './children.service';
import { ConsentService } from './consent.service';

/**
 * `children` — child, parent_child, child_group, consent_record
 * (`specs/07-backend-spec.md`).
 *
 * Imports `identity` for ScopeService only, through its exported surface —
 * never by reaching into another module's repositories, which is the boundary
 * rule the modular monolith rests on.
 */
@Module({
  imports: [IdentityModule],
  controllers: [ChildrenController],
  providers: [ChildrenService, ConsentService],
  exports: [ChildrenService, ConsentService],
})
export class ChildrenModule {}
