# Arquitectura

Nombra descarga un archivo (desde una URL o compartido desde otra app), le pone el nombre que dicta una regla y lo guarda en una carpeta pública del teléfono.

## Arranque
`main.dart` tiene dos puntos de entrada, los dos con Firebase (`core/bootstrap.dart`), `SharedPreferences` y un `ProviderScope`:
- `main()`: la app (`NombraApp`, con go_router y navegación inferior Descargar / Reglas).
- `shareMain()`: la hoja "Guardar con Nombra" que muestra `ShareActivity` al compartir (`ShareApp`). Corre en su propio motor de Flutter.

Si falta el `google-services.json` del flavor, el arranque sigue sin Firebase y deja el motivo en el log.

## Funcionalidades (`lib/features/`)
- `rules/`: modelo de regla (`RenameRule`: patrón de elementos, transformaciones, carpeta opcional, conflicto), lógica pura de nombres (`filename_builder.dart`, `name_resolver.dart`), pantalla de reglas (lista ordenada por nombre) y editor.
- `settings/`: lo último que eligió el usuario (modo Guardada/Rápida, regla, prefijo, sufijo, carpeta).
- `naming/`: widgets que comparten Inicio y la hoja de compartir: `RuleSelector`, `DestinationCard`, selector de carpeta.
- `download/`: Inicio (URL, vista previa del nombre, recientes), `DownloadsNotifier` (cola, progreso, historial; la persistencia está en `DownloadsRepository`; abrir el archivo guardado y quitarlo de la lista), `DownloadEngine` (plugin `background_downloader`) y `FileFinalizer` (renombra y mueve a MediaStore).
- `share/`: `ShareChannel` (canal con Kotlin), `ShareSheetScreen` y su carga útil (`SharePayload`).

## Flujo de una descarga
1. Inicio o la hoja de compartir arman un `DownloadPlan`: URL (o archivo local), copia de la regla y carpeta de destino.
2. `DownloadsNotifier.start` crea el elemento del historial y encola la tarea (carpeta temporal, nombre sugerido por el servidor).
3. Al completar, calcula el nombre final con el nombre real del archivo (`DownloadPlan.nameFor`; el contador `{n:3}` avanza solo aquí) y `FileFinalizer.save` lo mueve a `<raíz>/<subcarpeta>` resolviendo conflictos.
4. Para un archivo compartido se salta la descarga: `saveLocalFile` aplica el mismo paso 3.

## Android
- `ShareActivity.kt`: recibe `SEND` / `SEND_MULTIPLE`, copia los archivos al caché y responde al canal `com.jujeme.nombra/share`.
- Flavors `dev` / `prod`, firma y plugins de Firebase en `android/app/build.gradle.kts`. `minSdk` 29.

## Datos
`shared_preferences` con JSON (reglas, ajustes, historial). Firestore está disponible pero aún no se usa. Detalle en los ADR 007 a 010.

## Entornos
`dev` y `prod` (ver ADR 004). `AppEnvironment.current` resuelve el entorno a partir de `appFlavor`.
