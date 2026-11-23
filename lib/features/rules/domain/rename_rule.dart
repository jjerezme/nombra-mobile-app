import 'storage_root.dart';

enum CaseMode { keep, upper, lower }

enum ConflictPolicy { suffix, replace, ask }

/// Tokens a pattern can contain, besides free text: `{name}`, `{date}`, `{time}`, `{n:3}`, `{domain}`, `{type}`.
abstract final class PatternTokens {
  static const String name = '{name}';
  static const String date = '{date}';
  static const String time = '{time}';
  static const String counter = '{n:3}';
  static const String domain = '{domain}';
  static const String type = '{type}';

  static const List<String> palette = [name, date, time, counter, domain, type, '_', '-'];

  static bool isToken(String value) => value.length > 1 && value.startsWith('{') && value.endsWith('}');
}

class RenameRule {
  const RenameRule({
    required this.id,
    required this.name,
    required this.tokens,
    this.caseMode = CaseMode.keep,
    this.replaceSpaces = false,
    this.spaceChar = '-',
    this.removeCopySuffix = false,
    this.sanitize = false,
    this.folder,
    this.conflict = ConflictPolicy.suffix,
    this.isEnabled = true,
    this.isDefault = false,
    this.counter = 1,
  });

  factory RenameRule.fromJson(Map<String, dynamic> json) => RenameRule(
    id: json['id'] as String,
    name: json['name'] as String,
    tokens: (json['tokens'] as List<dynamic>).cast<String>(),
    caseMode: CaseMode.values.firstWhere((mode) => mode.name == json['caseMode'], orElse: () => CaseMode.keep),
    replaceSpaces: json['replaceSpaces'] as bool? ?? false,
    spaceChar: json['spaceChar'] as String? ?? '-',
    removeCopySuffix: json['removeCopySuffix'] as bool? ?? false,
    sanitize: json['sanitize'] as bool? ?? false,
    folder: json['folder'] == null ? null : DestinationFolder.fromJson(json['folder'] as Map<String, dynamic>),
    conflict: ConflictPolicy.values.firstWhere(
      (policy) => policy.name == json['conflict'],
      orElse: () => ConflictPolicy.suffix,
    ),
    isEnabled: json['isEnabled'] as bool? ?? true,
    isDefault: json['isDefault'] as bool? ?? false,
    counter: json['counter'] as int? ?? 1,
  );

  final String id;
  final String name;
  final List<String> tokens;
  final CaseMode caseMode;
  final bool replaceSpaces;
  final String spaceChar;
  final bool removeCopySuffix;
  final bool sanitize;

  /// Null means "use the last folder the user saved to".
  final DestinationFolder? folder;
  final ConflictPolicy conflict;
  final bool isEnabled;
  final bool isDefault;

  /// Next value of `{n:3}`.
  final int counter;

  String get pattern => tokens.join();

  RenameRule copyWith({
    String? name,
    List<String>? tokens,
    CaseMode? caseMode,
    bool? replaceSpaces,
    String? spaceChar,
    bool? removeCopySuffix,
    bool? sanitize,
    DestinationFolder? folder,
    bool clearFolder = false,
    ConflictPolicy? conflict,
    bool? isEnabled,
    bool? isDefault,
    int? counter,
  }) => RenameRule(
    id: id,
    name: name ?? this.name,
    tokens: tokens ?? this.tokens,
    caseMode: caseMode ?? this.caseMode,
    replaceSpaces: replaceSpaces ?? this.replaceSpaces,
    spaceChar: spaceChar ?? this.spaceChar,
    removeCopySuffix: removeCopySuffix ?? this.removeCopySuffix,
    sanitize: sanitize ?? this.sanitize,
    folder: clearFolder ? null : folder ?? this.folder,
    conflict: conflict ?? this.conflict,
    isEnabled: isEnabled ?? this.isEnabled,
    isDefault: isDefault ?? this.isDefault,
    counter: counter ?? this.counter,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tokens': tokens,
    'caseMode': caseMode.name,
    'replaceSpaces': replaceSpaces,
    'spaceChar': spaceChar,
    'removeCopySuffix': removeCopySuffix,
    'sanitize': sanitize,
    'folder': folder?.toJson(),
    'conflict': conflict.name,
    'isEnabled': isEnabled,
    'isDefault': isDefault,
    'counter': counter,
  };
}
