import environments from '@/constants/environments.json';

export type AppVariant = 'development' | 'production';

// Pure: maps the raw value (Constants.expoConfig.extra.appVariant) to a known variant. Unknown means development.
export function resolveAppVariant(raw: unknown): AppVariant {
  return raw === 'production' ? 'production' : 'development';
}

export function getEnvironment(raw: unknown) {
  return environments[resolveAppVariant(raw)];
}
