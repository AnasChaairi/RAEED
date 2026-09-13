import { Injectable, Logger } from '@nestjs/common';

import { loadConfig } from '../../common/config/env';

export interface PushMessage {
  readonly tokens: string[];
  /** Ids only — never a child's name or any health text. */
  readonly data: Record<string, string>;
}

/**
 * Sends pushes through Firebase Cloud Messaging.
 *
 * FCM is the only Firebase product in the stack, used for delivery and nothing
 * else (`specs/01-product-brief.md`), which is what keeps the "no tracking SDK"
 * property intact on the device.
 *
 * With no service account configured — the local default — it logs what it
 * would have sent instead of pretending to succeed silently. The critical
 * pipeline stays fully observable in development, and the absence of a
 * provider is visible rather than indistinguishable from a working one.
 */
@Injectable()
export class PushDispatcher {
  private readonly logger = new Logger('push');
  private readonly config = loadConfig();

  async send(message: PushMessage): Promise<void> {
    if (this.config.fcmServiceAccountJson === '') {
      this.logger.warn(
        `[dev] would push to ${message.tokens.length} device(s): ` +
          JSON.stringify(message.data),
      );
      return;
    }

    // The FCM call goes here. Left explicit rather than stubbed as a no-op:
    // a silent success would make a broken critical pipeline look healthy.
    throw new Error(
      'FCM_SERVICE_ACCOUNT_JSON is set but the FCM client is not implemented yet.',
    );
  }
}
