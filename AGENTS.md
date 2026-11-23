This is an Expo/React Native mobile application. Prioritize mobile-first patterns, performance, and cross-platform compatibility.

## Expo has changed — do not trust your training data

Expo ships breaking changes every SDK release. APIs you remember are likely renamed, moved, or removed. Before writing any code that touches an Expo, EAS, or React Native API:

1. Read the major version of the `expo` package in `package.json`.
2. Fetch the matching versioned docs: `https://docs.expo.dev/versions/v<major>.0.0/`
3. For anything else, fetch https://docs.expo.dev/llms.txt — an index of all Expo docs with corrections to common LLM misconceptions. Follow its links to the specific page you need; never answer from memory.

## Commands

Use `bunx` instead of `npx` if the project uses bun (`bun.lock` present).

```bash
npx expo install <package>  # ALWAYS use instead of npm/yarn/pnpm/bun add — resolves SDK-compatible versions
npx expo start              # start the dev server
npx expo lint               # lint
npx tsc --noEmit            # typecheck
npx expo-doctor             # diagnose dependency and config issues
npx expo install --fix      # fix incompatible package versions
```

Run `npm run lint` and `npm run typecheck` (and `npm test`) before declaring any task done.

## Navigation & Routing

- Use **Expo Router** for all navigation. Routes live in the `app/` directory (`src/app/` in projects that use `src/`; see the architecture map in CLAUDE.md) — every file there is a screen, `_layout.tsx` files define navigators. Keep non-route code (components, hooks, utils) outside the routes directory.
- Import `Link`, `router`, and `useLocalSearchParams` from `expo-router`.
- Docs: https://docs.expo.dev/router/introduction.md

## Builds

Builds are local, not EAS: `npm run apk`, `apk:preview`, `apk:production` and `aab` (where defined) run `build-apk` from `@jujeme/mobile-tools`, configured in `build.config.json`. After adding a native library run `npm run apk -- --prebuild`. Details in `docs/BUILD.md`. Do not use `eas build`, `eas submit` or `eas update`.

## Rules

- If `ios/` and `android/` directories do not exist, they are generated (Continuous Native Generation). Never create or edit them by hand — configure native behavior in `app.json` and config plugins.
- Expo Go only includes its bundled native modules. After adding a library with native code, the app needs a development build: `npx expo run:ios|android` locally, or `npm run apk` (dev client build).
- Prefer recommended Expo modules over third-party libraries, and check your available skills before adding dependencies. Docs: https://docs.expo.dev/versions/latest/index.md
