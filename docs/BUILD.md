# Builds

Todos los builds son locales. Requisitos: Flutter, Java 17 y el SDK de Android configurado (`flutter doctor`).

```bash
dart run scripts/build.dart                       # APK dev
dart run scripts/build.dart --flavor prod         # APK prod (firmado con la llave de subida)
dart run scripts/build.dart --flavor prod --aab   # App Bundle para Google Play
dart run scripts/build.dart --flavor prod --aab --upload   # y copia a Drive
```

El resultado queda en `builds/<prefijo>-<flavor>-v<versión>-<código>-<fecha>.apk|aab`. La versión sale de `version:` en `pubspec.yaml` (`x.y.z+código`).

## Configuración (`build.config.json`)
- `filePrefix`: prefijo de los archivos.
- `driveDir`: carpeta de Drive donde copia `--upload`.
- `uploadKeyPropertiesFile`: archivo fuera del repo con `storeFile`, `storePassword`, `keyAlias` y `keyPassword`. Solo lo lee el flavor `prod`; las claves pasan a Gradle por variables de entorno y nunca aparecen en la línea de comandos.

## Firebase
Cada flavor necesita su `google-services.json` en `android/app/src/<flavor>/` (no versionado). Sin él, el build funciona y la app arranca sin Firebase.
