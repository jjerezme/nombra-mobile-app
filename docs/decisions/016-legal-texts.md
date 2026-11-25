# 016. Términos y política de privacidad: un solo texto para la app y la web

- Estado: aceptada
- Fecha: 2026-11-25

## Contexto
Para publicar la app y para el inicio de sesión con Google hacen falta unos términos y una política de privacidad, visibles dentro de la app y en una dirección web pública (Hosting de `nombra-prod`).

## Decisión
- El texto vive una sola vez, en Dart puro, en `lib/features/legal/domain/` (`legal_content_es.dart` y `legal_content_en.dart`, con `LegalDocument`/`LegalSection`). La app lo muestra en `LegalScreen` según su idioma y la web se genera desde ese mismo dato con `dart run scripts/build_legal.dart` (`legal_html.dart` produce el HTML).
- La web está en `web/` (versionada): `index.html`, `terms.html`, `privacy.html` y `en/terms.html`, `en/privacy.html`, con `style.css` y `logo.png` escritos a mano. Con `cleanUrls` quedan en `/terms`, `/privacy`, `/en/terms` y `/en/privacy`. `firebase.json` define el hosting (carpeta `web`, cabeceras de seguridad y una CSP que no permite scripts).
- Dentro de la app: Ajustes › Legal (dos filas) y, bajo «Continuar con Google», una nota con enlaces a ambos textos.
- Un test falla si `web/` no coincide con lo que genera el script, para que la web no quede atrás del texto de la app.
- El correo de contacto es `jjerezme@gmail.com` (`legalContactEmail`, público). La web se publica en `https://nombra-prod.web.app`.
- El texto describe lo que la app hace de verdad (datos locales, cuenta opcional, respaldo de reglas, Crashlytics sin enlaces, sin publicidad ni analítica). Si cambia lo que se recoge, hay que cambiar el texto y la fecha en el mismo cambio.

## Consecuencias
- Pendiente a propósito: el nombre del responsable y la ley aplicable no se indican todavía (el usuario pidió dejarlo vacío); los términos no tienen cláusula de jurisdicción. Está en `TODO.md`.
- El texto no es asesoría legal: conviene que lo revise una persona con conocimiento legal antes de publicar en una tienda.
- «Borrar respaldo y cerrar sesión» no elimina el registro de Firebase Authentication; la política lo dice y pide escribir al contacto. Eliminar la cuenta desde la app queda en `TODO.md`.
- Cambiar el texto obliga a ejecutar el script y a publicar de nuevo en Hosting (`firebase deploy --only hosting --project nombra-prod`), a pedido del usuario.
