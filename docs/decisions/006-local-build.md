# 006. Builds locales con scripts/build.dart

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Los builds son locales (Windows), sin servicios alojados. Antes los hacía `build-apk` de `@jujeme/mobile-tools` (Node), que ya no aplica.

## Decisión
`dart run scripts/build.dart [--flavor dev|prod] [--aab] [--upload]` envuelve `flutter build apk|appbundle --release --flavor <f>`, firma el flavor `prod` con la llave de subida (archivo de propiedades fuera del repo, pasado a Gradle por variables `ORG_GRADLE_PROJECT_*`), nombra el archivo `<prefijo>-<flavor>-v<versión>-<código>-<fecha>` en `builds/` y con `--upload` lo copia a Drive. Se configura en `build.config.json`.

## Consecuencias
`prod` no se compila sin la llave de subida. El flavor `dev` usa la firma de debug.
