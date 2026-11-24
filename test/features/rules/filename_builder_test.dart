import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/rules/domain/filename_builder.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';

void main() {
  final now = DateTime(2026, 11, 23, 10, 35);
  const source = SourceFile(name: 'Informe Q3 FINAL (2).pdf', domain: 'ejemplo.com');

  RenameRule rule(
    List<String> tokens, {
    CaseMode caseMode = CaseMode.keep,
    bool spaces = false,
    String spaceChar = '-',
    bool copy = false,
    bool sanitize = false,
    int counter = 14,
  }) {
    return RenameRule(
      id: 'r',
      name: 'r',
      tokens: tokens,
      caseMode: caseMode,
      replaceSpaces: spaces,
      spaceChar: spaceChar,
      removeCopySuffix: copy,
      sanitize: sanitize,
      counter: counter,
    );
  }

  group('splitFileName', () {
    test('splits on the last dot', () {
      expect(splitFileName('a.b.pdf'), ('a.b', 'pdf'));
    });

    test('has no extension for a leading or trailing dot or no dot', () {
      expect(splitFileName('.env'), ('.env', ''));
      expect(splitFileName('file.'), ('file.', ''));
      expect(splitFileName('file'), ('file', ''));
    });
  });

  group('buildFileName', () {
    test('renders date, name and keeps the extension', () {
      expect(
        buildFileName(rule([PatternTokens.date, '_', PatternTokens.name]), source, now: now),
        '2026-11-23_Informe Q3 FINAL (2).pdf',
      );
    });

    test('renders time, counter, domain and type', () {
      final result = buildFileName(
        rule([PatternTokens.domain, '-', PatternTokens.type, '-', PatternTokens.time, '-', PatternTokens.counter]),
        source,
        now: now,
      );
      expect(result, 'ejemplo.com-PDF-1035-014.pdf');
    });

    test('applies copy suffix, case and space replacement', () {
      final result = buildFileName(
        rule([PatternTokens.name], caseMode: CaseMode.lower, spaces: true, copy: true),
        source,
        now: now,
      );
      expect(result, 'informe-q3-final.pdf');
    });

    test('sanitizes accents, emojis and invalid characters', () {
      const dirty = SourceFile(name: 'Canción ñandú 🎵 (v2)!.mp3');
      final result = buildFileName(
        rule([PatternTokens.name], sanitize: true, spaces: true, spaceChar: '_'),
        dirty,
        now: now,
      );
      expect(result, 'Cancion_nandu_v2.mp3');
    });

    test('uses the given counter over the rule counter', () {
      expect(buildFileName(rule([PatternTokens.counter]), source, now: now, counter: 7), '007.pdf');
    });

    test('never returns an empty or invalid name', () {
      expect(buildFileName(rule(['/']), source, now: now), 'file.pdf');
      expect(buildFileName(rule(['a:b', PatternTokens.name]), const SourceFile(name: 'x'), now: now), 'abx');
    });
  });

  group('buildQuickFileName', () {
    test('builds the name from the quick pattern and keeps the original extension', () {
      expect(
        buildQuickFileName(['acme_', PatternTokens.name, '_v2'], source, now: now),
        'acme_Informe Q3 FINAL (2)_v2.pdf',
      );
    });

    test('the counter token numbers the file, padded to its digits', () {
      expect(buildQuickFileName(['Foto_', '{n:3}'], source, now: now, counter: 7), 'Foto_007.pdf');
      expect(buildQuickFileName(['{n:2}'], source, now: now, counter: 12345), '12345.pdf');
    });

    test('date, domain and type tokens work as in a rule', () {
      expect(
        buildQuickFileName([PatternTokens.date, '_', PatternTokens.domain, '_', PatternTokens.type], source, now: now),
        '2026-11-23_ejemplo.com_PDF.pdf',
      );
    });

    test('a pattern without {name} replaces the original name', () {
      expect(buildQuickFileName(['Foto_', '{n:3}'], source, now: now), 'Foto_001.pdf');
    });

    test('nothing left falls back to the default name', () {
      expect(buildQuickFileName(const [], source, now: now), 'file.pdf');
    });
  });

  test('withNumberSuffix numbers before the extension', () {
    expect(withNumberSuffix('a.pdf', 1), 'a (1).pdf');
    expect(withNumberSuffix('a', 2), 'a (2)');
  });

  group('URLs', () {
    test('sourceFromUrl decodes the last segment and strips www', () {
      final file = sourceFromUrl('https://www.cdn.ejemplo.com/docs/Informe%20Q3%20FINAL%20(2).pdf?x=1');
      expect(file.name, 'Informe Q3 FINAL (2).pdf');
      expect(file.domain, 'cdn.ejemplo.com');
    });

    test('sourceFromUrl is empty for invalid input', () {
      expect(sourceFromUrl('no es una url').name, '');
    });

    test('firstUrlIn finds a link inside text and drops trailing punctuation', () {
      expect(firstUrlIn('Mira esto: https://a.com/x.pdf.'), 'https://a.com/x.pdf');
      expect(firstUrlIn('sin enlace'), isNull);
    });

    test('isHttpUrl accepts only http and https', () {
      expect(isHttpUrl('https://a.com/b'), isTrue);
      expect(isHttpUrl('ftp://a.com/b'), isFalse);
      expect(isHttpUrl('a.com'), isFalse);
    });
  });
}
