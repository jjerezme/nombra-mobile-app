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

  /// A blank space. It is stored as a plain text token, so it is also valid in rules saved as text.
  static const String space = ' ';

  /// How a blank space is drawn inside the pattern, where it would otherwise be invisible.
  static const String spaceMark = '␣';

  /// Stands for "write some text" in the palette; never stored in a pattern.
  static const String textPlaceholder = '\u0000text';

  /// A pattern holds at most this many tokens.
  static const int maxCount = 5;

  static const int defaultCounterDigits = 3;
  static const int maxCounterDigits = 8;

  static const List<String> palette = [name, date, time, counter, domain, type, '_', '-', space];

  /// `{n:5}`: the sequential number padded to [digits] digits.
  static String counterWith(int digits) => '{n:$digits}';

  /// Digits of a `{n:3}` token.
  static int counterDigits(String token) =>
      int.tryParse(RegExp(r'^\{n:(\d+)\}$').firstMatch(token)?.group(1) ?? '') ?? defaultCounterDigits;

  /// What a number token writes for the number 7, to show the effect of the digits.
  static String counterExample(int digits) => '7'.padLeft(digits, '0');

  /// Whether the palette item [paletteToken] is already in [tokens] and cannot be added again. Each token (`{name}`,
  /// `{date}`, the number...) can be used once; free text and separators (`_`, `-`, a blank space) any number of times.
  static bool isUsed(String paletteToken, List<String> tokens) {
    if (!isToken(paletteToken)) return false;
    // The number counts whatever its digits are: `{n:3}` is used when the pattern has `{n:5}`.
    if (isCounter(paletteToken)) return tokens.any(isCounter);
    return tokens.contains(paletteToken);
  }

  /// Free text the user can change by tapping it: not a token and not just blank space.
  static bool isEditable(String token) => !isToken(token) && token.trim().isNotEmpty;

  static bool isToken(String value) => value.length > 1 && value.startsWith('{') && value.endsWith('}');

  /// `{n:3}`: the sequential number, padded to 3 digits.
  static bool isCounter(String value) => RegExp(r'^\{n:\d+\}$').hasMatch(value);
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
    ConflictPolicy? conflict,
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
    folder: folder ?? this.folder,
    conflict: conflict ?? this.conflict,
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
    'isDefault': isDefault,
    'counter': counter,
  };
}
