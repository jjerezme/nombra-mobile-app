// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Nombra';

  @override
  String get navDownload => 'Descargar';

  @override
  String get navRules => 'Reglas';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get change => 'Cambiar';

  @override
  String get retry => 'Reintentar';

  @override
  String get delete => 'Eliminar';

  @override
  String get accept => 'Aceptar';

  @override
  String get modeSaved => 'Guardada';

  @override
  String get modeQuick => 'Rápida';

  @override
  String get ruleLabel => 'Regla';

  @override
  String get ruleRemembered => 'Se recuerda la última usada';

  @override
  String get editRules => 'Editar reglas';

  @override
  String get noEnabledRules => 'No hay reglas activas. Actívalas en Reglas.';

  @override
  String get prefix => 'Prefijo';

  @override
  String get suffix => 'Sufijo';

  @override
  String get prefixHint => 'p. ej. acme_';

  @override
  String get suffixHint => 'p. ej. _v2';

  @override
  String saveIn(String source) {
    return 'Guardar en · $source';
  }

  @override
  String get folderSourceLastUsed => 'última usada';

  @override
  String get folderSourceChosen => 'elegida';

  @override
  String folderSourceRule(String rule) {
    return 'según regla «$rule»';
  }

  @override
  String get changeFolderTooltip => 'Cambiar carpeta de destino';

  @override
  String get homeUrlLabel => 'URL del archivo';

  @override
  String get homePasteTooltip => 'Pegar del portapapeles';

  @override
  String get homeUrlInvalid => 'Introduce una URL http o https válida';

  @override
  String get homeSavedAs => 'Se guardará como';

  @override
  String get homePreviewEmpty => 'Pega una URL para ver el nombre';

  @override
  String get homeDownload => 'Descargar';

  @override
  String get homeRecents => 'Recientes';

  @override
  String get homeRecentsEmpty => 'Aún no hay descargas';

  @override
  String homeProgress(String received, String total, String speed) {
    return '$received de $total · $speed';
  }

  @override
  String homeProgressNoTotal(String received, String speed) {
    return '$received · $speed';
  }

  @override
  String get homeWaiting => 'En espera…';

  @override
  String get homeFinishing => 'Guardando…';

  @override
  String homeSavedIn(String folder, String when) {
    return 'Guardado en $folder · $when';
  }

  @override
  String homeFailedHttp(int code) {
    return 'Error $code · no se pudo descargar';
  }

  @override
  String get homeFailed => 'No se pudo descargar';

  @override
  String get homeFailedSave => 'No se pudo guardar el archivo';

  @override
  String get homeNotFound => 'Error 404 · no se encontró el archivo';

  @override
  String homeFallbackDownload(String kind) {
    return 'Se guardó en Download: $kind no admite esta carpeta';
  }

  @override
  String get homeNotificationsRationale => 'Activa las notificaciones para ver el progreso de las descargas.';

  @override
  String get relativeNow => 'ahora';

  @override
  String relativeMinutes(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String relativeHours(int hours) {
    return 'hace $hours h';
  }

  @override
  String relativeDays(int days) {
    return 'hace $days d';
  }

  @override
  String downloadNotificationRunning(Object filename) {
    return 'Descargando $filename';
  }

  @override
  String get downloadNotificationComplete => 'Descarga completa';

  @override
  String get downloadNotificationError => 'No se pudo descargar';

  @override
  String get shareTitle => 'Guardar con Nombra';

  @override
  String shareFileCount(int count) {
    return '$count archivos';
  }

  @override
  String get shareFinalName => 'Nombre final';

  @override
  String get shareExtensionKept => 'La extensión se mantiene. Toca el nombre para ajustarlo a mano.';

  @override
  String shareRememberDefault(String kind) {
    return 'Recordar como predeterminada para $kind';
  }

  @override
  String get kindImage => 'imágenes';

  @override
  String get kindVideo => 'videos';

  @override
  String get kindAudio => 'audios';

  @override
  String get kindDocument => 'documentos';

  @override
  String get kindOther => 'archivos';

  @override
  String get shareNothing => 'No hay un enlace ni archivos para guardar.';

  @override
  String get shareClose => 'Cerrar';

  @override
  String get shareDownloading => 'Descargando…';

  @override
  String shareDone(String folder) {
    return 'Listo, guardado en $folder';
  }

  @override
  String get shareLeaveHint =>
      'Puedes cerrar esta hoja: el archivo terminará de guardarse la próxima vez que abras Nombra.';

  @override
  String get rulesTitle => 'Reglas';

  @override
  String get rulesSubtitle =>
      'Las reglas activas aparecen en este orden al descargar o compartir. Arrastra para reordenarlas.';

  @override
  String get ruleDefaultBadge => 'Predeterminada';

  @override
  String get ruleNoFolder => 'Sin carpeta · última usada';

  @override
  String ruleToggleLabel(String name) {
    return 'Activar regla $name';
  }

  @override
  String get ruleReorderHandle => 'Arrastrar para reordenar';

  @override
  String get newRule => 'Nueva regla';

  @override
  String get editorTitleEdit => 'Editar regla';

  @override
  String get editorTitleNew => 'Nueva regla';

  @override
  String get editorBackTooltip => 'Volver a Reglas';

  @override
  String get editorRuleName => 'Nombre de la regla';

  @override
  String get editorNameRequired => 'Escribe un nombre';

  @override
  String get editorPattern => 'Patrón';

  @override
  String get editorBackspaceTooltip => 'Borrar último elemento';

  @override
  String get editorTapToInsert => 'Toca para insertar';

  @override
  String get editorAddText => 'Texto…';

  @override
  String get editorTextDialogTitle => 'Texto fijo';

  @override
  String get editorTextDialogHint => 'p. ej. Factura_';

  @override
  String editorExample(String name) {
    return 'Ejemplo · $name';
  }

  @override
  String get editorTransformTitle => 'Transformar nombre';

  @override
  String get editorCase => 'Mayúsculas / minúsculas';

  @override
  String get editorCaseKeep => 'Por defecto';

  @override
  String get editorCaseUpper => 'MAYÚSCULAS';

  @override
  String get editorCaseLower => 'minúsculas';

  @override
  String get editorStripCopy => 'Quitar sufijos de copia «(2)»';

  @override
  String get editorReplaceSpaces => 'Reemplazar espacios';

  @override
  String get editorReplaceWith => 'Reemplazar por';

  @override
  String get editorSpaceDash => 'guion';

  @override
  String get editorSpaceUnderscore => 'guion bajo';

  @override
  String get editorSpaceDot => 'punto';

  @override
  String editorReplaceWithChar(String name) {
    return 'Reemplazar por $name';
  }

  @override
  String get editorSanitize => 'Sanitizar nombre';

  @override
  String get editorSanitizeDesc =>
      'Quita acentos (á → a), emojis y caracteres no válidos en archivos ( / \\ : * ? \" < > | ), y deja solo letras, números, - _ y punto.';

  @override
  String get editorFolderTitle => 'Carpeta de destino';

  @override
  String get editorOptional => '(opcional)';

  @override
  String get editorFolderAlways => 'Los archivos con esta regla se guardan siempre aquí.';

  @override
  String get editorRemoveFolderTooltip => 'Quitar carpeta';

  @override
  String get editorNoFolderTitle => 'Sin carpeta asignada';

  @override
  String get editorNoFolderDesc =>
      'Se usará la última carpeta en la que guardaste, y podrás cambiarla al descargar o compartir.';

  @override
  String get editorPickFolder => 'Elegir carpeta…';

  @override
  String get editorIfExists => 'Si el nombre ya existe';

  @override
  String get editorConflictSuffix => 'Añadir (1)';

  @override
  String get editorConflictReplace => 'Reemplazar';

  @override
  String get editorConflictAsk => 'Preguntar';

  @override
  String get editorDeleteRule => 'Eliminar regla';

  @override
  String get editorDeleteTitle => '¿Eliminar la regla?';

  @override
  String editorDeleteBody(String name) {
    return 'Se eliminará «$name». Esta acción no se puede deshacer.';
  }

  @override
  String get folderPickerTitle => 'Elegir carpeta';

  @override
  String get folderPickerRoot => 'Ubicación';

  @override
  String get folderPickerSubfolder => 'Subcarpeta (opcional)';

  @override
  String get folderPickerSubfolderHint => 'p. ej. Nombra/Facturas';

  @override
  String get folderPickerUse => 'Usar esta carpeta';

  @override
  String get conflictTitle => 'El archivo ya existe';

  @override
  String conflictBody(String name, String folder) {
    return '«$name» ya está en $folder.';
  }

  @override
  String get conflictReplace => 'Reemplazar';

  @override
  String get conflictKeepBoth => 'Conservar ambos';

  @override
  String get seedOriginal => 'Original';

  @override
  String get seedDateName => 'Fecha + nombre';

  @override
  String get seedClean => 'Limpio';

  @override
  String get seedInvoices => 'Facturas';

  @override
  String get seedPhotos => 'Fotos limpias';

  @override
  String get seedInvoicePrefix => 'Factura_';
}
