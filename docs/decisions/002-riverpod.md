# 002. Estado con Riverpod

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Hace falta una gestión de estado testeable y que no dependa de `BuildContext`.

## Decisión
`flutter_riverpod`. La app va envuelta en `ProviderScope`; el router, los repositorios y el estado de cada feature son providers.

## Consecuencias
Los widgets leen providers con `ConsumerWidget`; los widgets sin estado compartido siguen siendo `StatelessWidget`. Las pruebas sobrescriben providers en vez de usar mocks globales.
