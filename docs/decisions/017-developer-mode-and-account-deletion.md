# 017. Modo desarrollador, App Check y eliminación de la cuenta

- Estado: aceptada
- Fecha: 2026-11-26

## Contexto
Las demás apps de Jujeme comparten un modo desarrollador y App Check; Google Play exige poder eliminar la cuenta desde la app.

## Decisión
- **Modo desarrollador** (`lib/features/developer/`): solo en el flavor `dev` (en `prod` no hay fila en Ajustes ni ruta). Dos herramientas comunes (copiar informe y enviar un error de prueba, con aviso flotante) y las secciones de información en el mismo orden que en las otras apps; se omiten las que Nombra no tiene (Remote Config, plugins de Expo y módulos nativos). Las etiquetas técnicas van en inglés porque se pegan en reportes. Se agregan `device_info_plus`, `connectivity_plus` y `battery_plus` (autorizado por el usuario). La lista de dependencias se lee de `pubspec.yaml`, incluido como recurso.
- **App Check**: `firebase_app_check` (autorizado), Play Integrity en `prod` y proveedor de depuración en `dev`. Si falla al activarse, la app sigue.
- **Eliminar cuenta**: Ajustes › Cuenta. Pide elegir de nuevo la cuenta de Google (Firebase lo exige), borra `users/{uid}` y después el usuario de Authentication. Cancelar el selector no borra nada. Las reglas del teléfono se quedan. «Borrar respaldo y cerrar sesión» sigue existiendo.

## Consecuencias
- Pendiente en la consola de Firebase: registrar App Check en `nombra-dev` y `nombra-prod` (token de depuración en `dev`, Play Integrity y SHA-256 en `prod`) antes de activar la exigencia.
- Cambiar lo que se recoge o cómo se borra obliga a actualizar los textos legales y la página de eliminación ([016](016-legal-texts.md)).
