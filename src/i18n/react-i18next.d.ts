import 'react-i18next';

import type { resources } from './index';

// Typed i18n keys: t('home.title') is checked at compile time.
declare module 'i18next' {
  interface CustomTypeOptions {
    defaultNS: 'translation';
    resources: (typeof resources)['es'];
  }
}
