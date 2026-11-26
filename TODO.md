# Pendientes

## Por hacer
- Responsable y ley aplicable en los términos y la política: se dejaron fuera a propósito ([016](docs/decisions/016-legal-texts.md)). Completar con el nombre y el país y agregar la cláusula de jurisdicción.
- App Check en la consola: registrar el token de depuración en `nombra-dev` y Play Integrity (SHA-256) en `nombra-prod`; activar la exigencia después de comprobar las métricas.
- Probar en un teléfono: eliminar la cuenta y el modo desarrollador (compilar `dev`).
- Ficha de Play: icono de 512 px (hoy solo hay 256 px), gráfico de funciones y capturas en `store/`; revisar los textos de `store/listing/` y poner `playUrl` en `web/site.config.json` al publicar.
- Pruebas de `firestore.rules` con el emulador (las otras apps ya las tienen).
- Que una persona con conocimiento legal revise los términos y la política antes de publicar en Google Play.
- Publicar la web en Hosting: `firebase deploy --only hosting --project nombra-prod` (cuando se pida).
- Publicar `firestore.rules` en `nombra-prod` (ya está en `nombra-dev`).
- Registrar en `nombra-prod` la huella SHA-1 de la llave de subida.
- Minificación (R8) del release: probar con un build.

## Hecho
