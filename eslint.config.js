// https://docs.expo.dev/guides/using-eslint/
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');

module.exports = defineConfig([
  expoConfig,
  { ignores: ['dist/*', 'android/*', 'builds/*'] },
  {
    // Standard: no file over 500 lines.
    rules: { 'max-lines': ['error', { max: 500, skipBlankLines: true, skipComments: true }] },
  },
]);
