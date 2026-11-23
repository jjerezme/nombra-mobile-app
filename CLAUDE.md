# CLAUDE.md

@AGENTS.md

## Resumen
<!-- Qué es la app, en 2-3 líneas. -->

## Comandos de verificación
```bash
npm run lint
npm run typecheck
npm test
npm run check:styles
```
Ejecuta lint, typecheck y test antes de dar una tarea por terminada.

## Reglas de proceso y comunicación

- **Ante cualquier duda, pregunta y espera confirmación antes de decidir e implementar.** Tiene prioridad sobre "avanzar sin preguntar". Pregunta breve, con alternativas y la recomendada marcada; incluye las elecciones técnicas (librerías, nombres, arquitectura), no solo las ambigüedades del pedido.
- **Toda decisión técnica o de diseño va en su ADR** (`docs/decisions/NNN-titulo.md`), en el mismo cambio. Si restringe código futuro, agrega además una línea en "Reglas vigentes". Si una decisión cambia, edita su entrada: no agregues una que la contradiga. Antes de tocar un tema, lee su ADR.
- Si cambia lo que hace la app, actualiza `docs/ARCHITECTURE.md`; si cambia cómo se instala o se usa, el `README.md`.
- CLAUDE.md no es un diario ni duplica el README. Menos de 200 líneas.
- `TODO.md` guarda los pendientes pospuestos; al terminar uno, muévelo a "Hecho".
- Commits pequeños (uno por cambio lógico), en inglés, Conventional Commits, terminando con `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Ramas `feature/*` desde `develop` (ver `docs/GITFLOW.md`; la rama de producción es `master`).
- **No hagas `git push`, PR, fusión a `master`, despliegues (reglas, Hosting) ni subidas a tiendas sin que el usuario lo pida.** Compila solo cuando se pida; cada compilación se copia también a Drive (`--upload`).
- **Secretos fuera del chat y del repo.** Nunca escribas ni pidas contraseñas, frases de paso ni claves. `google-services*.json`, `.env`, llaves y keystores no se versionan.
- Interfaz y documentación en español neutro (tuteo, sin voseo); identificadores, comentarios nuevos y commits en inglés. Toda cadena visible va en `src/i18n/` (es y en, con las mismas claves).
- **Ningún archivo pasa de 500 líneas**; si se acerca a 400, pártelo. **Función pura nueva = test.**
- Si una pantalla cambió, pruébala en un dispositivo real, en tema claro y oscuro y en todos los idiomas.

## Convenciones

- **Estilos** (detalle en `STANDARD.md`): tamaños, espacios, radios, bordes y fuentes solo de `constants/tokens.ts` y `typography.ts`; colores solo de `useTheme().colors`. `npm run check:styles` lo verifica; excepción deliberada: `// style-ok` al final de la línea. Si ningún token calza, piensa si falta uno.
- Los estilos de un componente son `createXStyles(colors)` con `StyleSheet.create`; si el archivo crece, van en un `styles.ts` con un hook `useXStyles()`.
- **Nombres:** componentes `PascalCase.tsx`, hooks `useX.ts`, `lib/` y `constants/` `camelCase.ts`, rutas `kebab-case`; props de evento `onX`, manejadores `handleX`, booleanos `isX`/`hasX`; constantes fijas `SCREAMING_SNAKE`.
- **Componentes:** revisa `components/` antes de crear uno; si ninguno sirve, pregunta antes de crear uno nuevo. Un componente por archivo con su `XProps`, sin acceso directo a Firestore. Toda lista cubre carga, error con "Reintentar" y vacío (`EmptyState`). Avisos y confirmaciones con `ConfirmDialog`/`MessageDialog`, nunca `Alert.alert`; hojas con `BottomSheetModal`.
- Un `Pressable` solo con icono lleva `accessibilityRole` y `accessibilityLabel`; áreas táctiles de 48 dp (`hitSlopFor`); iconos de `@expo/vector-icons/MaterialIcons` por ruta directa. No hay pantalla de "sistema de diseño".
- Estándar completo: `STANDARD.md`. Builds: `npm run apk` / `apk:preview` / `apk:production` / `aab` usan el `build-apk` compartido de `@jujeme/mobile-tools`, configurado en `build.config.json`; tras agregar una librería nativa, `npm run apk -- --prebuild`.

## Mapa de arquitectura
<!-- Carpetas clave y su responsabilidad. Detalle en docs/ARCHITECTURE.md. -->

## Reglas vigentes
<!-- Una línea por regla + enlace a su ADR en docs/decisions/. -->

## Qué no hacer

- No uses CLAUDE.md como diario ni dupliques el README.
- No agregues JavaScript nuevo (salvo archivos de configuración) ni el SDK web de Firebase.
- No versiones `google-services*.json`, `.env`, keystores ni llaves.
- No dejes reglas de Firestore con escritura libre.
- No pongas números de estilo, colores ni textos sueltos en las pantallas.
- No hagas push, PR, fusión a `master` ni despliegues sin que el usuario lo pida.
