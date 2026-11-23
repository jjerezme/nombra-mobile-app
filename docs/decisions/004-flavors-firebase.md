# 004. Flavors dev/prod y Firebase nativo

- Estado: aceptada
- Fecha: 2026-11-23

## Contexto
Hay dos proyectos Firebase (desarrollo y producción) y no se debe escribir datos de producción por error.

## Decisión
- Flavors de Android: `dev` (`com.jujeme.nombra.dev`, "Nombra Dev") y `prod` (`com.jujeme.nombra`, "Nombra"), definidos en `android/app/build.gradle.kts`. `AppEnvironment` (`lib/core/environment.dart`) lee el flavor; sin flavor es desarrollo.
- Firebase con `firebase_core`, `cloud_firestore` y `firebase_crashlytics`, configurado con el `google-services.json` nativo de cada flavor en `android/app/src/{dev,prod}/` (no versionado). Sin ese archivo la app compila y arranca sin Firebase (`lib/core/bootstrap.dart`).
- Crashlytics solo recolecta fuera de modo debug.

## Consecuencias
Un checkout nuevo funciona sin secretos. Los plugins de Gradle de Firebase solo se aplican si existe algún `google-services.json`.
