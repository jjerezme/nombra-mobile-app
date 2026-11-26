import 'rename_rule.dart';

/// The file being named: its full name (with extension) and, for downloads, the host it came from.
class SourceFile {
  const SourceFile({required this.name, this.domain = ''});

  final String name;
  final String domain;

  String get baseName => splitFileName(name).$1;

  /// Extension without the dot, as in the original name.
  String get extension => splitFileName(name).$2;
}

/// Splits `report.final.pdf` into (`report.final`, `pdf`). A leading dot is not an extension.
(String, String) splitFileName(String fileName) {
  final index = fileName.lastIndexOf('.');
  if (index <= 0 || index == fileName.length - 1) return (fileName, '');
  return (fileName.substring(0, index), fileName.substring(index + 1));
}

/// Name used when nothing usable is left after cleaning.
const String fallbackBaseName = 'file';

const Map<String, String> _accents = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'ã': 'a',
  'å': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
  'ý': 'y',
  'ÿ': 'y',
  'Á': 'A',
  'À': 'A',
  'Ä': 'A',
  'Â': 'A',
  'Ã': 'A',
  'Å': 'A',
  'É': 'E',
  'È': 'E',
  'Ë': 'E',
  'Ê': 'E',
  'Í': 'I',
  'Ì': 'I',
  'Ï': 'I',
  'Î': 'I',
  'Ó': 'O',
  'Ò': 'O',
  'Ö': 'O',
  'Ô': 'O',
  'Õ': 'O',
  'Ú': 'U',
  'Ù': 'U',
  'Ü': 'U',
  'Û': 'U',
  'Ñ': 'N',
  'Ç': 'C',
  'Ý': 'Y',
};

/// Removes accents, emojis and characters that are not valid in file names; keeps letters, digits, `- _ .` and spaces.
String sanitizeName(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString().replaceAll(RegExp(r'[^A-Za-z0-9 ._-]'), '');
}

/// Characters Android does not allow in file names.
String stripInvalidFileChars(String value) => value.replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1F]'), '');

final RegExp _copySuffix = RegExp(r'\s*\(\d+\)$');

/// Applies the rule's transformations to the original base name, in this order: copy suffix, sanitize, case, spaces.
String transformBaseName(String base, RenameRule rule) {
  var result = base;
  if (rule.removeCopySuffix) result = result.replaceFirst(_copySuffix, '');
  if (rule.sanitize) result = sanitizeName(result);
  result = switch (rule.caseMode) {
    CaseMode.upper => result.toUpperCase(),
    CaseMode.lower => result.toLowerCase(),
    CaseMode.keep => result,
  };
  if (rule.replaceSpaces) {
    result = result.replaceAll(RegExp(r'\s+'), rule.spaceChar);
  }
  return result;
}

String _two(int value) => value.toString().padLeft(2, '0');

String formatDate(DateTime time) => '${time.year.toString().padLeft(4, '0')}-${_two(time.month)}-${_two(time.day)}';

String formatTime(DateTime time) => '${_two(time.hour)}${_two(time.minute)}';

final RegExp _counterToken = RegExp(r'^\{n:(\d+)\}$');

/// Renders the pattern tokens into a name (without extension).
String renderPattern(
  List<String> tokens, {
  required String base,
  required String domain,
  required String type,
  required DateTime now,
  required int counter,
}) {
  final buffer = StringBuffer();
  for (final token in tokens) {
    final counterMatch = _counterToken.firstMatch(token);
    if (counterMatch != null) {
      buffer.write(counter.toString().padLeft(int.parse(counterMatch.group(1)!), '0'));
      continue;
    }
    switch (token) {
      case PatternTokens.name:
        buffer.write(base);
      case PatternTokens.date:
        buffer.write(formatDate(now));
      case PatternTokens.time:
        buffer.write(formatTime(now));
      case PatternTokens.domain:
        buffer.write(domain);
      case PatternTokens.type:
        buffer.write(type);
      default:
        buffer.write(token);
    }
  }
  return buffer.toString();
}

String _joinExtension(String base, String extension) {
  final name = safeFileName(base);
  return extension.isEmpty ? name : '$name.$extension';
}

/// Final file name for [source] following [rule]; the extension is always kept.
String buildFileName(RenameRule rule, SourceFile source, {required DateTime now, int? counter}) {
  final rendered = renderPattern(
    rule.tokens,
    base: transformBaseName(source.baseName, rule),
    domain: source.domain,
    type: source.extension.toUpperCase(),
    now: now,
    counter: counter ?? rule.counter,
  );
  return _joinExtension(rendered, source.extension);
}

/// Final file name in quick mode: the quick pattern [tokens] (the same tokens a rule uses) with the original name and
/// extension of [source]. [counter] is the value of the `{n:3}` token.
String buildQuickFileName(List<String> tokens, SourceFile source, {required DateTime now, int counter = 1}) {
  final rendered = renderPattern(
    tokens,
    base: source.baseName,
    domain: source.domain,
    type: source.extension.toUpperCase(),
    now: now,
    counter: counter,
  );
  return _joinExtension(rendered, source.extension);
}

/// `report.pdf` -> `report (1).pdf`, `report (2).pdf`, ...
String withNumberSuffix(String fileName, int number) {
  final (base, extension) = splitFileName(fileName);
  return extension.isEmpty ? '$base ($number)' : '$base ($number).$extension';
}

/// Name for a URL: the last path segment, decoded; [fallbackBaseName] when there is none.
SourceFile sourceFromUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return const SourceFile(name: '');
  }
  var name = '';
  if (uri.pathSegments.isNotEmpty) {
    final last = uri.pathSegments.last;
    try {
      name = Uri.decodeComponent(last);
    } on Object {
      name = last;
    }
  }
  return SourceFile(name: stripInvalidFileChars(name).trim(), domain: uri.host.replaceFirst(RegExp(r'^www\.'), ''));
}

/// The first https link in shared text, or null. Plain http is not accepted: Android blocks it and it is not safe.
String? firstUrlIn(String text) {
  final match = RegExp(r'https://[^\s<>"]+', caseSensitive: false).firstMatch(text);
  if (match == null) return null;
  return match.group(0)!.replaceFirst(RegExp(r'[.,;:!?)\]]+$'), '');
}

/// Whether [text] is a single valid https URL.
bool isHttpsUrl(String text) {
  final uri = Uri.tryParse(text.trim());
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
}

/// Whether [text] starts like a plain http link, which is refused so the user gets a clear message.
bool isInsecureUrl(String text) => RegExp(r'^\s*http://', caseSensitive: false).hasMatch(text);

/// Whether [text] has a plain http link inside, used to tell the user why a shared link cannot be saved.
bool hasInsecureLink(String text) => RegExp(r'http://[^\s<>"]+', caseSensitive: false).hasMatch(text);

/// A name that is safe to use as a file name: invalid characters removed and never empty or made only of dots (`.`,
/// `..`), which would point to a folder.
String safeFileName(String name) {
  final cleaned = stripInvalidFileChars(name).trim();
  return cleaned.isEmpty || RegExp(r'^\.+$').hasMatch(cleaned) ? fallbackBaseName : cleaned;
}
