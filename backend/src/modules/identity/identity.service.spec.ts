import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { ApiError, ApiErrorCode } from '../../common/http/api-error';
import { IdentityService } from './identity.service';
import { LoginThrottle } from './login-throttle.service';
import { PasswordService } from './password.service';
import { TokenService } from './token.service';

describe('IdentityService sign-in', () => {
  const passwords = new PasswordService();
  const device = '3c6d3b9e-6b4a-4d4b-9d3e-2f1a0c8b7e6d';

  async function build(rows: Array<{ id: string; is_active: boolean; password_hash: string | null }>) {
    const statements: Array<{ sql: string; params: unknown[] }> = [];
    const runQuery = async (sql: string, params: unknown[] = []): Promise<unknown> => {
      statements.push({ sql, params });
      if (sql.includes('select id, is_active, password_hash from app_user')) return rows;
      if (sql.includes('select password_hash from app_user')) {
        return rows.map((r) => ({ password_hash: r.password_hash }));
      }
      return [];
    };
    const dataSource = {
      query: runQuery,
      manager: { query: runQuery },
    } as unknown as DataSource;
    const throttle = {
      assertAllowed: jest.fn().mockResolvedValue(undefined),
      recordFailure: jest.fn().mockResolvedValue(undefined),
      reset: jest.fn().mockResolvedValue(undefined),
    };
    const tokens = {
      issue: jest.fn().mockResolvedValue({ accessToken: 'a', refreshToken: 'r' }),
    };
    const service = new IdentityService(
      dataSource,
      passwords,
      throttle as unknown as LoginThrottle,
      tokens as unknown as TokenService,
    );
    return { service, statements, throttle, tokens };
  }

  async function expectInvalidCredentials(promise: Promise<unknown>): Promise<void> {
    await expect(promise).rejects.toMatchObject({ code: ApiErrorCode.AUTH_INVALID_CREDENTIALS });
  }

  it('issues tokens for the right password and forgets earlier failures', async () => {
    const hash = await passwords.hash('raeed1');
    const { service, statements, throttle, tokens } = await build([
      { id: 'u1', is_active: true, password_hash: hash },
    ]);

    const pair = await service.login('+212600000001', 'raeed1', device, '10.0.0.1');

    expect(pair).toEqual({ accessToken: 'a', refreshToken: 'r' });
    expect(throttle.assertAllowed).toHaveBeenCalledWith('+212600000001', '10.0.0.1');
    expect(throttle.reset).toHaveBeenCalledWith('+212600000001');
    expect(throttle.recordFailure).not.toHaveBeenCalled();
    expect(tokens.issue).toHaveBeenCalledWith('u1', device);
    expect(statements.some((s) => s.sql.includes('insert into user_device'))).toBe(true);
  });

  it('a wrong password, an unknown number, a deactivated account and a passwordless account all fail alike', async () => {
    const hash = await passwords.hash('raeed1');
    const cases = [
      { rows: [{ id: 'u1', is_active: true, password_hash: hash }], password: 'raeed2' },
      { rows: [], password: 'raeed1' },
      { rows: [{ id: 'u1', is_active: false, password_hash: hash }], password: 'raeed1' },
      { rows: [{ id: 'u1', is_active: true, password_hash: null }], password: 'raeed1' },
    ];
    for (const { rows, password } of cases) {
      const { service, throttle, tokens } = await build(rows);
      await expectInvalidCredentials(service.login('+212600000001', password, device, '10.0.0.1'));
      expect(throttle.recordFailure).toHaveBeenCalledWith('+212600000001', '10.0.0.1');
      expect(tokens.issue).not.toHaveBeenCalled();
    }
  });

  it('does not even check the password while the number is throttled', async () => {
    const hash = await passwords.hash('raeed1');
    const { service, throttle, statements } = await build([
      { id: 'u1', is_active: true, password_hash: hash },
    ]);
    throttle.assertAllowed.mockRejectedValue(ApiError.rateLimited(600));

    await expect(service.login('+212600000001', 'raeed1', device, '10.0.0.1')).rejects.toMatchObject({
      code: ApiErrorCode.AUTH_RATE_LIMITED,
    });
    expect(statements.some((s) => s.sql.includes('from app_user'))).toBe(false);
  });

  it('changing a password requires the current one and stores a new hash', async () => {
    const hash = await passwords.hash('raeed1');
    const { service, statements } = await build([{ id: 'u1', is_active: true, password_hash: hash }]);
    const user = new AuthenticatedUser('u1', new Set(['parent']), new Set(), new Set(), null);

    await expectInvalidCredentials(service.changePassword(user, 'wrong1', 'new123'));
    expect(statements.some((s) => s.sql.includes('set password_hash'))).toBe(false);

    await service.changePassword(user, 'raeed1', 'new123');
    const update = statements.find((s) => s.sql.includes('set password_hash'))!;
    expect(update.params[0]).toBe('u1');
    expect(await passwords.verify('new123', update.params[1] as string)).toBe(true);
  });
});
