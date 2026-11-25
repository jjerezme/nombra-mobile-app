import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/legal/domain/legal_content.dart';
import 'package:nombra/features/legal/domain/legal_html.dart';
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

  group('legal web pages', () {
    test('escapeHtml escapes the characters that matter', () {
      expect(escapeHtml('<a href="x">&\'</a>'), '&lt;a href=&quot;x&quot;&gt;&amp;&#39;&lt;/a&gt;');
    });

    test('a page has its title, one heading per section and marks the current page', () {
      final document = legalDocument(LegalKind.privacy, 'es');
      final html = renderLegalPage(document);
      expect(html, contains('<html lang="es">'));
      expect(html, contains('<h1>Política de privacidad</h1>'));
      expect('<h2>'.allMatches(html).length, document.sections.length);
      expect(html, contains('<a href="/privacy" aria-current="page">'));
      expect(html, contains('<a href="/terms">'));
      expect(html, contains('href="/en/privacy" hreflang="en"'));
      expect(html, contains('<a href="mailto:$legalContactEmail">'));
    });

    test('English pages live under /en and link back to Spanish', () {
      final html = renderLegalPage(legalDocument(LegalKind.terms, 'en'));
      expect(html, contains('<html lang="en">'));
      expect(html, contains('<a href="/en/terms" aria-current="page">'));
      expect(html, contains('href="/terms" hreflang="es"'));
    });

    test('the site has the front page and the four texts', () {
      expect(
        renderLegalSite().keys,
        unorderedEquals(['index.html', 'terms.html', 'privacy.html', 'en/terms.html', 'en/privacy.html']),
      );
      expect(renderLegalIndex(), contains('href="/en/privacy"'));
    });

    test('the pages in web/ are up to date with the text of the app', () {
      for (final entry in renderLegalSite().entries) {
        final file = File('web/${entry.key}');
        expect(file.existsSync(), isTrue, reason: 'web/${entry.key} is missing: run dart run scripts/build_legal.dart');
        expect(
          file.readAsStringSync().replaceAll('\r\n', '\n'),
          entry.value,
          reason: 'web/${entry.key} is out of date: run dart run scripts/build_legal.dart',
        );
      }
    });
  });
}
