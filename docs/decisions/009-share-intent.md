# 009. Compartir hacia Nombra con una ShareActivity translúcida

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Al compartir un archivo o un enlace desde otra app, Nombra debe aparecer como destino y guardar según la configuración, sin abrir la app completa.

## Decisión
- `ShareActivity` (Kotlin, `FlutterActivity`) con filtros `SEND` (`text/plain` y `*/*`) y `SEND_MULTIPLE`, tema translúcido y `BackgroundMode.transparent`. Arranca el punto de entrada de Dart `shareMain()` (`lib/main.dart`), que dibuja solo la hoja inferior "Guardar con Nombra" sobre la app que comparte.
- Los archivos compartidos se copian al caché de la app (`cache/share/<id>/`) para que Dart los lea por ruta; las copias sin guardar se borran al día siguiente. El texto se examina en Dart: el primer enlace http(s) se descarga.
- Canal `com.jujeme.nombra/share`: `payload` (texto + archivos) y `close`.
- La hoja usa las mismas reglas y la misma lógica que Inicio (`RuleSelector`, `DestinationCard`, `DownloadsNotifier`). Con un solo elemento el nombre final se puede ajustar a mano; con varios archivos se muestra el conteo. "Recordar como predeterminada para imágenes" guarda la regla por tipo de archivo.
- Tras "Guardar" la hoja muestra el progreso y se cierra sola al terminar (ver la limitación del ADR 008).

## Consecuencias
- "Editar reglas" no aparece en la hoja (no hay router); se editan desde la app.
- El código nativo (`ShareActivity`, manifiesto, estilos) no se compiló en el entorno de desarrollo: probar en un dispositivo.
