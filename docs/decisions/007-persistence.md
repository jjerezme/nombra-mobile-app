# 007. Reglas, ajustes e historial en shared_preferences

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Nombra guarda las reglas de renombrado, lo último que eligió el usuario (modo, regla, prefijo, sufijo, carpeta, regla predeterminada por tipo de archivo) y el historial de descargas. Son pocos datos y no hay cuentas ni sincronización.

## Decisión
- `shared_preferences`, un valor JSON por clave: `rules`, `settings` y `downloads` (historial, máximo 50).
- Cada uno vive en un `Notifier` de Riverpod (`RulesNotifier`, `SettingsNotifier`, `DownloadsNotifier`) que lee al construirse y escribe en cada cambio. `SharedPreferences` se carga en `main()` y entra por `sharedPreferencesProvider`.
- Los textos de las reglas de ejemplo (primer arranque) salen de `lib/l10n/` con el idioma del dispositivo.
- La hoja de compartir corre en su propio motor de Flutter y escribe en las mismas preferencias: la app principal las recarga (`reload()`) y reinvalida los providers al volver a primer plano.

## Consecuencias
- Si el historial o las reglas crecen mucho, habrá que pasar a una base de datos (ver la alternativa descartada, `drift`).
- Una regla guarda una copia de sí misma en cada descarga (`DownloadPlan.rule`), así que editar o borrar la regla no cambia descargas en curso.
