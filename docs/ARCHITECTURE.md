# Arquitectura

## Arranque
`main.dart` inicializa Firebase (`core/bootstrap.dart`) y ejecuta `NombraApp` dentro de un `ProviderScope`. Si falta el `google-services.json` del flavor, el arranque sigue sin Firebase y deja el motivo en el log.

## Capas
- `app/`: `NombraApp` (tema, idiomas, router) y `router.dart` (`routerProvider`, constantes `AppRoutes`).
- `core/`: `environment.dart` (`AppEnvironment` según el flavor), `constants/tokens.dart`, `theme/app_theme.dart` (tema claro y oscuro con `ColorScheme.fromSeed`).
- `features/<feature>/`: pantallas, providers y repositorios. Hoy solo existe `home`.
- `l10n/`: `app_es.arb` (plantilla) y `app_en.arb`; el código generado se versiona.

## Datos
Firestore se accede solo desde repositorios expuestos como providers de Riverpod; los widgets no lo usan directamente. Aún no hay colecciones.

## Entornos
`dev` y `prod` (ver ADR 004). `AppEnvironment.current` resuelve el entorno a partir de `appFlavor`.
