# Estándar de proyectos móviles

Aplica a exodo, tpc, tps y tpt. Fuente: `PLAN-ESTANDARIZACION.md`.

## Decisiones tomadas
| Tema | Decisión |
|---|---|
| Rama de producción | `master` (en tpc, renombrar `main` → `master`) |
| Lenguaje | TypeScript strict. tpt migra todo a TS (no solo código nuevo) |
| Firebase | SDK nativo (`@react-native-firebase`). tpc abandona el SDK web |
| Plantilla | Este repo (`mobile-base`) |
| Commits | Conventional Commits en inglés + `Co-Authored-By` |

## Estructura
`src/app` (rutas) · `src/components` · `src/hooks` · `src/lib` (lógica pura) · `src/constants` · `src/i18n`. Tests en `__tests__/` junto a cada módulo.

## Nombres
- Archivos: componentes `PascalCase.tsx` · hooks `useX.ts` · `lib/` y `constants/` `camelCase.ts` · rutas `kebab-case` (con `[param]` y `(grupo)` de Expo Router) · variantes de plataforma `X.web.tsx`.
- Código: tipos y componentes `PascalCase` · constantes fijas `SCREAMING_SNAKE` (`FIELD_ORDER`) · objetos de tokens en minúscula (`spacing`) · props de evento `onX`, manejadores `handleX` · booleanos `isX` / `hasX`.
- Claves de i18n en `camelCase` agrupadas por pantalla; campos y colecciones de Firestore en inglés y `camelCase`.

## Estilos
- Un solo archivo de tokens, `constants/tokens.ts`, con los exports `spacing`, `radius`, `iconSize`, `fontSize`, `border`, `opacity` (y `alpha`, `lineHeight`, `layout` si el proyecto los necesita). Los roles tipográficos van en `constants/typography.ts` y las fuentes en `constants/fonts.ts`.
- Ningún número de tamaño, espacio, radio, borde o fuente fuera de esos tokens. Los colores salen solo de `useTheme().colors` (paletas en `constants/themes.ts`); nunca un hex en un componente. Un proyecto con una sola paleta (exodo) importa `colors` de `src/theme.ts` en vez de usar `useTheme()`.
- `npm run check:styles` falla si algo se sale de los tokens. Una excepción deliberada lleva `// style-ok` al final de la línea.
- Los estilos de un componente son `createXStyles(colors)` con `StyleSheet.create` y, si el archivo crece, viven en un `styles.ts` junto a él con un hook `useXStyles()` que los memoriza por `colors`.
- Si ningún token calza, piensa si falta un token antes de escribir el número.
- No hay pantalla de "sistema de diseño" con ejemplos: los componentes comunes se describen en `docs/ARCHITECTURE.md`.

## Componentes
- Estructura: `components/ui/` para primitivos (botón, campo, tarjeta, FAB, `EmptyState`, diálogos, hojas) y `components/<dominio>/` para los del dominio. Un componente grande se parte en `components/<pantalla>/` con `styles.ts`, `types.ts`, hooks y subcomponentes; la ruta solo arma piezas.
- Antes de crear un componente revisa `components/`. Si uno sirve, extiéndelo; si ninguno sirve, pregunta antes de crear uno nuevo.
- Un componente por archivo, con su `XProps` y export por defecto del mismo nombre. Los componentes no acceden a Firestore: usan hooks o servicios de `lib/`.
- Toda lista cubre los tres estados: carga (esqueleto), error con "Reintentar" y vacío (`EmptyState` con acción).
- Avisos y confirmaciones con `ConfirmDialog` / `MessageDialog`, nunca `Alert.alert`. Hojas modales con `BottomSheetModal`.
- Accesibilidad: un `Pressable` solo con icono lleva `accessibilityRole` y `accessibilityLabel`; áreas táctiles de al menos 48 dp (`hitSlopFor`); el estado no depende solo del color.
- Iconos: `@expo/vector-icons/MaterialIcons`, importado por su ruta directa.
- Con el React Compiler activo no se escribe `useMemo`, `useCallback` ni `React.memo` por defecto; solo si el Profiler muestra un problema (excepción: los hooks de estilos).

