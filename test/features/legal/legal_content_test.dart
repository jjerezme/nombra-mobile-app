import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/legal/domain/legal_content.dart';
import 'package:nombra/features/legal/domain/legal_export.dart';
import 'package:nombra/features/legal/domain/legal_models.dart';

void main() {
  group('legal content', () {
    test('every text exists in Spanish and English with the same sections', () {
      for (final kind in LegalKind.values) {
        final es = legalDocument(kind, 'es');
        final en = legalDocument(kind, 'en');
        expect(es.languageCode, 'es');
        expect(en.languageCode, 'en');
        expect(es.kind, kind);
        expect(en.sections.length, es.sections.length, reason: '$kind differs between languages');
        for (var i = 0; i < es.sections.length; i++) {
          expect(en.sections[i].paragraphs.length, es.sections[i].paragraphs.length, reason: '$kind section $i');
          expect(en.sections[i].items.length, es.sections[i].items.length, reason: '$kind section $i');
        }
      }
    });

    test('an unknown language gets Spanish', () {
      expect(legalDocument(LegalKind.terms, 'fr').languageCode, 'es');
    });

    test('both texts give the contact e-mail and have no unfinished marks', () {
      for (final kind in LegalKind.values) {
        for (final code in ['es', 'en']) {
          final document = legalDocument(kind, code);
          final text = [
            document.title,
            document.intro,
            for (final section in document.sections) ...[section.title, ...section.paragraphs, ...section.items],
          ].join('\n');
          expect(text, contains(legalContactEmail), reason: '$kind/$code');
          expect(text, isNot(matches(RegExp(r'\bTODO\b|\[[A-Za-z ]+\]|\bXXX\b|[Ll]orem ipsum'))));
        }
      }
    });

    test('the privacy policy covers what the app really collects', () {
      final text = legalDocument(LegalKind.privacy, 'en').sections.map((s) => s.title).join('|').toLowerCase();
      for (final topic in ['google account', 'backup', 'crash', 'permissions', 'rights', 'children']) {
        expect(text, contains(topic));
      }
    });
  });

  group('legal export for the website', () {
    test('has both texts with a body per section, and Google\'s policy as a link', () {
      final json = jsonDecode(exportLegalJson('es')) as Map<String, dynamic>;
      for (final kind in LegalKind.values) {
        final document = json[kind.name] as Map<String, dynamic>;
        final sections = (document['sections'] as List).cast<Map<String, dynamic>>();
        expect(sections.length, legalDocument(kind, 'es').sections.length);
        expect(sections.every((section) => (section['body'] as String).isNotEmpty), isTrue);
      }
      expect(exportLegalJson('es'), contains('](https://policies.google.com/privacy)'));
    });

    test('the files in web/legal are up to date with the text of the app', () {
      for (final code in ['en', 'es']) {
        final file = File('web/legal/$code.json');
        expect(
          file.readAsStringSync().replaceAll('\r\n', '\n'),
          exportLegalJson(code),
          reason:
              'web/legal/$code.json is out of date: run dart run scripts/export_legal.dart and build-web (see README)',
        );
      }
    });
  });
}
