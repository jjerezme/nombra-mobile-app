import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/developer/domain/dev_info.dart';

void main() {
  test('the report lists each section with its rows', () {
    const sections = [
      InfoSection('app', [InfoRow('Version', '1.0.0')]),
      InfoSection('battery', [InfoRow('Level', '50 %')]),
    ];
    expect(formatReport(sections, (id) => id.toUpperCase()), '## APP\nVersion: 1.0.0\n\n## BATTERY\nLevel: 50 %');
  });

  test('dependencies come from the pubspec without SDK or dev packages', () {
    const pubspec = '''
name: x
dependencies:
  flutter:
    sdk: flutter
  go_router: ^18.1.4
  # a comment
  intl: ^0.20.3

dev_dependencies:
  flutter_lints: ^6.0.0
''';
    final rows = parseDependencies(pubspec);
    expect(rows.map((row) => row.label), ['go_router', 'intl']);
    expect(rows.first.value, '^18.1.4');
  });

  test('sizes are short and an unknown size says so', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(1536 * 1024 * 1024), '1.5 GB');
    expect(formatBytes(0), unknownValue);
  });
}
