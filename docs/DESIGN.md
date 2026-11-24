# Diseño: reglas de layout

Todas las pantallas se arman con las mismas piezas (`lib/core/widgets/`) y los valores de `AppLayout` (`lib/core/constants/tokens.dart`). `scripts/check_styles.dart` falla si una pantalla usa números o colores fuera de los tokens.

## Medidas (`AppLayout`)
| Token | Valor | Uso |
|---|---|---|
| `gutter` | 16 | Margen entre el borde de la pantalla y el contenido |
| `sectionGap` | 16 | Separación entre bloques de una página y dentro de una tarjeta |
| `itemGap` | 8 | Separación entre elementos de una lista (reglas, descargas) |
| `labelGap` | 8 | Etiqueta ↔ control ↔ ayuda |
| `cardPadding` / `cardRadius` | 16 / 16 | Toda tarjeta |
| `controlRadius` | 12 | Botones, campos y cajas dentro de una tarjeta |
| `sheetGutter` | 20 | Margen horizontal de las hojas inferiores |
| `buttonGap` | 12 | Entre botones de una fila |

## Piezas
- `ScreenHeader`: título de cada pantalla (`headlineSmall`, 4 de sangría sobre el margen, subtítulo opcional). Las pantallas de detalle añaden atrás (pegado al margen izquierdo) y una acción a la derecha. Se coloca como primer elemento de la lista, con `AppPage.padding` (o `AppPage.paddingWithBack` si lleva fila de atrás).
- `AppSection` / `SectionTitle`: título de un grupo (`titleMedium`) **encima** de su tarjeta; el título nunca va dentro de la tarjeta.
- `AppCard` / `AppCard.stack`: superficie con radio y relleno únicos; `stack` apila los bloques con `sectionGap`.
- `LabeledField`: etiqueta (`labelMedium`) + control + ayuda (`bodySmall`). Es la única forma de rotular un campo.
- `ToggleRow`, `ActionRow`: filas con interruptor y filas de acción.
- `SegmentedToggle`, `PillChoice`: elecciones exclusivas.

## Marca
El logo (`AppLogo`) va a la derecha del título de Descargar (el título no se mueve de sitio) y en el bloque "acerca de" de Ajustes; no se repite en otras pantallas. Detalle en la decisión [012](decisions/012-app-icon.md).

## Botones
- Acción principal: un `FilledButton` de ancho completo, alto `AppSize.button`, solo con texto.
- Secundaria: `OutlinedButton` con la misma forma; terciaria y en diálogos: `TextButton`.
- Filas de dos botones: `Expanded` + `buttonGap`. Todos con radio `controlRadius`; el estilo vive en el tema, no en cada pantalla.

## Hojas inferiores
Color de superficie, asa del tema, margen `sheetGutter`, bloques con `sectionGap` y relleno inferior que respeta la barra de navegación de Android.

## Lista de reglas
- Siempre ordenada por nombre (sin distinguir mayúsculas), también en el selector de Descargar y de la hoja de compartir; no hay orden manual.
- Cada tarjeta (`RuleCard`) tiene las mismas filas, en el mismo orden y alineadas al mismo borde: nombre, tokens, ejemplo, opciones adicionales (etiquetas) y carpeta de destino. Las reglas siempre están activas (no se pueden apagar). Tocar la tarjeta abre la regla.

## Entradas de texto y selecciones
Todo lo que el usuario escribe o elige (texto fijo, dígitos del número, carpeta) se pide en una hoja inferior con `showInputSheet` / `SheetScaffold` (título, contenido y `SheetActions`), que cubre toda la pantalla incluida la barra de navegación. Los diálogos centrados quedan solo para preguntas de sí o no (`showConfirmDialog`).
