import { getEnvironment, resolveAppVariant } from '../appVariant';

describe('resolveAppVariant', () => {
  it('returns production only for "production"', () => {
    expect(resolveAppVariant('production')).toBe('production');
  });

  it('defaults to development for anything else', () => {
    expect(resolveAppVariant(undefined)).toBe('development');
    expect(resolveAppVariant('staging')).toBe('development');
  });
});

describe('getEnvironment', () => {
  it('uses the dev Firebase project by default', () => {
    expect(getEnvironment(undefined).googleServicesFile).toContain('firebase/dev/');
  });

  it('uses the prod Firebase project for production', () => {
    expect(getEnvironment('production').googleServicesFile).toContain('firebase/prod/');
  });
});
