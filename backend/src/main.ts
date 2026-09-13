import 'reflect-metadata';
import { Logger, ValidationPipe } from '@nestjs/common';
import { ValidationError } from 'class-validator';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app.module';
import { loadConfig } from './common/config/env';
import { ApiError } from './common/http/api-error';
import { ErrorEnvelopeFilter } from './common/http/error.filter';

/**
 * Flattens class-validator's nested errors into `field.path` → messages.
 *
 * Without this, a bad value inside an array — `image_rights[0].level` — comes
 * back as an empty list against `image_rights`, telling a client only that
 * *something* in there is wrong. Naming the exact path is the difference
 * between a 422 a developer can act on and one they have to bisect.
 */
function flatten(
  errors: ValidationError[],
  parentPath = '',
): Record<string, string[]> {
  const flattened: Record<string, string[]> = {};

  for (const error of errors) {
    const path = parentPath ? `${parentPath}.${error.property}` : error.property;
    const messages = Object.values(error.constraints ?? {});
    if (messages.length > 0) flattened[path] = messages;

    if (error.children && error.children.length > 0) {
      Object.assign(flattened, flatten(error.children, path));
    }
  }

  return flattened;
}

async function bootstrap(): Promise<void> {
  const config = loadConfig();
  const app = await NestFactory.create(AppModule, { bufferLogs: false });

  // Versioned at the path (`specs/04-api/conventions.md`); a breaking change
  // bumps this to v2 rather than changing an existing route's behaviour.
  app.setGlobalPrefix('api/v1');

  app.useGlobalFilters(new ErrorEnvelopeFilter());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      // Rejects unknown fields outright rather than ignoring them: a client
      // sending `role: "admin"` in a body should fail loudly, not silently
      // have it dropped and assume it worked.
      forbidNonWhitelisted: true,
      transform: true,
      exceptionFactory: (errors) => ApiError.validationFailed(flatten(errors)),
    }),
  );

  // The Flutter app runs from a device, and the React dashboard from a
  // browser; in local development the web build is served from an arbitrary
  // port, so development allows any origin and deployed environments do not.
  app.enableCors({
    origin: config.nodeEnv === 'development' ? true : false,
    credentials: true,
  });

  await app.listen(config.port, '0.0.0.0');
  new Logger('bootstrap').log(
    `RAEED API listening on :${config.port} (${config.nodeEnv})`,
  );
}

void bootstrap();
