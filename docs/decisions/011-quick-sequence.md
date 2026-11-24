# 011. Patrón rápido con tokens y secuencial

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
La regla rápida (prefijo + nombre original + sufijo) no podía numerar archivos ni descartar el nombre original, que a veces es solo un identificador (`17954786131634187737124177335050`). Las reglas guardadas ya arman el nombre con tokens (`{name}`, `{date}`, `{time}`, `{n:3}`, `{domain}`, `{type}` y texto libre).

## Decisión
- El modo rápido usa el mismo constructor de patrón que una regla (`PatternSection`). El patrón se guarda en `AppSettings.quickTokens` (por defecto `[{name}]`): **no es una regla guardada**, es el único patrón que se mantiene y se aplica cada vez que se guarda algo en modo rápido. Se renderiza con `renderPattern`, igual que una regla (`buildQuickFileName`).
- Quitar `{name}` del patrón reemplaza el nombre original. El número secuencial es el token `{n:3}` (los dígitos salen del propio token).
- El siguiente número (`quickNext` + `quickNextKey`) se mantiene mientras el patrón no cambie: la firma del patrón es `quickSignature` (los tokens unidos). Si cambia el patrón, la secuencia vuelve a 1 (`nextQuickNumber`). El campo "Siguiente número" permite fijarlo a mano (entero de 1 a 999 999 999) para el patrón actual.
- El número se toma al nombrar el archivo (`DownloadPlan.nameFor` → `SettingsNotifier.takeQuickNumber`), igual que el contador de las reglas: una descarga que falla no gasta número y varios archivos compartidos reciben números consecutivos. Un nombre escrito a mano en la hoja de compartir no consume número.
- `DownloadPlan.quick` copia el patrón al crear el plan: cambiarlo mientras algo se descarga no altera su nombre.
- Migración: los ajustes y planes de la primera versión rápida (prefijo, sufijo, reemplazo, secuencial) se convierten en un patrón (`legacyQuickTokens`).
- Un patrón vacío no se puede usar: se muestra el error y se bloquea Descargar / Guardar.
- Extensión por tipo MIME: al compartir, si el nombre que entrega la app de origen no tiene extensión, `ShareActivity` la deduce del tipo (`image/jpeg` → `.jpg`) con `MimeTypeMap`.
- Editor de reglas: el cuadro de ejemplo del nombre final queda fijo debajo del formulario (fuera de la lista que se desplaza) y se actualiza con cada cambio.

## Consecuencias
- Cambiar el patrón reinicia la secuencia en 1: es lo esperado, pero obliga a fijar el número otra vez si se quiere continuar desde otro valor.
- Si el tipo MIME no se conoce, el nombre queda sin extensión.
- El modo rápido no tiene transformaciones (mayúsculas, espacios, limpieza); para eso se usa una regla guardada.

## Constructor de patrón (reglas y modo rápido)
- Un patrón admite como máximo 5 elementos (`PatternTokens.maxCount`); al llegar al límite la paleta se atenúa y se muestra el aviso.
- Elemento de espacio en blanco: texto `' '` guardado como cualquier otro texto; en la caja se dibuja como `␣`.
- Los textos fijos se editan tocándolos. Al agregar un número se pregunta cuántos dígitos tiene (1 a 8, `{n:5}` escribe `00007`) y se cambian tocando el elemento.
- Los elementos y el botón de borrar comparten línea central, también con el patrón vacío.
- "Reemplazar espacios por" usa el mismo `SegmentedToggle` que mayúsculas/minúsculas.
