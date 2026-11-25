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
  String get modeQuick => 'Personalizado';

  @override
  String get ruleAdd => 'Agregar';

  @override
  String get changeFolderTooltip => 'Cambiar carpeta de destino';

  @override
  String get homeUrlLabel => 'URL del archivo';

  @override
  String get homePasteTooltip => 'Pegar del portapapeles';

  @override
  String get homeUrlInvalid => 'Introduce una URL https válida';

  @override
  String get homeUrlInsecure => 'Solo se admiten enlaces https (cifrados)';

  @override
  String get homeSavedAs => 'Se guardará como';

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
  String get shareInsecure => 'Solo se pueden guardar enlaces https (cifrados).';

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
  String get rulesSubtitle => 'Las reglas activas se ofrecen al descargar o compartir, ordenadas por nombre.';

  @override
  String get ruleDefaultBadge => 'Predeterminada';

  @override
  String get ruleNoFolder => 'Sin carpeta · última usada';

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
  String get folderPickerUse => 'Usar esta carpeta';

  @override
  String get folderPickerSavedIn => 'Se guardará en';

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
  String get errRequired => 'Este campo es obligatorio';

  @override
  String errTooLong(int max) {
    return 'Máximo $max caracteres';
  }

  @override
  String get errInvalidChars => 'No uses /  : * ? \" < > |';

  @override
  String get errDuplicateName => 'Ya existe una regla con ese nombre';

  @override
  String get errPatternEmpty => 'Agrega al menos un elemento al patrón';

  @override
  String get errSubfolderInvalid => 'Subcarpeta no válida: no uses .. ni : * ? \" < > |';

  @override
  String get editorDiscardTitle => '¿Descartar cambios?';

  @override
  String get editorDiscardBody => 'Tienes cambios sin guardar en esta regla.';

  @override
  String get discard => 'Descartar';

  @override
  String get editorKeepEditing => 'Seguir editando';

  @override
  String get ruleNotFound => 'Esta regla ya no existe';

  @override
  String get rulesEmptyTitle => 'Aún no tienes reglas';

  @override
  String get rulesEmptyBody => 'Crea una regla para renombrar tus descargas con un patrón.';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle => 'Apariencia, idioma, descargas y datos.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get settingsDownloads => 'Descargas';

  @override
  String get settingsDefaultFolder => 'Carpeta predeterminada';

  @override
  String get settingsDefaultFolderHint => 'Se usa cuando la regla no define una carpeta.';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsForgetRemembered => 'Olvidar la última regla usada';

  @override
  String get settingsForgetRememberedHint => 'Quita la última regla usada y se vuelve a elegir automáticamente.';

  @override
  String get settingsClearHistory => 'Borrar historial de descargas';

  @override
  String get settingsClearHistoryHint => 'No borra los archivos ya guardados.';

  @override
  String get settingsClearRules => 'Borrar todas las reglas';

  @override
  String get settingsClearRulesHint => 'Empiezas de nuevo, sin reglas.';

  @override
  String get settingsConfirmForgetTitle => '¿Olvidar la última regla usada?';

  @override
  String get settingsConfirmForgetBody => 'La regla se volverá a elegir automáticamente.';

  @override
  String get settingsConfirmHistoryTitle => '¿Borrar el historial?';

  @override
  String get settingsConfirmHistoryBody =>
      'Se quitan de la lista las descargas terminadas y con error. Los archivos guardados no se borran.';

  @override
  String get settingsConfirmRulesTitle => '¿Borrar todas las reglas?';

  @override
  String settingsConfirmRulesBody(int count) {
    return 'Se eliminan $count reglas. No se puede deshacer.';
  }

  @override
  String get settingsDone => 'Listo';

  @override
  String settingsVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get notificationChannelName => 'Archivos guardados';

  @override
  String get notificationSavedTitle => 'Guardado';

  @override
  String notificationSavedBody(String name, String folder) {
    return '$name · $folder';
  }

  @override
  String get notificationSaveFailedTitle => 'No se pudo guardar';

  @override
  String get quickNext => 'Siguiente número';

  @override
  String get quickNextReset => 'Reiniciar a 1';

  @override
  String get errInvalidNumber => 'Escribe un número entero mayor que 0';

  @override
  String get quickNextHint =>
      'Con el elemento de número en el patrón, el número sigue mientras no cambies el patrón; si lo cambias, vuelve a 1.';

  @override
  String get homeClearRecents => 'Borrar';

  @override
  String get settingsShowRecents => 'Mostrar archivos recientes';

  @override
  String get settingsShowRecentsHint =>
      'Lista en Descargar los archivos guardados. Las descargas en curso siempre se ven.';

  @override
  String get editorSpaceToken => 'Espacio';

  @override
  String get editorDigitsTitle => 'Dígitos del número';

  @override
  String get editorDigitsLess => 'Menos dígitos';

  @override
  String get editorDigitsMore => 'Más dígitos';

  @override
  String editorDigitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dígitos', one: '$count dígito');
    return '$_temp0';
  }

  @override
  String editorDigitsExample(String example) {
    return 'Ejemplo: $example';
  }

  @override
  String get ruleOptCopySuffix => 'Sin sufijo (2)';

  @override
  String ruleOptSpaces(String char) {
    return 'Espacios → $char';
  }

  @override
  String get ruleOptSanitize => 'Nombre limpio';

  @override
  String ruleOptConflict(String policy) {
    return 'Si existe: $policy';
  }

  @override
  String get modeNoneHint => 'El archivo se guarda con su nombre original, sin aplicar ninguna regla.';

  @override
  String get ruleApply => 'Aplicar una regla';

  @override
  String get homeActions => 'Más acciones';

  @override
  String get homeOpen => 'Abrir';

  @override
  String get homeRemove => 'Quitar de la lista';

  @override
  String get homeOpenFailed => 'No se pudo abrir el archivo. Puede que lo hayan movido o borrado.';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get accountBody => 'Inicia sesión con Google para respaldar tus reglas y recuperarlas en otro teléfono.';

  @override
  String get accountSignIn => 'Continuar con Google';

  @override
  String get accountSignInFailed => 'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get accountUnavailable => 'El respaldo no está disponible en esta compilación.';

  @override
  String get accountSyncing => 'Respaldando tus reglas…';

  @override
  String get accountUpToDate => 'Reglas respaldadas';

  @override
  String get accountError => 'No se pudo respaldar tus reglas. Revisa tu conexión.';

  @override
  String get accountRetry => 'Reintentar';

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get accountSignOutHint => 'Tus reglas se quedan en este teléfono y en la nube.';

  @override
  String get accountDeleteBackup => 'Borrar respaldo y cerrar sesión';

  @override
  String get accountDeleteBackupHint => 'Elimina tus reglas de la nube. Las de este teléfono no se tocan.';

  @override
  String get accountConfirmDeleteTitle => '¿Borrar el respaldo?';

  @override
  String get accountConfirmDeleteBody =>
      'Se eliminarán tus reglas de la nube y se cerrará la sesión. Las reglas de este teléfono se conservan.';

  @override
  String get accountDeleteFailed => 'No se pudo borrar el respaldo. Revisa tu conexión.';

  @override
  String get ruleChoicesLabel => 'Reglas de nombrado';

  @override
  String get accountBusySigningIn => 'Iniciando sesión…';

  @override
  String get accountBusySigningOut => 'Cerrando sesión…';

  @override
  String get accountBusyDeleting => 'Borrando el respaldo…';

  @override
  String get editorExtensionLocked => 'La extensión original del archivo se conserva y no se puede editar.';
}
