# Estándar del proyecto

Reglas técnicas, de documentación y de publicación de Nombra, hecha en Flutter (ver [ADR 001](docs/decisions/001-flutter.md)).

## Decisiones tomadas
| Tema | Decisión |
|---|---|
| Rama de producción | `master` |
| Lenguaje | Dart (Flutter 3.50), solo Android |
| Estado / rutas | Riverpod / go_router |
| Firebase | Plugins nativos de FlutterFire (`firebase_core`, `cloud_firestore`, `firebase_crashlytics`, `firebase_auth`, `firebase_app_check`) |
| Entornos | Flavors `dev` y `prod` |
| Commits | Conventional Commits en inglés + `Co-Authored-By` |

## Estructura
`lib/app` (app y rutas) · `lib/core` (entorno, arranque, tokens, tema, widgets comunes) · `lib/features/<feature>` · `lib/l10n`. Los tests reflejan la estructura de `lib/` dentro de `test/`.

## Nombres
- Archivos `snake_case.dart`; clases y enums `PascalCase`; miembros y constantes `lowerCamelCase` (estilo Dart); providers `xProvider`.
- Pantallas `XScreen`; booleanos `isX` / `hasX`; manejadores `_handleX`.
- Claves de i18n en `camelCase` con el nombre de la pantalla como prefijo; campos y colecciones de Firestore en inglés y `camelCase`.

## Estilos
- Un solo archivo de tokens, `core/constants/tokens.dart`, con `AppSpacing`, `AppRadius`, `AppIconSize`, `AppFontSize` y `minTouchTarget`.
- Ningún número de tamaño, espacio, radio o fuente fuera de esos tokens. Los colores salen solo de `Theme.of(context).colorScheme`; los hex viven solo en `core/theme/`.
- `dart run scripts/check_styles.dart` falla si algo se sale de los tokens (revisa `lib/app` y `lib/features`). Una excepción deliberada lleva `// style-ok` al final de la línea.
- Si ningún token calza, piensa si falta un token antes de escribir el número.

## Widgets
- Un widget público por archivo. Una pantalla grande se parte en `features/<feature>/widgets/`.
- Antes de crear un widget común revisa `core/widgets/`; si ninguno sirve, pregunta antes de crear uno nuevo.
- Los widgets no acceden a Firestore: usan providers y repositorios.
- Toda lista cubre carga, error con "Reintentar" y vacío.
- Accesibilidad: botones solo con icono con `tooltip` o `Semantics`; áreas táctiles de al menos 48 dp; el estado no depende solo del color.

## Comandos obligatorios
`flutter analyze`, `flutter test`, `dart run scripts/check_styles.dart`, `dart run scripts/build.dart`.

## Entornos y Firebase
- 2 proyectos Firebase: dev y prod.
- `android/app/src/{dev,prod}/google-services.json` en `.gitignore`.
- El flavor decide el entorno (`AppEnvironment`); sin flavor es desarrollo.

## Seguridad
- Reglas Firestore: deny-all por defecto, validación por colección, test con emulador.
- App Check, Crashlytics, analytics sin datos personales.
- Eliminar cuenta borra todos los datos del usuario.

## Política y términos dentro de la app
Se leen sin conexión desde Ajustes › Legal (dos filas), con el mismo texto que la web.

## Modo desarrollador
Solo en el flavor `dev`: en `prod` no existe. Herramientas comunes (copiar informe, error de prueba, con aviso flotante) e información en este orden: app · teléfono · pantalla · idioma y región · red · batería · almacenamiento · Firebase · cuenta y datos · notificaciones · dependencias.

## Sitio web
Landing, `/privacy`, `/terms` y `/delete-account` en inglés (por defecto) y español, generadas con el comando `build-web` de `mobile-tools`. Sin `playUrl` la landing dice «Próximamente».

## Fichas de Google Play (`store/`)
`listing/<idioma>.md` (`en-US` y `es-419`), `graphics/icon-512.png`, `graphics/feature-graphic-<idioma>.png` y `screenshots/<idioma>/`. Límites: título 30, corta 80, completa 4000, novedades 500.

## Calidad
- Función pura nueva = test. Ningún archivo supera 500 líneas.
- CI por PR: analyze, test, check_styles.
- Dependabot activo (`.github/dependabot.yml`: semanal contra `develop`, menores y parches agrupados, mayores a mano) y alertas y actualizaciones de seguridad activas en GitHub.

## Git
Gitflow: `feature/*` y `bugfix/*` → `develop`; `release/*` y `hotfix/*` → `master`. Ver `docs/GITFLOW.md`.

## Documentación
- `README.md` (<120 líneas), `CLAUDE.md` (<200 líneas) y `CHANGELOG.md` (Keep a Changelog: «Sin publicar» sin versión mientras los cambios entran a `develop`).
- **Formato del `CHANGELOG.md`**: título `# Changelog`; `## [Sin publicar]` y `## [X.Y.Z] - versionCode N (AAAA-MM-DD)`, sin enlaces; secciones en este orden: Agregado, Cambiado, Corregido, Eliminado, Actualizado, Seguridad y, si hace falta, Versiones internas (una línea por `versionCode` que no se tituló).
- `docs/`: `GITFLOW.md`, `ARCHITECTURE.md`, `BUILD.md`, `decisions/NNN-titulo.md`.
- Toda decisión técnica va en un ADR; si restringe código futuro, una línea en "Reglas vigentes" de `CLAUDE.md`.
- Español neutro (tuteo) en docs e i18n.
