import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/current_l10n.dart';
import '../../core/providers.dart';
import '../../core/validation.dart';
import '../rules/domain/file_kind.dart';
import '../rules/domain/rename_rule.dart';
import '../rules/domain/storage_root.dart';

enum NamingMode { saved, quick }

/// Light, dark or follow the system.
enum AppThemeMode { system, light, dark }

/// Languages the app is translated to; a null language code in the settings means "follow the system".
const List<String> supportedLanguageCodes = ['es', 'en'];

/// The quick pattern a fresh install starts with: the original name.
const List<String> defaultQuickTokens = [PatternTokens.name];

/// Builds the quick pattern of the first quick version (prefix, original name, number, suffix) so nothing is lost
/// for users who had set it up.
List<String> legacyQuickTokens({
  required String prefix,
  required String suffix,
  required bool replaceName,
  required bool sequence,
  required int digits,
}) {
  final tokens = <String>[
    if (prefix.isNotEmpty) prefix,
    if (!replaceName) PatternTokens.name,
    if (sequence) '{n:$digits}',
    if (suffix.isNotEmpty) suffix,
  ];
  return tokens.isEmpty ? defaultQuickTokens : tokens;
}

/// What the user last chose; Home and the share sheet start from it.
///
/// The quick pattern ([quickTokens]) is not a saved rule: it is the one pattern kept for quick mode and used every
/// time a file is saved in that mode.
class AppSettings {
  AppSettings({
    this.mode = NamingMode.saved,
    this.lastRuleId,
    DestinationFolder? lastFolder,
    this.defaultRuleByKind = const {},
    this.languageCode,
    this.themeMode = AppThemeMode.system,
    this.quickTokens = defaultQuickTokens,
    this.quickNext = 1,
    this.quickNextKey,
    this.showRecents = true,
  }) : lastFolder = lastFolder ?? DestinationFolder(StorageRoot.download);

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    mode: NamingMode.values.firstWhere((mode) => mode.name == json['mode'], orElse: () => NamingMode.saved),
    lastRuleId: json['lastRuleId'] as String?,
    lastFolder: json['lastFolder'] == null
        ? null
        : DestinationFolder.fromJson(json['lastFolder'] as Map<String, dynamic>),
    defaultRuleByKind: (json['defaultRuleByKind'] as Map<String, dynamic>? ?? {}).cast<String, String>(),
    languageCode: supportedLanguageCodes.contains(json['languageCode']) ? json['languageCode'] as String : null,
    themeMode: AppThemeMode.values.firstWhere(
      (mode) => mode.name == json['themeMode'],
      orElse: () => AppThemeMode.system,
    ),
    quickTokens: json['quickTokens'] == null
        ? legacyQuickTokens(
            prefix: json['prefix'] as String? ?? '',
            suffix: json['suffix'] as String? ?? '',
            replaceName: json['quickReplaceName'] as bool? ?? false,
            sequence: json['quickSequence'] as bool? ?? false,
            digits: ((json['quickDigits'] as int?) ?? 3).clamp(1, 9),
          )
        : (json['quickTokens'] as List<dynamic>).cast<String>(),
    quickNext: ((json['quickNext'] as int?) ?? 1).clamp(1, maxSequenceNumber),
    quickNextKey: json['quickNextKey'] as String?,
    showRecents: json['showRecents'] as bool? ?? true,
  );

  final NamingMode mode;
  final String? lastRuleId;
  final DestinationFolder lastFolder;

  /// `FileKind.name` -> rule id, set with "remember as default for images".
  final Map<String, String> defaultRuleByKind;

  /// `es` or `en`; null follows the system language.
  final String? languageCode;
  final AppThemeMode themeMode;

  /// Pattern of quick mode, built from the same tokens as a rule (`{name}`, `{date}`, `{n:3}`, free text...).
  final List<String> quickTokens;

  /// Number the next file gets, valid while [quickNextKey] equals [quickSignature].
  final int quickNext;
  final String? quickNextKey;

  /// Whether Download lists the files saved before (finished and failed downloads). Downloads in progress always show.
  final bool showRecents;

  /// Identifies the quick pattern: the sequence goes on only while the pattern does not change.
  String get quickSignature => quickTokens.join('\u0001');

  /// Whether the quick pattern has a `{n:3}` token, that is, whether it numbers the files.
  bool get quickUsesCounter => quickTokens.any(PatternTokens.isCounter);

  /// The number the next file gets: the saved one while the pattern is the same, otherwise it starts again at 1.
  int get nextQuickNumber => quickNextKey == quickSignature ? quickNext : 1;

  AppSettings copyWith({
    NamingMode? mode,
    String? lastRuleId,
    DestinationFolder? lastFolder,
    Map<String, String>? defaultRuleByKind,
    String? languageCode,
    bool clearLanguage = false,
    AppThemeMode? themeMode,
    List<String>? quickTokens,
    int? quickNext,
    String? quickNextKey,
    bool? showRecents,
  }) => AppSettings(
    mode: mode ?? this.mode,
    lastRuleId: lastRuleId ?? this.lastRuleId,
    lastFolder: lastFolder ?? this.lastFolder,
    defaultRuleByKind: defaultRuleByKind ?? this.defaultRuleByKind,
    languageCode: clearLanguage ? null : languageCode ?? this.languageCode,
    themeMode: themeMode ?? this.themeMode,
    quickTokens: quickTokens ?? this.quickTokens,
    quickNext: quickNext ?? this.quickNext,
    quickNextKey: quickNextKey ?? this.quickNextKey,
    showRecents: showRecents ?? this.showRecents,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'lastRuleId': lastRuleId,
    'lastFolder': lastFolder.toJson(),
    'defaultRuleByKind': defaultRuleByKind,
    'languageCode': languageCode,
    'themeMode': themeMode.name,
    'quickTokens': quickTokens,
    'quickNext': quickNext,
    'quickNextKey': quickNextKey,
    'showRecents': showRecents,
  };
}

