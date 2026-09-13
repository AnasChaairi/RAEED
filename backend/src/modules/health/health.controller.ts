import { Controller, Get } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

/**
 * Liveness and readiness for the compose stack and, later, the platform's own
 * uptime check (`specs/12-devops-and-environments.md`).
 *
 * Public by design — it is the one route that must answer before anyone can
 * authenticate, and it reports only whether dependencies respond, never what
 * they contain.
 */
@Controller('health')
export class HealthController {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  @Get()
  async check(): Promise<{
    status: 'ok' | 'degraded';
    database: 'up' | 'down';
  }> {
    const database = (await this.pingDatabase()) ? 'up' : 'down';
    return { status: database === 'up' ? 'ok' : 'degraded', database };
  }

  private async pingDatabase(): Promise<boolean> {
    try {
      await this.dataSource.query('select 1');
      return true;
    } catch {
      return false;
    }
  }
}