## Scripts obligatorios
`lint`, `typecheck`, `test`, `check:styles`, `apk`, `apk:preview`, `apk:production`, `aab`.

## Build de Android

Todos los proyectos usan el mismo script, el paquete `@jujeme/mobile-tools` (repo `jjerezme/mobile-tools`, binario `build-apk`), como `optionalDependencies` fijada por tag (el repo es privado: en la CI npm la omite porque no se compila ahí, los builds son locales). Cada proyecto lo configura con su `build.config.json` (nombre, prefijo de archivos, rutas de SDK/JDK/Drive, llaves, variantes). Los archivos se llaman `<prefijo>-<tipo>-v<versión>-<versionCode>-<fecha>.apk|aab` y cada compilación se copia también a Drive (`--upload`). Referencia completa: README de `mobile-tools`.

## Entornos y Firebase
- 2 proyectos Firebase: dev y prod.
- `firebase/{dev,prod}/google-services.json` en `.gitignore`.
- Variable `APP_VARIANT` (dev por defecto). No usar `EXPO_PUBLIC_BUILD_PROFILE`.
- `environments.json` describe cada entorno.

## Seguridad
- Reglas Firestore: deny-all por defecto, validación por colección (`hasOnly`), test con emulador.
- App Check, Crashlytics, analytics sin datos personales.
- Eliminar cuenta borra todos los datos del usuario.

## Calidad
- Función pura nueva = test.
- Ningún archivo supera 500 líneas.
- CI por PR: lint, typecheck, test, `expo-doctor`.
- Dependabot activo. Mismo Expo SDK en todos los proyectos.

## Git
Gitflow: `feature/*` y `bugfix/*` → `develop`; `release/*` y `hotfix/*` → `master`. Ver `docs/GITFLOW.md`.

## Documentación
- `README.md` (<200 líneas) y `CLAUDE.md` (<200 líneas). `AGENTS.md` idéntico en todos.
- `docs/`: `GITFLOW.md`, `ARCHITECTURE.md`, `SECURITY.md`, `BUILD.md`, `decisions/NNN-titulo.md`.
- Toda decisión técnica va en un ADR. Si restringe código futuro, una línea en "Reglas vigentes" de `CLAUDE.md`.
- CLAUDE.md no es diario ni duplica README.
- Español neutro (tuteo) en docs e i18n.

### Formato del README
Puerta de entrada de unas 80 líneas (máximo 120). Plantilla: `docs/README.template.md`. Secciones, en este orden:
1. `# Nombre` y un párrafo: qué es, plataforma y stack en una frase.
2. **Qué incluye**: 5 a 8 viñetas de una línea.
3. **Requisitos**: Node, Java 17, Android SDK; no hay Expo Go.
4. **Empezar**: `npm install`, `.env`, `firebase/{dev,prod}/google-services.json`, primer build.
5. **Entornos**: tabla (paquete, proyecto de Firebase, `APP_VARIANT`).
6. **Scripts**: tabla común.
7. **Estructura**: árbol de un nivel, una línea por carpeta.
8. **Documentación**: lista fija de enlaces.

No van en el README (van en `docs/`): modelo de datos, tabla de stack, procedimientos de firma, Google Sign-In, Metro, historial de nombres y limitaciones (estas, en `TODO.md`).

### Formato del CLAUDE.md
Menos de 200 líneas. Secciones, en este orden: `# CLAUDE.md` + `@AGENTS.md`, Resumen, Comandos de verificación, Reglas de proceso y comunicación, Convenciones, Mapa de arquitectura, Reglas vigentes (por tema, con enlace a su ADR) y Qué no hacer.
- "Reglas de proceso y comunicación" y la base de "Qué no hacer" son iguales en todos los proyectos (ver `CLAUDE.md` de esta plantilla); cada proyecto solo añade líneas propias al final de la lista.
- `AGENTS.md` es idéntico en todos: builds locales con `build-apk` (sin EAS) y rutas en `app/` o `src/app/`.
- El código nuevo usa identificadores y comentarios en inglés; la interfaz y la documentación, en español neutro.
