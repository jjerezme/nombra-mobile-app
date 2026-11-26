# 016. Términos y política de privacidad: un solo texto para la app y la web

- Estado: aceptada
- Fecha: 2026-11-25

## Contexto
Para publicar la app y para el inicio de sesión con Google hacen falta unos términos y una política de privacidad, visibles dentro de la app y en una dirección web pública (Hosting de `nombra-prod`).

## Decisión
- El texto vive una sola vez, en Dart puro, en `lib/features/legal/domain/` (`legal_content_es.dart` y `legal_content_en.dart`, con `LegalDocument`/`LegalSection`). La app lo muestra en `LegalScreen` según su idioma y la web se genera desde ese mismo dato (ver abajo).
- La web la genera el comando `build-web` del paquete `mobile-tools`, que trae el código y los estilos (requiere Node; se ejecuta con `npx --yes -p git+https://github.com/jjerezme/mobile-tools.git#v0.5.0 build-web`): landing, `/privacy`, `/terms` y `/delete-account`, cada una con los dos idiomas (inglés por defecto, `?lang=es`). `dart run scripts/export_legal.dart` pasa el texto de la app a `web/legal/{en,es}.json`; la landing y la eliminación de la cuenta se escriben en `web/content/` y la configuración en `web/site.config.json`. El resultado, versionado, queda en `web/public/`.
- `firebase.json` publica `web/public` con cabeceras de seguridad. La CSP solo permite el script del selector de idioma, por su hash: si cambia el generador, hay que actualizar el hash.
- Dentro de la app: Ajustes › Legal (dos filas) y, bajo «Continuar con Google», una nota con enlaces a ambos textos.
- Un test falla si `web/legal/` no coincide con el texto de la app. Después de exportar hay que ejecutar `build-web`.
- El correo de contacto es `jjerezme@gmail.com` (`legalContactEmail`, público). La web se publica en `https://nombra-prod.web.app`.
- El texto describe lo que la app hace de verdad (datos locales, cuenta opcional, respaldo de reglas, Crashlytics sin enlaces, sin publicidad ni analítica). Si cambia lo que se recoge, hay que cambiar el texto y la fecha en el mismo cambio.

## Consecuencias
- Pendiente a propósito: el nombre del responsable y la ley aplicable no se indican todavía (el usuario pidió dejarlo vacío); los términos no tienen cláusula de jurisdicción. Está en `TODO.md`.
- El texto no es asesoría legal: conviene que lo revise una persona con conocimiento legal antes de publicar en una tienda.
- La cuenta se elimina desde la app ([017](017-developer-mode-and-account-deletion.md)); el correo de contacto queda para quien no pueda usarla.
- Cambiar el texto obliga a ejecutar los dos scripts y a publicar de nuevo en Hosting (`firebase deploy --only hosting --project nombra-prod`), a pedido del usuario.
