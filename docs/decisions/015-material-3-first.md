# 015. Material 3 primero: componentes estándar, envoltorios finos

- Estado: aceptada
- Fecha: 2026-11-25

## Contexto
La app dibujaba a mano varias piezas que Material 3 ya trae: las píldoras de reglas (`PillChoice`), el selector segmentado (`SegmentedToggle`), la tarjeta (`AppCard`), las etiquetas (`TagChip`), las filas con interruptor y de acción (`ToggleRow`, `ActionRow`) y la barra de navegación (sin indicador). Se veían distintas a las apps de Android y no seguían los estados ni los tamaños de Material (foco, presionado, deshabilitado, objetivo táctil de 48 dp).

## Decisión
- Se usa el componente estándar de Material 3 siempre que exista, con el estilo en el tema (`app_theme.dart`), no en cada pantalla.
- Los widgets de `core/widgets/` que ya existían se conservan como **envoltorios finos** del componente de Material, para no repetir su configuración: `PillChoice` es un `ChoiceChip` (la variante `.action` es un `ActionChip`), `SegmentedToggle` un `SegmentedButton` sin icono de selección y a ancho completo, `AppCard` un `Card` con el relleno de la app, `TagChip` un `Chip` compacto, `ToggleRow` un `SwitchListTile` y `ActionRow` un `ListTile`.
- `NavigationBar` vuelve a sus valores de Material 3 (indicador, alto y etiquetas por defecto). El tema solo define la forma y el color de `Card` (`cardTheme`).
- Siguen siendo propios, porque Material no tiene un equivalente: `InfoBox` (recuadro informativo con etiqueta y valor, o una frase), `ScreenHeader` y `AppSection` (cabecera y título de grupo), `LabeledField` (etiqueta, control y ayuda) y `DestinationCard`.
- Se mantienen deliberadamente los temas de `Switch` y `Checkbox`: apagado debe verse con contorno y no como deshabilitado.

## Consecuencias
- Los chips y el selector segmentado cambian de aspecto: el elegido va en `secondaryContainer`, sin el relleno del color primario.
- Una versión nueva de Flutter puede cambiar la apariencia de estos componentes; el tema es el único sitio donde ajustarla.
- Antes de crear un widget nuevo hay que comprobar si Material ya lo tiene.
