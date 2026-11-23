# 003. Navegación con go_router

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Se necesita navegación declarativa con deep links, equivalente a Expo Router.

## Decisión
`go_router`, expuesto como `routerProvider` en `lib/app/router.dart`. Las rutas se declaran ahí (constantes en `AppRoutes`); las pantallas viven en `lib/features/`.

## Consecuencias
No se usa `Navigator` directamente salvo para diálogos y hojas modales.
