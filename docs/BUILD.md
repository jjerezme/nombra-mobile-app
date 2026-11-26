# Builds

Todos los builds son locales, con el script compartido `build-apk` de [`mobile-tools`](https://github.com/jjerezme/mobile-tools). Requisitos: Flutter, Java 17, el SDK de Android configurado (`flutter doctor`) y Node (para ejecutar el script con `npx`).

```bash
npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.4.0 build-apk                      # debug (flavor dev)
npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.4.0 build-apk --preview            # release del flavor dev
npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.4.0 build-apk --production         # APK del flavor prod (firmado con la llave de subida)
npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.4.0 build-apk --aab --no-serve     # App Bundle para Google Play
npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.4.0 build-apk --preview --upload   # además lo copia a Drive
```

El resultado queda en `builds/<prefijo>-<tipo>-v<versión>-<código>-<fecha>-<hora>.apk|aab`. La versión sale de `version:` en `pubspec.yaml` (`x.y.z+código`). Sin `--no-serve`, los APK se ofrecen además por Wi-Fi para instalarlos desde el teléfono.

Con `--upload` el archivo se copia a `<apkDrive>/<name>/` y allí solo queda el último build de cada tipo (debug, preview, APK de producción y AAB); los anteriores del mismo tipo se borran (en Google Drive van a la papelera).

## Configuración (`build.config.json`)
- `name`: nombre de la carpeta en Drive.
- `filePrefix`: prefijo de los archivos.
- `apkDrive`: carpeta de Drive donde copia `--upload`.
- `tempDir`: carpeta temporal corta que usa Gradle en Windows.
- `signing.propertiesFile`: archivo fuera del repo con `storeFile`, `storePassword`, `keyAlias` y `keyPassword`. Solo se lee en producción; las claves pasan a Gradle por variables de entorno y nunca aparecen en la línea de comandos.

## Firebase
Cada flavor necesita su `google-services.json` en `android/app/src/<flavor>/` (no versionado). Sin él, el build funciona y la app arranca sin Firebase.
