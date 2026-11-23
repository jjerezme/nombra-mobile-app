# 010. Fuentes empaquetadas

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
El diseño usa IBM Plex Sans (interfaz) y JetBrains Mono (nombres de archivo, patrones y rutas).

## Decisión
Se empaquetan las fuentes variables en `assets/fonts/` (licencia OFL incluida) y se declaran en `pubspec.yaml`. El tema fija el eje de peso con `FontVariation.weight`. No se usa `google_fonts`: así funciona sin red.

## Consecuencias
Suman ~720 KB al APK. Los estilos de texto salen de `AppTheme` (`context.text`) y `AppTextStyles` (`context.monoStyles`).
