import 'dart:convert';

import 'legal_content.dart';
import 'legal_models.dart';

/// A section body in the format the website generator reads (scripts/build-web.mjs): one line per paragraph and "- " for
/// each item of a list. The bare address of Google's policy becomes a link.
String _body(LegalSection section) => [...section.paragraphs, for (final item in section.items) '- $item']
    .join('\n')
    .replaceAll('policies.google.com/privacy', '[policies.google.com/privacy](https://policies.google.com/privacy)');

Map<String, Object> _document(LegalDocument document) => {
  'title': document.title,
  'updated': document.updatedLabel,
  'intro': document.intro,
  'sections': [
    for (final section in document.sections) {'title': section.title, 'body': _body(section)},
  ],
};

/// The terms and the privacy policy of [languageCode] as the JSON the website reads (`web/legal/<code>.json`).
String exportLegalJson(String languageCode) =>
    '${const JsonEncoder.withIndent('  ').convert({for (final kind in LegalKind.values) kind.name: _document(legalDocument(kind, languageCode))})}\n';
