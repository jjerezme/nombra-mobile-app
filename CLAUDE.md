# CLAUDE.md

@AGENTS.md

## Resumen
Nombra: app móvil Android hecha con Flutter, Riverpod, go_router y Firebase (Firestore, Auth con Google, Crashlytics y App Check). Parte de la plantilla `mobile-base`.

## Comandos de verificación
```bash
flutter analyze
flutter test
dart run scripts/check_styles.dart
dart run scripts/export_legal.dart && npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.3.0 build-web   # solo si cambian los textos legales o web/
```
Ejecuta analyze y test antes de dar una tarea por terminada.

## Reglas de proceso y comunicación

- **Ante cualquier duda, pregunta y espera confirmación antes de decidir e implementar.** Tiene prioridad sobre "avanzar sin preguntar". Pregunta breve, con alternativas y la recomendada marcada; incluye las elecciones técnicas (librerías, nombres, arquitectura), no solo las ambigüedades del pedido.
- **Toda decisión técnica o de diseño va en su ADR** (`docs/decisions/NNN-titulo.md`), en el mismo cambio. Si restringe código futuro, agrega además una línea en "Reglas vigentes". Si una decisión cambia, edita su entrada: no agregues una que la contradiga. Antes de tocar un tema, lee su ADR.
- Si cambia lo que hace la app, actualiza `docs/ARCHITECTURE.md`; si cambia cómo se instala o se usa, el `README.md`.
- CLAUDE.md no es un diario ni duplica el README. Menos de 200 líneas.
- `TODO.md` guarda los pendientes pospuestos; al terminar uno, muévelo a "Hecho".
- `CHANGELOG.md` (Keep a Changelog): cada cambio que llega a `develop` y que ve el usuario se anota en «Sin publicar», **sin número de versión** (varias ramas pueden entrar a `develop` antes de una release). La `version` y el `versionCode` se asignan solo en la rama `release/*`, donde «Sin publicar» pasa a `## [X.Y.Z] - versionCode N (fecha)` y queda vacío; esa rama se fusiona a `master` y de vuelta a `develop`.
- La ficha de Play vive en `store/`: al subir `versionCode`, agrega las novedades en cada `store/listing/<idioma>.md`; si cambia lo que hace la app, actualiza la descripción en todos los idiomas.
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
- `lib/main.dart`: arranque (`main` y `shareMain`, la hoja de compartir). `lib/app/`: `NombraApp`, rutas y navegación.
- `lib/core/`: `environment.dart` (flavors), `bootstrap.dart`, `constants/tokens.dart`, `theme/`, `widgets/` comunes.
- `lib/features/`: `rules/` (reglas, editor), `download/` (inicio, descargas, guardado), `share/` (hoja de compartir), `naming/` (selector de regla y carpeta compartido), `account/` (cuenta de Google y respaldo de reglas), `legal/` (términos y privacidad), `developer/` (modo desarrollador, solo `dev`), `settings/`.
- `web/` sitio público (generado en `web/public/`, no se edita a mano) y `store/` ficha de Play.
- `lib/l10n/`: `.arb` (es, en). `android/`: flavors, firma, Firebase y `ShareActivity`. Detalle en `docs/ARCHITECTURE.md`.

## Reglas vigentes
- Flutter como plataforma: [001](docs/decisions/001-flutter.md). Estado con Riverpod: [002](docs/decisions/002-riverpod.md). Rutas con go_router: [003](docs/decisions/003-go-router.md).
- Flavors `dev`/`prod`, Firebase nativo, una config por flavor: [004](docs/decisions/004-flavors-firebase.md).
- Textos con `gen-l10n` (es y en): [005](docs/decisions/005-l10n.md). Builds locales con `scripts/build.dart`: [006](docs/decisions/006-local-build.md).
- Datos en `shared_preferences` (JSON): [007](docs/decisions/007-persistence.md). Descarga con `background_downloader` y guardado por MediaStore, `minSdk` 29: [008](docs/decisions/008-download-and-save.md).
- Compartir con `ShareActivity` translúcida y `shareMain`: [009](docs/decisions/009-share-intent.md). Fuentes empaquetadas, sin `google_fonts`: [010](docs/decisions/010-fonts.md). Icono y logo: [012](docs/decisions/012-app-icon.md).
- Seguridad: solo enlaces `https`, nombres con `safeFileName`, errores sin enlaces (`RedactedError`), sin copias de Android, release `prod` solo con llave de subida: [013](docs/decisions/013-security-hardening.md).
- Cuenta de Google y respaldo automático de las reglas en Firestore (`users/{uid}`, `firestore.rules`): [014](docs/decisions/014-account-and-backup.md).
- Material 3 primero: componente estándar con el estilo en el tema; los de `core/widgets/` son envoltorios finos: [015](docs/decisions/015-material-3-first.md).
- Términos y política de privacidad: un solo texto en `lib/features/legal/domain/` para la app y la web (`scripts/export_legal.dart` y el comando `build-web` de `mobile-tools` → `web/public/`): [016](docs/decisions/016-legal-texts.md).
- App Check; modo desarrollador solo en `dev`, con las secciones comunes; la cuenta se elimina desde la app: [017](docs/decisions/017-developer-mode-and-account-deletion.md).

## Qué no hacer

- No uses CLAUDE.md como diario ni dupliques el README.
- No agregues el SDK web de Firebase ni plugins de Firebase fuera de `firebase_core`, `cloud_firestore`, `firebase_crashlytics`, `firebase_app_check` y `firebase_auth` (con `google_sign_in`) sin preguntar.
- No versiones `google-services*.json`, `.env`, keystores ni llaves.
- No dejes reglas de Firestore con escritura libre.
- No pongas números de estilo, colores ni textos sueltos en las pantallas.
- No hagas push, PR, fusión a `master` ni despliegues sin que el usuario lo pida.
