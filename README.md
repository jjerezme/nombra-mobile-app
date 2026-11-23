# Nombra

Plantilla y estándar de las apps móviles propias (Android, Expo + React Native + Firebase con SDK nativo). Cada proyecto nuevo parte de aquí.

## Qué incluye

- `STANDARD.md`: estándar técnico y de documentación (incluye el formato del README).
- `CLAUDE.md` y `AGENTS.md`: instrucciones para agentes de IA (esqueleto fijo).
- App Expo mínima en `src/`, con i18n, tokens de estilo y `check:styles`.
- `.github/`: CI, Dependabot y plantilla de PR.
- `build.config.json`: configura el `build-apk` compartido (`@jujeme/mobile-tools`).
- `docs/`: `GITFLOW.md`, `README.template.md` y la carpeta de ADR.

## Requisitos

- Node.js 20 o superior, Java 17 y el SDK de Android.
- Hace falta un build nativo (dev client o APK): Firebase usa los SDK nativos y no funciona en Expo Go.

## Empezar

Copia estos archivos a un proyecto nuevo y completa los marcadores `<!-- -->`; luego:

```bash
npm install
npm run apk -- --prebuild   # primer build (genera android/)
```

## Entornos

| | Desarrollo (debug y preview) | Producción |
|---|---|---|
| Paquete de Android | `com.jujeme.nombra.dev` | `com.jujeme.nombra` |
| Proyecto de Firebase | el que pongas en `firebase/dev/` | el que pongas en `firebase/prod/` |
| `APP_VARIANT` | `development` / `preview` | `production` |

Los valores reales están en `src/constants/environments.json`; ajústalos al crear el proyecto.

## Scripts

| Comando | Qué hace |
|---|---|
| `npm run apk` / `apk:preview` / `apk:production` | Compila el APK de cada variante |
| `npm run aab` | App Bundle para Google Play |
| `npm run typecheck` · `lint` · `test` · `check:styles` | Verificaciones antes de commitear |

## Estructura

```
src/app/       rutas (Expo Router)
src/           components/, constants/, hooks/, i18n/, lib/
scripts/       check-styles.mjs
docs/          gitflow, plantilla de README y decisiones
.github/       CI, Dependabot y plantilla de PR
```

## Documentación

- [`STANDARD.md`](STANDARD.md): estándar completo.
- [`docs/README.template.md`](docs/README.template.md): plantilla del README de cada proyecto.
- [`docs/GITFLOW.md`](docs/GITFLOW.md): ramas, releases y commits.
- [`CLAUDE.md`](CLAUDE.md) y [`AGENTS.md`](AGENTS.md): instrucciones para agentes de IA.