const String _settingsKey = 'settings';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_settingsKey);
    var settings = AppSettings();
    if (raw != null) {
      try {
        settings = AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } on Object {
        // Unreadable settings fall back to the defaults.
      }
    }
    languageOverride = settings.languageCode;
    return settings;
  }

  void _update(AppSettings next) {
    state = next;
    languageOverride = next.languageCode;
    ref.read(sharedPreferencesProvider).setString(_settingsKey, jsonEncode(next.toJson()));
  }

  /// Null follows the system language.
  void setLanguage(String? languageCode) =>
      _update(languageCode == null ? state.copyWith(clearLanguage: true) : state.copyWith(languageCode: languageCode));

  void setThemeMode(AppThemeMode mode) => _update(state.copyWith(themeMode: mode));

  /// Forgets the rules remembered per kind of file and the last one used.
  void forgetRememberedRules() => _update(
    AppSettings(
      mode: state.mode,
      lastFolder: state.lastFolder,
      languageCode: state.languageCode,
      themeMode: state.themeMode,
      quickTokens: state.quickTokens,
      quickNext: state.quickNext,
      quickNextKey: state.quickNextKey,
      showRecents: state.showRecents,
    ),
  );

  void setShowRecents({required bool isShown}) => _update(state.copyWith(showRecents: isShown));

  void setMode(NamingMode mode) => _update(state.copyWith(mode: mode));

  void setRule(String ruleId) => _update(state.copyWith(lastRuleId: ruleId));

  /// Changes the quick pattern. The sequence starts again at 1 because the pattern is no longer the same.
  void setQuickTokens(List<String> tokens) => _update(state.copyWith(quickTokens: List.unmodifiable(tokens)));

  /// Sets the number the next file gets, for the pattern in use.
  void setQuickNext(int number) =>
      _update(state.copyWith(quickNext: number.clamp(1, maxSequenceNumber), quickNextKey: state.quickSignature));

  /// Returns the number for a file saved with the quick pattern [signature] and advances it.
  /// The saved number is only used when the pattern has not changed since it was stored.
  int takeQuickNumber(String signature) {
    final number = state.quickNextKey == signature ? state.quickNext : 1;
    _update(state.copyWith(quickNext: number + 1, quickNextKey: signature));
    return number;
  }

  void setLastFolder(DestinationFolder folder) => _update(state.copyWith(lastFolder: folder));

  void rememberDefaultFor(FileKind kind, String ruleId) =>
      _update(state.copyWith(defaultRuleByKind: {...state.defaultRuleByKind, kind.name: ruleId}));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
