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
- `ScreenHeader`: título de cada pantalla (`headlineSmall`, 4 de sangría sobre el margen, subtítulo opcional). Las pantallas de detalle llevan atrás (pegado al margen izquierdo) con el título a su lado, en la misma fila; la acción principal (por ejemplo "Guardar" en el editor) va abajo, fija y visible, como `FilledButton` de ancho completo. Se coloca como primer elemento de la lista, con `AppPage.padding` (o `AppPage.paddingWithBack` si lleva fila de atrás).
- `AppSection` / `SectionTitle`: título de un grupo (`titleMedium`) **encima** de su tarjeta; el título nunca va dentro de la tarjeta.
- `AppCard` / `AppCard.stack`: superficie con radio y relleno únicos; `stack` apila los bloques con `sectionGap`.
- `LabeledField`: etiqueta (`labelMedium`) + control + ayuda (`bodySmall`). Es la única forma de rotular un campo.
- `DestinationCard`: la única forma de mostrar y cambiar una carpeta (Descargar, hoja de compartir, Ajustes, editor de reglas): icono de carpeta, ruta elegida (o mensaje si no hay) y botón que abre el selector. Sin etiquetas ni textos sobre el origen de la carpeta. La carpeta solo se cambia, no se quita.
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

## Cómo se nombra el archivo (Descargar y hoja de compartir)
Un interruptor **Aplicar una regla**, justo debajo de la URL. Apagada (por defecto): no se aplica ninguna regla, el archivo conserva su nombre original y un cuadro informativo (`InfoBox.note`) bajo el interruptor lo explica (no va en la etiqueta); la carpeta de destino sí se puede elegir. Encendida: la nota se reemplaza por una sola fila de chips con scroll lateral: **Personalizado** (patrón propio que se mantiene), cada regla guardada y, al final, la acción **Agregar** (solo en Descargar). No hay chip "Ninguna". Al encender el interruptor se vuelve a la última regla usada, o a Personalizado si no hay. El recuadro "Se guardará como" no se muestra hasta que la URL es válida.


## Lista de descargas
Cada descarga terminada o fallida tiene un menú de tres puntos (`Más acciones`, 48 dp): **Abrir** (solo las guardadas; abre el archivo con la app del sistema y avisa si no se pudo) y **Quitar de la lista** (no borra el archivo). Las descargas en curso no tienen menú.

## Lista de reglas
- Siempre ordenada por nombre (sin distinguir mayúsculas), también en el selector de Descargar y de la hoja de compartir; no hay orden manual.
- Cada tarjeta (`RuleCard`) tiene las mismas filas, en el mismo orden y alineadas al mismo borde: nombre, tokens, ejemplo, opciones adicionales (etiquetas) y carpeta de destino. Las reglas siempre están activas (no se pueden apagar). Tocar la tarjeta abre la regla.

## Entradas de texto y selecciones
Todo lo que el usuario escribe o elige (texto fijo, dígitos del número, carpeta) se pide en una hoja inferior con `showInputSheet` / `SheetScaffold` (título, contenido y `SheetActions`), que cubre toda la pantalla incluida la barra de navegación. Los diálogos centrados quedan solo para preguntas de sí o no (`showConfirmDialog`).

## Cuenta (Ajustes)
Primera sección de Ajustes. Sin sesión: una frase que explica el respaldo y el botón **Continuar con Google** (contorno, con la «G» de Google en sus colores; `assets/images/google_g.png`). Con sesión: inicial, nombre y correo, el estado del respaldo (**Respaldando tus reglas…**, **Reglas respaldadas** o el error con **Reintentar**), **Cerrar sesión** y **Borrar respaldo y cerrar sesión** (destructiva, con confirmación). Si la compilación no tiene Firebase, un `InfoBox.note` lo explica y no hay botón.

## Accesibilidad
- Los chips de reglas forman un grupo con etiqueta (**Reglas de nombrado**); cada chip dice que es un botón y si está seleccionado.
- El estado del respaldo es una región viva: el lector de pantalla anuncia el cambio. La inicial del avatar es decorativa y se excluye.
- Un botón solo con icono lleva `tooltip` o `Semantics`; las áreas táctiles son de 48 dp.
- Mientras corre una acción de la cuenta (iniciar sesión, cerrar sesión, borrar el respaldo) arriba de la tarjeta aparece una barra de progreso con el nombre de la acción («Iniciando sesión…»), el resto se atenúa (`AppOpacity.disabled`) y no recibe toques. La barra es una región viva para el lector de pantalla.
