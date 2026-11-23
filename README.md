# Nombra

App móvil Android hecha con Flutter, Riverpod, go_router y Firebase (Firestore y Crashlytics).

## Qué incluye

- App Flutter mínima en `lib/`, con i18n (es y en), tema claro y oscuro y tokens de estilo.
- Dos flavors de Android: `dev` y `prod`, cada uno con su paquete y su proyecto de Firebase.
- `scripts/build.dart`: APK y AAB locales, firma de subida y copia a Drive.
- `scripts/check_styles.dart`: verifica que los estilos salgan de los tokens.
- `.github/`: CI, Dependabot y plantilla de PR.
- `docs/`: Gitflow, arquitectura, build y decisiones (ADR).

## Requisitos

- Flutter 3.50 o superior (incluye Dart 3.14), Java 17 o superior y el SDK de Android.
- Un proyecto de Firebase por flavor (opcional para empezar: sin él la app arranca sin Firebase).

## Empezar

```bash
flutter pub get
flutter run --flavor dev
```

Para activar Firebase, descarga el `google-services.json` de cada proyecto y guárdalo en `android/app/src/dev/` y `android/app/src/prod/`. No se versionan.

## Entornos

| | Desarrollo (`dev`) | Producción (`prod`) |
|---|---|---|
| Nombre | Nombra Dev | Nombra |
| Paquete de Android | `com.jujeme.nombra.dev` | `com.jujeme.nombra` |
| Proyecto de Firebase | el de `android/app/src/dev/` | el de `android/app/src/prod/` |
| Firma | debug | llave de subida |

## Scripts

| Comando | Qué hace |
|---|---|
| `dart run scripts/build.dart [--flavor dev\|prod] [--aab] [--upload]` | Compila APK o AAB en `builds/` |
| `flutter analyze` · `flutter test` | Verificaciones antes de commitear |
| `dart run scripts/check_styles.dart` | Revisa los tokens de estilo |
| `flutter gen-l10n` | Regenera los textos tras editar `lib/l10n/*.arb` |

## Estructura

```
lib/app/       NombraApp y rutas (go_router)
lib/core/      entorno, arranque, tokens y tema
lib/features/  una carpeta por funcionalidad
lib/l10n/      textos (es y en)
android/       flavors, firma y plugins de Firebase
scripts/       build.dart y check_styles.dart
docs/          gitflow, arquitectura, build y decisiones
```

## Documentación

- [`STANDARD.md`](STANDARD.md): estándar del proyecto.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) · [`docs/BUILD.md`](docs/BUILD.md) · [`docs/GITFLOW.md`](docs/GITFLOW.md)
- [`CLAUDE.md`](CLAUDE.md) y [`AGENTS.md`](AGENTS.md): instrucciones para agentes de IA.
