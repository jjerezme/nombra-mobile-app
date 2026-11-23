import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es')];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Nombra'**
  String get appName;

  /// No description provided for @navDownload.
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get navDownload;

  /// No description provided for @navRules.
  ///
  /// In es, this message translates to:
  /// **'Reglas'**
  String get navRules;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @change.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get change;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @modeSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardada'**
  String get modeSaved;

  /// No description provided for @modeQuick.
  ///
  /// In es, this message translates to:
  /// **'Rápida'**
  String get modeQuick;

  /// No description provided for @ruleLabel.
  ///
  /// In es, this message translates to:
  /// **'Regla'**
  String get ruleLabel;

  /// No description provided for @ruleRemembered.
  ///
  /// In es, this message translates to:
  /// **'Se recuerda la última usada'**
  String get ruleRemembered;

  /// No description provided for @editRules.
  ///
  /// In es, this message translates to:
  /// **'Editar reglas'**
  String get editRules;

  /// No description provided for @noEnabledRules.
  ///
  /// In es, this message translates to:
  /// **'No hay reglas activas. Actívalas en Reglas.'**
  String get noEnabledRules;

  /// No description provided for @prefix.
  ///
  /// In es, this message translates to:
  /// **'Prefijo'**
  String get prefix;

  /// No description provided for @suffix.
  ///
  /// In es, this message translates to:
  /// **'Sufijo'**
  String get suffix;

  /// No description provided for @prefixHint.
  ///
  /// In es, this message translates to:
  /// **'p. ej. acme_'**
  String get prefixHint;

  /// No description provided for @suffixHint.
  ///
  /// In es, this message translates to:
  /// **'p. ej. _v2'**
  String get suffixHint;

  /// No description provided for @saveIn.
  ///
  /// In es, this message translates to:
  /// **'Guardar en · {source}'**
  String saveIn(String source);

  /// No description provided for @folderSourceLastUsed.
  ///
  /// In es, this message translates to:
  /// **'última usada'**
  String get folderSourceLastUsed;

  /// No description provided for @folderSourceChosen.
  ///
  /// In es, this message translates to:
  /// **'elegida'**
  String get folderSourceChosen;

  /// No description provided for @folderSourceRule.
  ///
  /// In es, this message translates to:
  /// **'según regla «{rule}»'**
  String folderSourceRule(String rule);

  /// No description provided for @changeFolderTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar carpeta de destino'**
  String get changeFolderTooltip;

  /// No description provided for @homeUrlLabel.
  ///
  /// In es, this message translates to:
  /// **'URL del archivo'**
  String get homeUrlLabel;

  /// No description provided for @homePasteTooltip.
  ///
  /// In es, this message translates to:
  /// **'Pegar del portapapeles'**
  String get homePasteTooltip;

  /// No description provided for @homeUrlInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce una URL http o https válida'**
  String get homeUrlInvalid;

  /// No description provided for @homeSavedAs.
  ///
  /// In es, this message translates to:
  /// **'Se guardará como'**
  String get homeSavedAs;

  /// No description provided for @homePreviewEmpty.
  ///
  /// In es, this message translates to:
  /// **'Pega una URL para ver el nombre'**
  String get homePreviewEmpty;

  /// No description provided for @homeDownload.
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get homeDownload;

  /// No description provided for @homeRecents.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get homeRecents;

  /// No description provided for @homeRecentsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay descargas'**
  String get homeRecentsEmpty;

  /// No description provided for @homeProgress.
  ///
  /// In es, this message translates to:
  /// **'{received} de {total} · {speed}'**
  String homeProgress(String received, String total, String speed);

  /// No description provided for @homeProgressNoTotal.
  ///
  /// In es, this message translates to:
  /// **'{received} · {speed}'**
  String homeProgressNoTotal(String received, String speed);

  /// No description provided for @homeWaiting.
  ///
  /// In es, this message translates to:
  /// **'En espera…'**
  String get homeWaiting;

  /// No description provided for @homeFinishing.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get homeFinishing;

  /// No description provided for @homeSavedIn.
  ///
  /// In es, this message translates to:
  /// **'Guardado en {folder} · {when}'**
  String homeSavedIn(String folder, String when);

  /// No description provided for @homeFailedHttp.
  ///
  /// In es, this message translates to:
  /// **'Error {code} · no se pudo descargar'**
  String homeFailedHttp(int code);

  /// No description provided for @homeFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar'**
  String get homeFailed;

  /// No description provided for @homeFailedSave.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el archivo'**
  String get homeFailedSave;

  /// No description provided for @homeNotFound.
  ///
  /// In es, this message translates to:
  /// **'Error 404 · no se encontró el archivo'**
  String get homeNotFound;

  /// No description provided for @homeFallbackDownload.
  ///
  /// In es, this message translates to:
  /// **'Se guardó en Download: {kind} no admite esta carpeta'**
  String homeFallbackDownload(String kind);

  /// No description provided for @homeNotificationsRationale.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones para ver el progreso de las descargas.'**
  String get homeNotificationsRationale;

  /// No description provided for @relativeNow.
  ///
  /// In es, this message translates to:
  /// **'ahora'**
  String get relativeNow;

  /// No description provided for @relativeMinutes.
  ///
  /// In es, this message translates to:
  /// **'hace {minutes} min'**
  String relativeMinutes(int minutes);

  /// No description provided for @relativeHours.
  ///
  /// In es, this message translates to:
  /// **'hace {hours} h'**
  String relativeHours(int hours);

  /// No description provided for @relativeDays.
  ///
  /// In es, this message translates to:
  /// **'hace {days} d'**
  String relativeDays(int days);

  /// No description provided for @downloadNotificationRunning.
  ///
  /// In es, this message translates to:
  /// **'Descargando {filename}'**
  String downloadNotificationRunning(Object filename);

  /// No description provided for @downloadNotificationComplete.
  ///
  /// In es, this message translates to:
  /// **'Descarga completa'**
  String get downloadNotificationComplete;

  /// No description provided for @downloadNotificationError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar'**
  String get downloadNotificationError;

  /// No description provided for @shareTitle.
  ///
  /// In es, this message translates to:
  /// **'Guardar con Nombra'**
  String get shareTitle;

  /// No description provided for @shareFileCount.
  ///
  /// In es, this message translates to:
  /// **'{count} archivos'**
  String shareFileCount(int count);

  /// No description provided for @shareFinalName.
  ///
  /// In es, this message translates to:
  /// **'Nombre final'**
  String get shareFinalName;

  /// No description provided for @shareExtensionKept.
  ///
  /// In es, this message translates to:
  /// **'La extensión se mantiene. Toca el nombre para ajustarlo a mano.'**
  String get shareExtensionKept;

  /// No description provided for @shareRememberDefault.
  ///
  /// In es, this message translates to:
  /// **'Recordar como predeterminada para {kind}'**
  String shareRememberDefault(String kind);

  /// No description provided for @kindImage.
  ///
  /// In es, this message translates to:
  /// **'imágenes'**
  String get kindImage;

  /// No description provided for @kindVideo.
  ///
  /// In es, this message translates to:
  /// **'videos'**
  String get kindVideo;

  /// No description provided for @kindAudio.
  ///
  /// In es, this message translates to:
  /// **'audios'**
  String get kindAudio;

  /// No description provided for @kindDocument.
  ///
  /// In es, this message translates to:
  /// **'documentos'**
  String get kindDocument;

  /// No description provided for @kindOther.
  ///
  /// In es, this message translates to:
  /// **'archivos'**
  String get kindOther;

  /// No description provided for @shareNothing.
  ///
  /// In es, this message translates to:
  /// **'No hay un enlace ni archivos para guardar.'**
  String get shareNothing;

  /// No description provided for @shareClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get shareClose;

  /// No description provided for @shareDownloading.
  ///
  /// In es, this message translates to:
  /// **'Descargando…'**
  String get shareDownloading;

  /// No description provided for @shareDone.
  ///
  /// In es, this message translates to:
  /// **'Listo, guardado en {folder}'**
  String shareDone(String folder);

  /// No description provided for @shareLeaveHint.
  ///
  /// In es, this message translates to:
  /// **'Puedes cerrar esta hoja: el archivo terminará de guardarse la próxima vez que abras Nombra.'**
  String get shareLeaveHint;

  /// No description provided for @rulesTitle.
  ///
  /// In es, this message translates to:
  /// **'Reglas'**
  String get rulesTitle;

  /// No description provided for @rulesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las reglas activas aparecen en este orden al descargar o compartir. Arrastra para reordenarlas.'**
  String get rulesSubtitle;

  /// No description provided for @ruleDefaultBadge.
  ///
  /// In es, this message translates to:
  /// **'Predeterminada'**
  String get ruleDefaultBadge;

  /// No description provided for @ruleNoFolder.
  ///
  /// In es, this message translates to:
  /// **'Sin carpeta · última usada'**
  String get ruleNoFolder;

  /// No description provided for @ruleToggleLabel.
  ///
  /// In es, this message translates to:
  /// **'Activar regla {name}'**
  String ruleToggleLabel(String name);

  /// No description provided for @ruleReorderHandle.
  ///
  /// In es, this message translates to:
  /// **'Arrastrar para reordenar'**
  String get ruleReorderHandle;

  /// No description provided for @newRule.
  ///
  /// In es, this message translates to:
  /// **'Nueva regla'**
  String get newRule;

  /// No description provided for @editorTitleEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar regla'**
  String get editorTitleEdit;

  /// No description provided for @editorTitleNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva regla'**
  String get editorTitleNew;

  /// No description provided for @editorBackTooltip.
  ///
  /// In es, this message translates to:
  /// **'Volver a Reglas'**
  String get editorBackTooltip;

  /// No description provided for @editorRuleName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la regla'**
  String get editorRuleName;

  /// No description provided for @editorNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre'**
  String get editorNameRequired;

  /// No description provided for @editorPattern.
  ///
  /// In es, this message translates to:
  /// **'Patrón'**
  String get editorPattern;

  /// No description provided for @editorBackspaceTooltip.
  ///
  /// In es, this message translates to:
  /// **'Borrar último elemento'**
  String get editorBackspaceTooltip;

  /// No description provided for @editorTapToInsert.
  ///
  /// In es, this message translates to:
  /// **'Toca para insertar'**
  String get editorTapToInsert;

  /// No description provided for @editorAddText.
  ///
  /// In es, this message translates to:
  /// **'Texto…'**
  String get editorAddText;

  /// No description provided for @editorTextDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Texto fijo'**
  String get editorTextDialogTitle;

  /// No description provided for @editorTextDialogHint.
  ///
  /// In es, this message translates to:
  /// **'p. ej. Factura_'**
  String get editorTextDialogHint;

  /// No description provided for @editorExample.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo · {name}'**
  String editorExample(String name);

  /// No description provided for @editorTransformTitle.
  ///
  /// In es, this message translates to:
  /// **'Transformar nombre'**
  String get editorTransformTitle;

  /// No description provided for @editorCase.
  ///
  /// In es, this message translates to:
  /// **'Mayúsculas / minúsculas'**
  String get editorCase;

  /// No description provided for @editorCaseKeep.
  ///
  /// In es, this message translates to:
  /// **'Por defecto'**
  String get editorCaseKeep;

  /// No description provided for @editorCaseUpper.
  ///
  /// In es, this message translates to:
  /// **'MAYÚSCULAS'**
  String get editorCaseUpper;

  /// No description provided for @editorCaseLower.
  ///
  /// In es, this message translates to:
  /// **'minúsculas'**
  String get editorCaseLower;

  /// No description provided for @editorStripCopy.
  ///
  /// In es, this message translates to:
  /// **'Quitar sufijos de copia «(2)»'**
  String get editorStripCopy;

  /// No description provided for @editorReplaceSpaces.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar espacios'**
  String get editorReplaceSpaces;

  /// No description provided for @editorReplaceWith.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar por'**
  String get editorReplaceWith;

  /// No description provided for @editorSpaceDash.
  ///
  /// In es, this message translates to:
  /// **'guion'**
  String get editorSpaceDash;

  /// No description provided for @editorSpaceUnderscore.
  ///
  /// In es, this message translates to:
  /// **'guion bajo'**
  String get editorSpaceUnderscore;

  /// No description provided for @editorSpaceDot.
  ///
  /// In es, this message translates to:
  /// **'punto'**
  String get editorSpaceDot;

  /// No description provided for @editorReplaceWithChar.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar por {name}'**
  String editorReplaceWithChar(String name);

  /// No description provided for @editorSanitize.
  ///
  /// In es, this message translates to:
  /// **'Sanitizar nombre'**
  String get editorSanitize;

  /// No description provided for @editorSanitizeDesc.
  ///
  /// In es, this message translates to:
  /// **'Quita acentos (á → a), emojis y caracteres no válidos en archivos ( / \\ : * ? \" < > | ), y deja solo letras, números, - _ y punto.'**
  String get editorSanitizeDesc;

  /// No description provided for @editorFolderTitle.
  ///
  /// In es, this message translates to:
  /// **'Carpeta de destino'**
  String get editorFolderTitle;

  /// No description provided for @editorOptional.
  ///
  /// In es, this message translates to:
  /// **'(opcional)'**
  String get editorOptional;

  /// No description provided for @editorFolderAlways.
  ///
  /// In es, this message translates to:
  /// **'Los archivos con esta regla se guardan siempre aquí.'**
  String get editorFolderAlways;

  /// No description provided for @editorRemoveFolderTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar carpeta'**
  String get editorRemoveFolderTooltip;

  /// No description provided for @editorNoFolderTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin carpeta asignada'**
  String get editorNoFolderTitle;

  /// No description provided for @editorNoFolderDesc.
  ///
  /// In es, this message translates to:
  /// **'Se usará la última carpeta en la que guardaste, y podrás cambiarla al descargar o compartir.'**
  String get editorNoFolderDesc;

  /// No description provided for @editorPickFolder.
  ///
  /// In es, this message translates to:
  /// **'Elegir carpeta…'**
  String get editorPickFolder;

  /// No description provided for @editorIfExists.
  ///
  /// In es, this message translates to:
  /// **'Si el nombre ya existe'**
  String get editorIfExists;

  /// No description provided for @editorConflictSuffix.
  ///
  /// In es, this message translates to:
  /// **'Añadir (1)'**
  String get editorConflictSuffix;

  /// No description provided for @editorConflictReplace.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar'**
  String get editorConflictReplace;

  /// No description provided for @editorConflictAsk.
  ///
  /// In es, this message translates to:
  /// **'Preguntar'**
  String get editorConflictAsk;

  /// No description provided for @editorDeleteRule.
  ///
  /// In es, this message translates to:
  /// **'Eliminar regla'**
  String get editorDeleteRule;

  /// No description provided for @editorDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar la regla?'**
  String get editorDeleteTitle;

  /// No description provided for @editorDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se eliminará «{name}». Esta acción no se puede deshacer.'**
  String editorDeleteBody(String name);

  /// No description provided for @folderPickerTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegir carpeta'**
  String get folderPickerTitle;

  /// No description provided for @folderPickerRoot.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get folderPickerRoot;

  /// No description provided for @folderPickerSubfolder.
  ///
  /// In es, this message translates to:
  /// **'Subcarpeta (opcional)'**
  String get folderPickerSubfolder;

  /// No description provided for @folderPickerSubfolderHint.
  ///
  /// In es, this message translates to:
  /// **'p. ej. Nombra/Facturas'**
  String get folderPickerSubfolderHint;

  /// No description provided for @folderPickerUse.
  ///
  /// In es, this message translates to:
  /// **'Usar esta carpeta'**
  String get folderPickerUse;

  /// No description provided for @conflictTitle.
  ///
  /// In es, this message translates to:
  /// **'El archivo ya existe'**
  String get conflictTitle;

  /// No description provided for @conflictBody.
  ///
  /// In es, this message translates to:
  /// **'«{name}» ya está en {folder}.'**
  String conflictBody(String name, String folder);

  /// No description provided for @conflictReplace.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar'**
  String get conflictReplace;

  /// No description provided for @conflictKeepBoth.
  ///
  /// In es, this message translates to:
  /// **'Conservar ambos'**
  String get conflictKeepBoth;

  /// No description provided for @seedOriginal.
  ///
  /// In es, this message translates to:
  /// **'Original'**
  String get seedOriginal;

  /// No description provided for @seedDateName.
  ///
  /// In es, this message translates to:
  /// **'Fecha + nombre'**
  String get seedDateName;

  /// No description provided for @seedClean.
  ///
  /// In es, this message translates to:
  /// **'Limpio'**
  String get seedClean;

  /// No description provided for @seedInvoices.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get seedInvoices;

  /// No description provided for @seedPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos limpias'**
  String get seedPhotos;

  /// No description provided for @seedInvoicePrefix.
  ///
  /// In es, this message translates to:
  /// **'Factura_'**
  String get seedInvoicePrefix;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
