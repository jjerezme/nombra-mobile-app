# Nombra

App móvil Android para descargar un archivo y renombrarlo según reglas configurables. También aparece al compartir un archivo o un enlace desde otra app. Hecha con Flutter, Riverpod, go_router y Firebase (Auth, Firestore, Crashlytics y App Check).

## Qué incluye

- Descarga desde una URL en segundo plano, con progreso y reintentos.
- Reglas de renombrado: patrón con elementos (`{name}`, `{date}`, `{time}`, `{n:3}`, `{domain}`, `{type}`), mayúsculas, espacios, limpieza de nombre, carpeta de destino y qué hacer si el archivo existe.
- Modo rápido (prefijo y sufijo) y carpeta de destino en Download, Documents, Pictures, Movies o Music.
- Hoja "Guardar con Nombra" al compartir un archivo o un enlace desde otra app.
- Cuenta de Google opcional con respaldo de las reglas; se puede eliminar desde la app.
- i18n (es y en), tema claro y oscuro y tokens de estilo.
- Modo desarrollador en la versión de desarrollo.
- Dos flavors de Android: `dev` y `prod`, cada uno con su paquete y su proyecto de Firebase.
- `scripts/build.dart`: APK y AAB locales, firma de subida y copia a Drive.
- `scripts/check_styles.dart`: verifica que los estilos salgan de los tokens.
- `.github/`: CI, Dependabot y plantilla de PR.
- `docs/`: Gitflow, arquitectura, build y decisiones (ADR).

## Requisitos

- Flutter 3.50 o superior (incluye Dart 3.14), Java 17 o superior y el SDK de Android.
- Un teléfono con Android 10 o superior (`minSdk` 29).
- Un proyecto de Firebase por flavor (opcional para empezar: sin él la app arranca sin Firebase).

## Empezar

```bash
flutter pub get
flutter run --flavor dev
```

Para activar Firebase, descarga el `google-services.json` de cada proyecto y guárdalo en `android/app/src/dev/` y `android/app/src/prod/`. No se versionan.

Para iniciar sesión con Google (Ajustes › Cuenta) cada proyecto de Firebase necesita, además: el proveedor Google activo en Authentication, las huellas SHA-1 de la app (la de debug y la de la llave de subida) registradas en su app de Android, y las reglas de `firestore.rules` desplegadas (`firebase deploy --only firestore:rules --project dev`). Descarga el `google-services.json` después de registrar las huellas.

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
| `flutter analyze` · `flutter test` | Verificaciones antes de commitear (63 tests) |
| `dart run scripts/check_styles.dart` | Revisa los tokens de estilo |
| `flutter gen-l10n` | Regenera los textos tras editar `lib/l10n/*.arb` |
| `dart run scripts/export_legal.dart` · `npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.3.0 build-web` | Genera el sitio en `web/public/` |

## Estructura

```
lib/app/       NombraApp y rutas (go_router)
lib/core/      entorno, arranque, tokens y tema
lib/features/  rules, download, share, naming, account, legal, developer y settings
lib/l10n/      textos (es y en)
android/       flavors, firma, Firebase y ShareActivity (compartir)
scripts/       build.dart, check_styles.dart y export_legal.dart
web/ · store/  sitio público y ficha de Google Play
docs/          gitflow, arquitectura, build y decisiones
```

## Documentación

- [`STANDARD.md`](STANDARD.md): estándar del proyecto.
- [`CHANGELOG.md`](CHANGELOG.md): cambios por versión publicada.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) · [`docs/BUILD.md`](docs/BUILD.md) · [`docs/GITFLOW.md`](docs/GITFLOW.md)
- [`CLAUDE.md`](CLAUDE.md) y [`AGENTS.md`](AGENTS.md): instrucciones para agentes de IA.

## Sitio web
Landing, privacidad, términos y eliminación de la cuenta, en inglés y español. El texto legal es el de la app (`lib/features/legal/domain/`); lo demás está en `web/content/`. Necesita Node:

```bash
dart run scripts/export_legal.dart
npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.3.0 build-web
firebase deploy --only hosting --project nombra-prod
```

Queda en `https://nombra-prod.web.app` (`/privacy`, `/terms`, `/delete-account`; en español con `?lang=es`).
