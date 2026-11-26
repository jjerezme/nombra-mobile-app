# <Nombre de la app>

<!-- Qué es, plataforma y stack en una frase. Ejemplo: App móvil (Android) para ... Construida con Flutter, Riverpod y Firebase. -->

## Qué incluye

<!-- 5 a 8 viñetas de una línea. El detalle va en docs/ARCHITECTURE.md. -->
- ...

## Requisitos

- Flutter 3.50 o superior, Java 17 y el SDK de Android.

## Empezar

```bash
flutter pub get
# coloca android/app/src/dev/google-services.json (y src/prod/ para producción); no se versionan
flutter run --flavor dev
```

Detalles de builds y firma: [`docs/BUILD.md`](docs/BUILD.md).

## Entornos

| | Desarrollo (`dev`) | Producción (`prod`) |
|---|---|---|
| Paquete de Android | `<com.jujeme.x.dev>` | `<com.jujeme.x>` |
| Proyecto de Firebase | `<proyecto-dev>` | `<proyecto-prod>` |
| Firma | debug | llave de subida |

## Scripts

| Comando | Qué hace |
|---|---|
| `npx … build-apk [--preview] [--upload]` | Compila APK o AAB y lo copia a Drive |
| `flutter analyze` · `flutter test` | Verificaciones antes de commitear |
| `dart run scripts/check_styles.dart` | Revisa los tokens de estilo |

## Estructura

```
lib/app/       app y rutas (go_router)
lib/           core/, features/, l10n/
android/       flavors, firma y Firebase (google-services.json ignorados)
docs/          arquitectura, decisiones, builds, gitflow
scripts/       check_styles.dart
```

## Documentación

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): arquitectura, modelo de datos y stack.
- [`docs/decisions/`](docs/decisions/): decisiones técnicas por tema (ADR).
- [`docs/BUILD.md`](docs/BUILD.md): compilación, firma y subida a Drive.
- [`docs/GITFLOW.md`](docs/GITFLOW.md): ramas, releases y commits.
- [`CLAUDE.md`](CLAUDE.md) y [`AGENTS.md`](AGENTS.md): instrucciones para agentes de IA.
- [`TODO.md`](TODO.md): pendientes para más tarde.
