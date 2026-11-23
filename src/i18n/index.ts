import { getLocales } from 'expo-localization';
import { createInstance } from 'i18next';
import { initReactI18next } from 'react-i18next';

import es from './es.json';

// Neutral Spanish (tuteo). Add a language: create <code>.json and register it here.
export const resources = { es: { translation: es } } as const;

const instance = createInstance();
void instance.use(initReactI18next).init({
  resources,
  lng: getLocales()[0]?.languageCode ?? 'es',
  fallbackLng: 'es',
  interpolation: { escapeValue: false },
});

export default instance;
