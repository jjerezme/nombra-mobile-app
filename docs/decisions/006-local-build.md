# 006. Builds locales con build-apk

- Estado: aceptada
- Fecha: 2026-11-23 (actualizada el 2026-11-26)

## Contexto
Los builds son locales (Windows), sin servicios alojados. Hubo un script propio (`scripts/build.dart`) mientras `build-apk` no sabía compilar Flutter; desde `mobile-tools` 0.2.0 sí sabe.

## Decisión
Se compila con `build-apk` de `mobile-tools`, ejecutado con `npx` y fijado por etiqueta (v0.4.0), configurado en `build.config.json`. Envuelve `flutter build` con los flavors, firma producción con la llave de subida (archivo fuera del repo), nombra los archivos en `builds/` y con `--upload` los copia a Drive, donde solo deja el último de cada tipo. `scripts/build.dart` se eliminó.

## Consecuencias
Hace falta Node para compilar. `prod` en App Bundle no se compila sin la llave de subida. Subir de versión del script es cambiar la etiqueta en los documentos.
