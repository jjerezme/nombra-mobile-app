# 012. Icono de la app

- Estado: aceptada
- Fecha: 2026-11-24

## Contexto
La app necesita un icono para el launcher y una marca dentro de la interfaz. El diseño lo entregó el usuario como dos PNG de 512 px: la "N" sobre fondo verde (launcher) y la "N" sobre fondo transparente (dentro de la app).

## Decisión
- Launcher: icono adaptable (`mipmap-anydpi-v26/ic_launcher.xml`) con fondo del color `ic_launcher_background` (#0B6E5F) y la ilustración como primer plano; la "N" cabe en la zona segura central. Los PNG de cada densidad se generaron a partir del original y también están como `ic_launcher.png` para versiones sin iconos adaptables.
- Dentro de la app: `assets/images/logo.png` (256 px) con el widget `AppLogo`. Se muestra a la derecha del título de Descargar (para que el título quede en el mismo sitio que en las demás pestañas) y en el bloque "acerca de" de Ajustes. Es decorativo (sin etiqueta de accesibilidad): el nombre siempre está al lado.
- No se usa un paquete como `flutter_launcher_icons`: los recursos se generaron una vez y se versionan.

## Consecuencias
Cambiar el icono implica regenerar los PNG de `mipmap-*`. El logo interno se ve sobre el fondo del tema: en tema oscuro la parte verde oscura de la "N" tiene poco contraste.
