import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../rules/domain/file_kind.dart';
import '../rules/domain/storage_root.dart';

enum NamingMode { saved, quick }

/// What the user last chose; Home and the share sheet start from it.
class AppSettings {
  AppSettings({
    this.mode = NamingMode.saved,
    this.lastRuleId,
    this.prefix = '',
    this.suffix = '',
    DestinationFolder? lastFolder,
    this.defaultRuleByKind = const {},
  }) : lastFolder = lastFolder ?? DestinationFolder(StorageRoot.download, 'Nombra');

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    mode: NamingMode.values.firstWhere((mode) => mode.name == json['mode'], orElse: () => NamingMode.saved),
    lastRuleId: json['lastRuleId'] as String?,
    prefix: json['prefix'] as String? ?? '',
    suffix: json['suffix'] as String? ?? '',
    lastFolder: json['lastFolder'] == null
        ? null
        : DestinationFolder.fromJson(json['lastFolder'] as Map<String, dynamic>),
    defaultRuleByKind: (json['defaultRuleByKind'] as Map<String, dynamic>? ?? {}).cast<String, String>(),
  );

  final NamingMode mode;
  final String? lastRuleId;
  final String prefix;
  final String suffix;
  final DestinationFolder lastFolder;

  /// `FileKind.name` -> rule id, set with "remember as default for images".
  final Map<String, String> defaultRuleByKind;

  AppSettings copyWith({
    NamingMode? mode,
    String? lastRuleId,
    String? prefix,
    String? suffix,
    DestinationFolder? lastFolder,
    Map<String, String>? defaultRuleByKind,
  }) => AppSettings(
    mode: mode ?? this.mode,
    lastRuleId: lastRuleId ?? this.lastRuleId,
    prefix: prefix ?? this.prefix,
    suffix: suffix ?? this.suffix,
    lastFolder: lastFolder ?? this.lastFolder,
    defaultRuleByKind: defaultRuleByKind ?? this.defaultRuleByKind,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'lastRuleId': lastRuleId,
    'prefix': prefix,
    'suffix': suffix,
    'lastFolder': lastFolder.toJson(),
    'defaultRuleByKind': defaultRuleByKind,
  };
}

const String _settingsKey = 'settings';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_settingsKey);
    if (raw == null) return AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return AppSettings();
    }
  }

  void _update(AppSettings next) {
    state = next;
    ref.read(sharedPreferencesProvider).setString(_settingsKey, jsonEncode(next.toJson()));
  }

  void setMode(NamingMode mode) => _update(state.copyWith(mode: mode));

  void setRule(String ruleId) => _update(state.copyWith(lastRuleId: ruleId));

  void setPrefix(String prefix) => _update(state.copyWith(prefix: prefix));

  void setSuffix(String suffix) => _update(state.copyWith(suffix: suffix));

  void setLastFolder(DestinationFolder folder) => _update(state.copyWith(lastFolder: folder));

  void rememberDefaultFor(FileKind kind, String ruleId) =>
      _update(state.copyWith(defaultRuleByKind: {...state.defaultRuleByKind, kind.name: ruleId}));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
