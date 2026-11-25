# Pendientes

## Por hacer
- Responsable y ley aplicable en los términos y la política: se dejaron fuera a propósito ([016](docs/decisions/016-legal-texts.md)). Completar con el nombre y el país y agregar la cláusula de jurisdicción.
- Eliminar la cuenta desde la app (hoy «Borrar respaldo y cerrar sesión» deja el registro de Firebase Authentication; la política pide escribir al correo de contacto).
- Que una persona con conocimiento legal revise los términos y la política antes de publicar en Google Play.
- Publicar la web en Hosting: `firebase deploy --only hosting --project nombra-prod` (cuando se pida).
- Publicar `firestore.rules` en `nombra-prod` (ya está en `nombra-dev`).
- Registrar en `nombra-prod` la huella SHA-1 de la llave de subida.
- Minificación (R8) del release: probar con un build.

## Hecho
