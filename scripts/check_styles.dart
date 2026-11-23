// Fails when a style number or color drifts away from the design tokens (lib/core/constants/tokens.dart).
// Run with `dart run scripts/check_styles.dart`. A line that is a deliberate exception ends with `// style-ok`.
// lib/core/ (tokens and theme) is where raw values live, so it is not checked.
import 'dart:io';

const _roots = ['lib/app', 'lib/features'];

final _rules = <(RegExp, String)>[
  (
    RegExp(r'\bfontSize:\s*\d'),
    'fontSize literal: use AppFontSize.* or a textTheme style',
  ),
  (
    RegExp(r'EdgeInsets\.[A-Za-z]+\([^)]*\b[1-9]\d*(\.\d+)?\b'),
    'padding literal: use AppSpacing.*',
  ),
  (
    RegExp(r'\bSizedBox\((width|height):\s*[1-9]'),
    'size literal: use AppSpacing.*',
  ),
  (
    RegExp(r'\bBorderRadius\.circular\(\s*[1-9]'),
    'radius literal: use AppRadius.*',
  ),
  (
    RegExp(r'\bIcon\([^)]*\bsize:\s*[1-9]'),
    'icon size literal: use AppIconSize.*',
  ),
  (
    RegExp(r'\bColor\(\s*0x|\bColors\.'),
    'color literal: use Theme.of(context).colorScheme',
  ),
];

void main() {
  final findings = <String>[];
  for (final root in _roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimRight().endsWith('// style-ok')) continue;
        for (final (pattern, message) in _rules) {
          if (pattern.hasMatch(line)) {
            findings.add(
              '${entity.path.replaceAll(r'\', '/')}:${i + 1}  $message\n    ${line.trim()}',
            );
          }
        }
      }
    }
  }
  if (findings.isNotEmpty) {
    stderr
      ..writeln(findings.join('\n'))
      ..writeln(
        '\n${findings.length} style value(s) outside the design tokens. Use lib/core/constants/tokens.dart.',
      );
    exit(1);
  }
  stdout.writeln('check_styles: all style values come from the design tokens.');
}
