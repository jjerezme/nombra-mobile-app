# <Nombre de la app>

<!-- Qué es, plataforma y stack en una frase. Ejemplo: App móvil (Android) para ... Construida con Expo, React Native y Firebase (SDK nativo). -->

## Qué incluye

<!-- 5 a 8 viñetas de una línea. El detalle va en docs/ARCHITECTURE.md. -->
- ...

## Requisitos

- Node.js 20 o superior, Java 17 y el SDK de Android.
- Hace falta un build nativo (dev client o APK): Firebase usa los SDK nativos y no funciona en Expo Go.

## Empezar

```bash
npm install
cp .env.example .env      # completa las variables
# coloca firebase/dev/google-services.json (y firebase/prod/ para producción); no se versionan
npm run apk -- --prebuild   # primer build (genera android/)
```

Detalles de builds, firma y Metro: [`docs/BUILD.md`](docs/BUILD.md).

## Entornos

| | Desarrollo (debug y preview) | Producción |
|---|---|---|
| Paquete de Android | `<com.jujeme.x.dev>` | `<com.jujeme.x>` |
| Proyecto de Firebase | `<proyecto-dev>` | `<proyecto-prod>` |
| `APP_VARIANT` | `development` / `preview` | `production` |

## Scripts

| Comando | Qué hace |
|---|---|
| `npm run apk` / `apk:preview` / `apk:production` | Compila el APK de cada variante y lo copia a Drive |
| `npm run aab` | App Bundle para Google Play |
| `npm run typecheck` · `lint` · `test` · `check:styles` | Verificaciones antes de commitear |

## Estructura

```
src/app/       rutas (Expo Router)
src/           componentes, lib/, context/, i18n/ (según el proyecto)
firebase/      google-services.json por entorno (ignorados)
docs/          arquitectura, decisiones, builds, gitflow
scripts/       utilidades (check-styles, ...)
```

## Documentación

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): arquitectura, modelo de datos y stack.
- [`docs/decisions/`](docs/decisions/): decisiones técnicas por tema (ADR).
- [`docs/BUILD.md`](docs/BUILD.md): compilación, firma y subida a Drive.
- [`docs/GITFLOW.md`](docs/GITFLOW.md): ramas, releases y commits.
- [`CLAUDE.md`](CLAUDE.md) y [`AGENTS.md`](AGENTS.md): instrucciones para agentes de IA.
- [`TODO.md`](TODO.md): pendientes para más tarde.
