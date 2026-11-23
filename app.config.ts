// Two builds of the same app, each with its own Firebase project (see src/constants/environments.json):
//   APP_VARIANT=production  -> production environment, firebase/prod/google-services.json
//   anything else (default) -> development environment, firebase/dev/google-services.json
// The default is development on purpose: forgetting the variable never writes to production data.
// Changing the variable changes the native project, so it needs `expo prebuild --clean` (scripts/build-apk.mjs does it).
import type { ConfigContext, ExpoConfig } from 'expo/config';

import environments from './src/constants/environments.json';

export default ({ config }: ConfigContext): ExpoConfig => {
  const variant = process.env.APP_VARIANT === 'production' ? 'production' : 'development';
  const environment = environments[variant];

  return {
    ...config,
    name: environment.name,
    slug: config.slug ?? 'nombra',
    scheme: environment.scheme,
    ios: { ...config.ios, bundleIdentifier: environment.package },
    android: { ...config.android, package: environment.package, googleServicesFile: environment.googleServicesFile },
    // Signs the release with the upload key when scripts/build-apk.mjs provides it (production builds).
    plugins: [...(config.plugins ?? []), './plugins/withUploadSigning'],
    extra: { ...config.extra, appVariant: variant },
  };
};
