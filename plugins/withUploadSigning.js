// Expo config plugin: signs the RELEASE build with the upload key when its Gradle properties are given
// (UPLOAD_STORE_FILE, UPLOAD_STORE_PASSWORD, UPLOAD_KEY_ALIAS, UPLOAD_KEY_PASSWORD — scripts/build-apk.mjs passes them for
// production builds as ORG_GRADLE_PROJECT_* environment variables, so the passwords never appear in a command line).
// Without them the release keeps the debug signing, which is what the preview build uses.
const { withAppBuildGradle } = require('@expo/config-plugins');

const RELEASE_SIGNING = `        release {
            if (project.hasProperty('UPLOAD_STORE_FILE')) {
                storeFile file(UPLOAD_STORE_FILE)
                storePassword UPLOAD_STORE_PASSWORD
                keyAlias UPLOAD_KEY_ALIAS
                keyPassword UPLOAD_KEY_PASSWORD
            }
        }
`;

module.exports = function withUploadSigning(config) {
  return withAppBuildGradle(config, (cfg) => {
    let gradle = cfg.modResults.contents;
    if (gradle.includes('UPLOAD_STORE_FILE')) return cfg;

    // A `release` signing config next to the `debug` one.
    const signingStart = gradle.indexOf('signingConfigs {');
    if (signingStart < 0) throw new Error('withUploadSigning: no signingConfigs block in app/build.gradle');
    const insertAt = gradle.indexOf('\n', signingStart) + 1;
    gradle = gradle.slice(0, insertAt) + RELEASE_SIGNING + gradle.slice(insertAt);

    // The release build type uses it when the properties are there.
    const buildTypes = gradle.indexOf('buildTypes {');
    const release = gradle.indexOf('release {', buildTypes);
    const debugSigning = 'signingConfig signingConfigs.debug';
    const at = gradle.indexOf(debugSigning, release);
    if (buildTypes < 0 || release < 0 || at < 0) throw new Error('withUploadSigning: the release build type was not found');
    gradle =
      gradle.slice(0, at) +
      "signingConfig project.hasProperty('UPLOAD_STORE_FILE') ? signingConfigs.release : signingConfigs.debug" +
      gradle.slice(at + debugSigning.length);

    cfg.modResults.contents = gradle;
    return cfg;
  });
};
