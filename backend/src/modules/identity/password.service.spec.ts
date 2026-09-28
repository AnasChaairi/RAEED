import { PasswordService } from './password.service';

describe('PasswordService', () => {
  const passwords = new PasswordService();

  it('accepts exactly six letters or digits and nothing else', () => {
    for (const ok of ['raeed1', 'ABC123', '123456', 'abcdef']) {
      expect(passwords.isWellFormed(ok)).toBe(true);
    }
    for (const bad of ['', 'raeed', 'raeed12', 'raeed!', 'رائد12', 'ra ed1']) {
      expect(passwords.isWellFormed(bad)).toBe(false);
    }
  });

  it('generates well-formed passwords without look-alike characters', () => {
    for (let index = 0; index < 50; index += 1) {
      const generated = passwords.generate();
      expect(passwords.isWellFormed(generated)).toBe(true);
      expect(generated).toMatch(/^[a-hj-km-np-z2-9]{6}$/);
    }
  });

  it('verifies a password against its own hash and no other', async () => {
    const stored = await passwords.hash('raeed1');
    expect(stored.startsWith('scrypt$')).toBe(true);
    expect(stored).not.toContain('raeed1');
    expect(await passwords.verify('raeed1', stored)).toBe(true);
    expect(await passwords.verify('raeed2', stored)).toBe(false);
    expect(await passwords.verify('RAEED1', stored)).toBe(false);
  });

  it('salts, so the same password hashes differently twice', async () => {
    expect(await passwords.hash('raeed1')).not.toBe(await passwords.hash('raeed1'));
  });

  it('refuses an account with no password, without throwing', async () => {
    expect(await passwords.verify('raeed1', null)).toBe(false);
    expect(await passwords.verify('raeed1', 'not-a-hash')).toBe(false);
  });
});
