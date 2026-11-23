# 008. Descarga con background_downloader y guardado en carpetas públicas

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Se descarga un archivo, se le pone el nombre que dicta la regla y se guarda en una carpeta pública del teléfono (`/Download/Nombra`, `/Documents/Facturas`, ...) sin pedir permisos de almacenamiento.

## Decisión
- Descarga: `background_downloader` (segundo plano, notificación de progreso, reintentos). Cada tarea se baja a la carpeta temporal con el nombre sugerido por el servidor; `DownloadEngine` aísla el plugin.
- Guardado: `FileDownloader.moveFileToSharedStorage` (MediaStore). Las raíces son `Download`, `Documents` (`SharedStorage.files`), `Pictures` (`images`), `Movies` (`video`) y `Music` (`audio`), más una subcarpeta. Android solo admite imágenes en Pictures, videos en Movies y audio en Music: otro tipo va a `Download` con la misma subcarpeta y el historial lo avisa.
- El nombre final se calcula al terminar la descarga, con el nombre real del archivo (`FileFinalizer`): se renombra en una carpeta temporal propia y se mueve. Conflictos: añadir `(1)`, reemplazar (solo si la app puede borrar el archivo anterior, si no numera) o preguntar (`ConflictPrompt`).
- `minSdk` 29: en Android 10+ MediaStore no necesita permisos.
- Permiso de notificaciones (Android 13+) se pide al primer intento de descarga; sin él se descarga igual, sin aviso.

## Consecuencias
- **Limitación conocida:** mover el archivo a su carpeta final es código Dart y necesita un isolate vivo (la app o la hoja de compartir). Si el usuario cierra Nombra antes de que termine una descarga, el archivo queda en la carpeta temporal y se guarda la próxima vez que abra la app (el historial lo restaura con `trackTasks`). El plugin no permite usar MediaStore desde su callback en segundo plano.
- La hoja de compartir mantiene la progresión visible hasta que se guarda (ADR 009).
- Se probó con tests y un `DownloadEngine`/`SharedStorageGateway` falsos; falta probar en un dispositivo real.
