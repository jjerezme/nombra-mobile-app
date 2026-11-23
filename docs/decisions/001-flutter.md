# 001. Flutter como plataforma

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Nombra nació de la plantilla `mobile-base` (Expo + React Native). Se decidió construirla con Flutter.

## Decisión
Flutter 3.50 (Dart 3.14), solo Android por ahora. Material viene del paquete `material_ui`, que es el que genera `flutter create` en esta versión. El soporte de iOS no se creó; se agrega con `flutter create --platforms=ios .` cuando haga falta.

## Consecuencias
- Se eliminó todo el código Expo/React Native (sigue en el historial de git).
- Los estándares de `STANDARD.md` se reescribieron para Flutter.
