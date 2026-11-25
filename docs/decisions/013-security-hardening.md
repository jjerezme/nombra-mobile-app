# 013. Endurecimiento de seguridad

- Estado: aceptada
- Fecha: 2026-11-25

## Contexto
Una revisión del manifiesto, de `ShareActivity`, del guardado de archivos y del arranque encontró varios puntos: el historial (con URLs que pueden llevar tokens) entraba en las copias de seguridad de Android, un release de producción podía firmarse con la llave de debug, un nombre como `..` podía llegar al guardado, los errores enviados a Crashlytics podían incluir enlaces completos y las URLs `http` se aceptaban aunque Android las bloquea.

## Decisión
- `android:allowBackup="false"`: los datos de la app no entran en las copias de Android. Lo que se quiere respaldar (las reglas) va a la cuenta del usuario, ver [014](014-account-and-backup.md).
- Un release `prod` (apk o bundle) falla si falta la llave de subida; el release `dev` puede seguir con la llave de debug para previews.
- `ShareActivity` limpia los nombres (sin separadores, vacíos ni solo puntos), limita el tamaño de cada copia (2 GB) y el número de archivos (50), y borra la carpeta de la copia al terminar, se haya guardado o no.
- `safeFileName` (Dart) es la última defensa de nombres: nunca devuelve un nombre vacío ni formado solo por puntos. Lo usan `buildFileName` y `FileFinalizer`.
- Solo se aceptan enlaces `https`. Un enlace `http` se rechaza con un mensaje propio, tanto en Inicio como en la hoja de compartir.
- Los errores que van a Crashlytics pasan por `RedactedError`, que reemplaza todo enlace por `<url>`.

## Consecuencias
- Reinstalar o cambiar de teléfono no recupera el historial ni los ajustes; solo las reglas, con la cuenta.
- Para compilar `prod` hace falta la llave de subida configurada (ver `docs/BUILD.md`).
- Un archivo compartido de más de 2 GB no se copia; no hay aviso al usuario, solo desaparece de la lista.
- Sin minificación (R8) todavía: se evaluará con un build de release.
