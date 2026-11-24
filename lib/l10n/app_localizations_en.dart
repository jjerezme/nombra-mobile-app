// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nombra';

  @override
  String get navDownload => 'Download';

  @override
  String get navRules => 'Rules';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get change => 'Change';

  @override
  String get retry => 'Retry';

  @override
  String get delete => 'Delete';

  @override
  String get accept => 'OK';

  @override
  String get modeSaved => 'Saved';

  @override
  String get modeQuick => 'Quick';

  @override
  String get ruleLabel => 'Rule';

  @override
  String get ruleRemembered => 'The last one used is remembered';

  @override
  String get editRules => 'Edit rules';

  @override
  String get noEnabledRules => 'No active rules. Create or enable one in Rules.';

  @override
  String saveIn(String source) {
    return 'Save to · $source';
  }

  @override
  String get folderSourceLastUsed => 'last used';

  @override
  String get folderSourceChosen => 'chosen';

  @override
  String folderSourceRule(String rule) {
    return 'from rule “$rule”';
  }

  @override
  String get changeFolderTooltip => 'Change destination folder';

  @override
  String get homeUrlLabel => 'File URL';

  @override
  String get homePasteTooltip => 'Paste from clipboard';

  @override
  String get homeUrlInvalid => 'Enter a valid http or https URL';

  @override
  String get homeSavedAs => 'It will be saved as';

  @override
  String get homePreviewEmpty => 'Paste a URL to see the name';

  @override
  String get homeDownload => 'Download';

  @override
  String get homeRecents => 'Recent';

  @override
  String get homeRecentsEmpty => 'No downloads yet';

  @override
  String homeProgress(String received, String total, String speed) {
    return '$received of $total · $speed';
  }

  @override
  String homeProgressNoTotal(String received, String speed) {
    return '$received · $speed';
  }

  @override
  String get homeWaiting => 'Waiting…';

  @override
  String get homeFinishing => 'Saving…';

  @override
  String homeSavedIn(String folder, String when) {
    return 'Saved to $folder · $when';
  }

  @override
  String homeFailedHttp(int code) {
    return 'Error $code · could not download';
  }

  @override
  String get homeFailed => 'Could not download';

  @override
  String get homeFailedSave => 'Could not save the file';

  @override
  String get homeNotFound => 'Error 404 · file not found';

  @override
  String homeFallbackDownload(String kind) {
    return 'Saved to Download: $kind cannot go in this folder';
  }

  @override
  String get homeNotificationsRationale => 'Turn on notifications to see download progress.';

  @override
  String get relativeNow => 'now';

  @override
  String relativeMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String relativeHours(int hours) {
    return '$hours h ago';
  }

  @override
  String relativeDays(int days) {
    return '$days d ago';
  }

  @override
  String downloadNotificationRunning(Object filename) {
    return 'Downloading $filename';
  }

  @override
  String get downloadNotificationError => 'Could not download';

  @override
  String get shareTitle => 'Save with Nombra';

  @override
  String shareFileCount(int count) {
    return '$count files';
  }

  @override
  String get shareFinalName => 'Final name';

  @override
  String get shareExtensionKept => 'The extension is kept. Tap the name to adjust it by hand.';

  @override
  String shareRememberDefault(String kind) {
    return 'Remember as default for $kind';
  }

  @override
  String get kindImage => 'images';

  @override
  String get kindVideo => 'videos';

  @override
  String get kindAudio => 'audio files';

  @override
  String get kindDocument => 'documents';

  @override
  String get kindOther => 'files';

  @override
  String get shareNothing => 'There is no link or file to save.';

  @override
  String get shareClose => 'Close';

  @override
  String get shareDownloading => 'Downloading…';

  @override
  String shareDone(String folder) {
    return 'Done, saved to $folder';
  }

  @override
  String get shareLeaveHint => 'You can close this sheet: the file will finish saving the next time you open Nombra.';

  @override
  String get rulesTitle => 'Rules';

  @override
  String get rulesSubtitle => 'Active rules are offered when downloading or sharing, sorted by name.';

  @override
  String get ruleDefaultBadge => 'Default';

  @override
  String get ruleNoFolder => 'No folder · last used';

  @override
  String ruleToggleLabel(String name) {
    return 'Turn on rule $name';
  }

  @override
  String get newRule => 'New rule';

  @override
  String get editorTitleEdit => 'Edit rule';

  @override
  String get editorTitleNew => 'New rule';

  @override
  String get editorBackTooltip => 'Back to Rules';

  @override
  String get editorRuleName => 'Rule name';

  @override
  String get editorNameRequired => 'Enter a name';

  @override
  String get editorPattern => 'Pattern';

  @override
  String get editorBackspaceTooltip => 'Delete last item';

  @override
  String get editorTapToInsert => 'Tap to insert';

  @override
  String get editorAddText => 'Text…';

  @override
  String get editorTextDialogTitle => 'Fixed text';

  @override
  String get editorTextDialogHint => 'e.g. Invoice_';

  @override
  String editorExample(String name) {
    return 'Example · $name';
  }

  @override
  String get editorTransformTitle => 'Transform name';

  @override
  String get editorCase => 'Upper / lower case';

  @override
  String get editorCaseKeep => 'Default';

  @override
  String get editorCaseUpper => 'UPPERCASE';

  @override
  String get editorCaseLower => 'lowercase';

  @override
  String get editorStripCopy => 'Remove copy suffixes “(2)”';

  @override
  String get editorReplaceSpaces => 'Replace spaces';

  @override
  String get editorReplaceWith => 'Replace with';

  @override
  String get editorSpaceDash => 'hyphen';

  @override
  String get editorSpaceUnderscore => 'underscore';

  @override
  String get editorSpaceDot => 'dot';

  @override
  String editorReplaceWithChar(String name) {
    return 'Replace with $name';
  }

  @override
  String get editorSanitize => 'Sanitize name';

  @override
  String get editorSanitizeDesc =>
      'Removes accents (á → a), emojis and characters not valid in file names ( / \\ : * ? \" < > | ), keeping only letters, digits, - _ and dots.';

  @override
  String get editorFolderTitle => 'Destination folder';

  @override
  String get editorOptional => '(optional)';

  @override
  String get editorFolderAlways => 'Files with this rule are always saved here.';

  @override
  String get editorRemoveFolderTooltip => 'Remove folder';

  @override
  String get editorNoFolderTitle => 'No folder assigned';

  @override
  String get editorNoFolderDesc =>
      'The last folder you saved to will be used, and you can change it when you download or share.';

  @override
  String get editorPickFolder => 'Choose folder…';

  @override
  String get editorIfExists => 'If the name already exists';

  @override
  String get editorConflictSuffix => 'Add (1)';

  @override
  String get editorConflictReplace => 'Replace';

  @override
  String get editorConflictAsk => 'Ask';

  @override
  String get editorDeleteRule => 'Delete rule';

  @override
  String get editorDeleteTitle => 'Delete the rule?';

  @override
  String editorDeleteBody(String name) {
    return '“$name” will be deleted. This cannot be undone.';
  }

  @override
  String get folderPickerTitle => 'Choose folder';

  @override
  String get folderPickerRoot => 'Location';

  @override
  String get folderPickerSubfolder => 'Subfolder (optional)';

  @override
  String get folderPickerUse => 'Use this folder';

  @override
  String get conflictTitle => 'The file already exists';

  @override
  String conflictBody(String name, String folder) {
    return '“$name” is already in $folder.';
  }

  @override
  String get conflictReplace => 'Replace';

  @override
  String get conflictKeepBoth => 'Keep both';

  @override
  String get errRequired => 'This field is required';

  @override
  String errTooLong(int max) {
    return 'At most $max characters';
  }

  @override
  String get errInvalidChars => 'Do not use /  : * ? \" < > |';

  @override
  String get errDuplicateName => 'A rule with that name already exists';

  @override
  String get errPatternEmpty => 'Add at least one item to the pattern';

  @override
  String get errSubfolderInvalid => 'Invalid subfolder: do not use .. or : * ? \" < > |';

  @override
  String get editorDiscardTitle => 'Discard changes?';

  @override
  String get editorDiscardBody => 'You have unsaved changes in this rule.';

  @override
  String get discard => 'Discard';

  @override
  String get editorKeepEditing => 'Keep editing';

  @override
  String get ruleNotFound => 'This rule no longer exists';

  @override
  String get rulesEmptyTitle => 'You have no rules yet';

  @override
  String get rulesEmptyBody => 'Create a rule to rename your downloads with a pattern.';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Appearance, language, downloads and data.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get settingsDownloads => 'Downloads';

  @override
  String get settingsNamingMode => 'Naming mode';

  @override
  String get settingsNamingModeHint =>
      'How files are named by default: no rule, a saved rule, or a quick pattern that is kept.';

  @override
  String get settingsDefaultFolder => 'Default folder';

  @override
  String get settingsDefaultFolderHint => 'Used when the rule does not set a folder.';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsForgetRemembered => 'Forget remembered rules';

  @override
  String get settingsForgetRememberedHint => 'Removes the default rule per file type and the last one used.';

  @override
  String get settingsClearHistory => 'Clear download history';

  @override
  String get settingsClearHistoryHint => 'Files already saved are not deleted.';

  @override
  String get settingsClearRules => 'Delete all rules';

  @override
  String get settingsClearRulesHint => 'Start over with no rules.';

  @override
  String get settingsConfirmForgetTitle => 'Forget remembered rules?';

  @override
  String get settingsConfirmForgetBody => 'The rule will be picked automatically again.';

  @override
  String get settingsConfirmHistoryTitle => 'Clear the history?';

  @override
  String get settingsConfirmHistoryBody =>
      'Finished and failed downloads are removed from the list. Saved files are not deleted.';

  @override
  String get settingsConfirmRulesTitle => 'Delete all rules?';

  @override
  String settingsConfirmRulesBody(int count) {
    return '$count rules will be deleted. This cannot be undone.';
  }

  @override
  String get settingsDone => 'Done';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get notificationChannelName => 'Saved files';

  @override
  String get notificationSavedTitle => 'Saved';

  @override
  String notificationSavedBody(String name, String folder) {
    return '$name · $folder';
  }

  @override
  String get notificationSaveFailedTitle => 'Could not save';

  @override
  String get quickNext => 'Next number';

  @override
  String get errInvalidNumber => 'Enter a whole number greater than 0';

  @override
  String get quickNextHint =>
      'With the number item in the pattern, the number goes on as long as you do not change the pattern; if you do, it starts again at 1.';

  @override
  String get homeClearRecents => 'Clear';

  @override
  String get settingsShowRecents => 'Show recent files';

  @override
  String get settingsShowRecentsHint => 'Lists the saved files in Download. Downloads in progress are always shown.';

  @override
  String editorMaxTokens(int max) {
    return 'At most $max items';
  }

  @override
  String get editorSpaceToken => 'Space';

  @override
  String get editorDigitsTitle => 'Digits of the number';

  @override
  String get editorDigitsLess => 'Fewer digits';

  @override
  String get editorDigitsMore => 'More digits';

  @override
  String editorDigitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count digits', one: '$count digit');
    return '$_temp0';
  }

  @override
  String editorDigitsExample(String example) {
    return 'Example: $example';
  }

  @override
  String get ruleOptCopySuffix => 'No (2) suffix';

  @override
  String ruleOptSpaces(String char) {
    return 'Spaces → $char';
  }

  @override
  String get ruleOptSanitize => 'Clean name';

  @override
  String ruleOptConflict(String policy) {
    return 'If it exists: $policy';
  }

  @override
  String get modeNone => 'None';

  @override
  String get modeNoneHint => 'The file is saved with its original name, without applying any rule.';
}
