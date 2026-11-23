# CLAUDE.md

@AGENTS.md

## Resumen
Nombra: app móvil Android hecha con Flutter, Riverpod, go_router y Firebase (Firestore y Crashlytics). Parte de la plantilla `mobile-base`.

## Comandos de verificación
```bash
flutter analyze
flutter test
dart run scripts/check_styles.dart
```
Ejecuta analyze y test antes de dar una tarea por terminada.

## Reglas de proceso y comunicación

- **Ante cualquier duda, pregunta y espera confirmación antes de decidir e implementar.** Tiene prioridad sobre "avanzar sin preguntar". Pregunta breve, con alternativas y la recomendada marcada; incluye las elecciones técnicas (librerías, nombres, arquitectura), no solo las ambigüedades del pedido.
- **Toda decisión técnica o de diseño va en su ADR** (`docs/decisions/NNN-titulo.md`), en el mismo cambio. Si restringe código futuro, agrega además una línea en "Reglas vigentes". Si una decisión cambia, edita su entrada: no agregues una que la contradiga. Antes de tocar un tema, lee su ADR.
- Si cambia lo que hace la app, actualiza `docs/ARCHITECTURE.md`; si cambia cómo se instala o se usa, el `README.md`.
- CLAUDE.md no es un diario ni duplica el README. Menos de 200 líneas.
- `TODO.md` guarda los pendientes pospuestos; al terminar uno, muévelo a "Hecho".
- Commits pequeños (uno por cambio lógico), en inglés, Conventional Commits, terminando con `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Ramas `feature/*` desde `develop` (ver `docs/GITFLOW.md`; la rama de producción es `master`).
- **No hagas `git push`, PR, fusión a `master`, despliegues (reglas, Hosting) ni subidas a tiendas sin que el usuario lo pida.** Compila solo cuando se pida; cada compilación se copia también a Drive (`--upload`).
- **Secretos fuera del chat y del repo.** Nunca escribas ni pidas contraseñas, frases de paso ni claves. `google-services*.json`, `.env`, llaves y keystores no se versionan.
- Interfaz y documentación en español neutro (tuteo, sin voseo); identificadores, comentarios nuevos y commits en inglés. Toda cadena visible va en `lib/l10n/` (es y en, con las mismas claves).
- **Ningún archivo pasa de 500 líneas**; si se acerca a 400, pártelo. **Función pura nueva = test.**
- Si una pantalla cambió, pruébala en un dispositivo real, en tema claro y oscuro y en todos los idiomas.

## Convenciones

- **Estilos** (detalle en `STANDARD.md`): tamaños, espacios, radios e iconos solo de `core/constants/tokens.dart` (`AppSpacing`, `AppRadius`, `AppIconSize`, `AppFontSize`); colores solo de `Theme.of(context).colorScheme`. `dart run scripts/check_styles.dart` lo verifica; excepción deliberada: `// style-ok` al final de la línea. Si ningún token calza, piensa si falta uno.
- **Nombres:** archivos `snake_case.dart`; clases `PascalCase`; pantallas `XScreen`, widgets reutilizables `XWidget` solo si hace falta distinguirlos; providers `xProvider`; booleanos `isX`/`hasX`; constantes `lowerCamelCase` (estilo Dart).
- **Widgets:** revisa `lib/core/widgets/` antes de crear uno; si ninguno sirve, pregunta antes de crear uno nuevo. Un widget público por archivo. Los widgets no acceden a Firestore: usan providers/repositorios. Toda lista cubre carga, error con "Reintentar" y vacío.
- Un botón solo con icono lleva `tooltip`/`Semantics`; áreas táctiles de 48 dp (`minTouchTarget`).
- Estándar completo: `STANDARD.md`. Builds: `dart run scripts/build.dart` (ver `docs/BUILD.md`).

## Mapa de arquitectura
- `lib/main.dart`: arranque (Firebase + `ProviderScope`). `lib/app/`: `NombraApp` y rutas.
- `lib/core/`: `environment.dart` (flavors dev/prod), `bootstrap.dart`, `constants/tokens.dart`, `theme/`.
- `lib/features/<feature>/`: pantallas, providers y repositorios de cada funcionalidad.
- `lib/l10n/`: `.arb` (es, en). `android/`: flavors, firma y plugins de Firebase. Detalle en `docs/ARCHITECTURE.md`.

## Reglas vigentes
- Flutter como plataforma: [001](docs/decisions/001-flutter.md). Estado con Riverpod: [002](docs/decisions/002-riverpod.md). Rutas con go_router: [003](docs/decisions/003-go-router.md).
- Flavors `dev`/`prod`, Firebase nativo, una config por flavor: [004](docs/decisions/004-flavors-firebase.md).
- Textos con `gen-l10n` (es y en): [005](docs/decisions/005-l10n.md). Builds locales con `scripts/build.dart`: [006](docs/decisions/006-local-build.md).

## Qué no hacer

- No uses CLAUDE.md como diario ni dupliques el README.
- No agregues el SDK web de Firebase ni plugins de Firebase fuera de `firebase_core`, `cloud_firestore` y `firebase_crashlytics` sin preguntar.
- No versiones `google-services*.json`, `.env`, keystores ni llaves.
- No dejes reglas de Firestore con escritura libre.
- No pongas números de estilo, colores ni textos sueltos en las pantallas.
- No hagas push, PR, fusión a `master` ni despliegues sin que el usuario lo pida.
