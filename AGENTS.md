This is a Flutter mobile application (Android). Prioritize mobile-first patterns, performance and accessibility.

## Flutter changes fast — do not trust your training data

Flutter and its packages ship breaking changes (this project uses Flutter 3.50, where Material moved to the `material_ui` package). Before writing code that touches a Flutter or package API:

1. Read the versions in `pubspec.yaml` / `pubspec.lock`.
2. Check the docs of that version: https://docs.flutter.dev and the package page on https://pub.dev.
3. Trust `flutter analyze` over memory: deprecations and removals show up there.

## Commands

```bash
flutter pub add <package>          # ALWAYS use instead of editing pubspec.yaml by hand — resolves compatible versions
flutter run --flavor dev           # run the development flavor
flutter analyze                    # lint
flutter test                       # tests
dart format lib test scripts       # format
dart run scripts/check_styles.dart # design tokens check
flutter gen-l10n                   # regenerate lib/l10n/app_localizations*.dart after editing the .arb files
```

Run `flutter analyze`, `flutter test` and `dart run scripts/check_styles.dart` before declaring any task done.

## Navigation & Routing

- Use **go_router**. Routes are declared in `lib/app/router.dart`; screens live in `lib/features/<feature>/`. Navigate with `context.go` / `context.push`, never with raw `Navigator` calls.
- Docs: https://pub.dev/packages/go_router

## Builds

Builds are local: `dart run scripts/build.dart [--flavor dev|prod] [--aab] [--upload]`, configured in `build.config.json`. Details in `docs/BUILD.md`. Do not add Codemagic, Fastlane or other hosted build services.

## Rules

- `android/` is versioned, but edit it only for native configuration (flavors, signing, Firebase plugins). Do not hand-edit generated files (`GeneratedPluginRegistrant.java`, `lib/l10n/app_localizations*.dart`).
- Add Flutter/Dart packages with `flutter pub add`; after adding a package with native code, do a full rebuild (`flutter run`), not a hot reload.
- Prefer first-party and well-maintained pub.dev packages, and check your available skills before adding dependencies.
