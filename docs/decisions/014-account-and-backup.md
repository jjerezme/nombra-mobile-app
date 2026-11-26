# 014. Cuenta de Google y respaldo automático de las reglas

- Estado: aceptada
- Fecha: 2026-11-25

## Contexto
Con `allowBackup="false"` ([013](013-security-hardening.md)) las reglas, que son lo más difícil de rehacer, se pierden al cambiar de teléfono. Los proyectos de Firebase `nombra-dev` y `nombra-prod` ya existen, con Authentication, Firestore y Hosting activos.

## Decisión
- Se agregan `firebase_auth` y `google_sign_in` (autorizado por el usuario, fuera de la lista anterior de plugins). El acceso es solo con cuenta de Google, desde Ajustes › Cuenta.
- Se respaldan solo las **reglas**, no el historial ni los ajustes. Un documento por persona, `users/{uid}`, con `rulesJson` (la lista completa como texto JSON, para que vuelva idéntica), `writer` (id del dispositivo), `schema` y `updatedAt`.
- El respaldo es **automático**: al iniciar sesión se mezclan una vez las reglas del teléfono y las de la nube (`mergeRules`: se conservan las de ambos lados; en una regla repetida gana la de la nube, salvo su contador `{n:3}`, que conserva el número mayor). Después, gana la última escritura: un cambio local se envía tras 2 s sin cambios; un cambio de otro dispositivo reemplaza las reglas locales. Cada dispositivo ignora el eco de sus propias escrituras por su `writer`.
- `BackupSync` (Riverpod) lo coordina. `AuthGateway` y `BackupGateway` aíslan Firebase para poder probarlo con fakes; sin Firebase (checkout sin `google-services.json`) se usan versiones que no hacen nada y Ajustes lo explica.
- Cerrar sesión deja las reglas en el teléfono y en la nube. «Borrar respaldo y cerrar sesión» elimina el documento de la nube.
- `firestore.rules`: cada persona solo lee, escribe y borra su propio `users/{uid}`, solo con esos campos y con un tope de tamaño; todo lo demás está cerrado. Se despliega con `firebase deploy --only firestore:rules --project dev|prod`, a pedido del usuario.

## Consecuencias
- Para que el inicio de sesión funcione cada flavor necesita su `google-services.json` (con el cliente web OAuth) y las huellas SHA-1 del teléfono (debug) y de la llave de subida registradas en el proyecto de Firebase correspondiente. Sin eso, Ajustes muestra que el respaldo no está disponible o el inicio de sesión falla.
- Mientras no se despliegan las reglas, Firestore usa las que tenga el proyecto; no se debe dejar el modo de prueba (escritura libre).
- Borrar una regla en un dispositivo mientras otro no ha sincronizado puede devolverla en la mezcla del primer inicio de sesión de un tercero. Con escritura de «gana la última» después del primer inicio, el borrado se propaga.
- Dos dispositivos que cambian las reglas a la vez: gana el que escribe último; el otro puede perder su cambio.
- El contador `{n:3}` de cada regla viaja con el respaldo, así que cada descarga con contador genera una escritura (agrupada por el retraso de 2 s).
