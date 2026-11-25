import 'legal_content.dart';
import 'legal_models.dart';

/// Escapes text for HTML.
String escapeHtml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

/// The folder of the pages of [languageCode] on the web: Spanish at the root, English under `/en`.
String legalBasePath(String languageCode) => languageCode == 'en' ? '/en' : '';

/// The path of a legal page on the web (`/terms`, `/en/privacy`).
String legalPagePath(LegalKind kind, String languageCode) =>
    '${legalBasePath(languageCode)}/${kind == LegalKind.terms ? 'terms' : 'privacy'}';

const Map<String, ({String terms, String privacy, String switchLabel, String switchCode, String rights})> _labels = {
  'es': (
    terms: 'Términos y condiciones',
    privacy: 'Política de privacidad',
    switchLabel: 'English',
    switchCode: 'en',
    rights: 'Nombra. Todos los derechos reservados.',
  ),
  'en': (
    terms: 'Terms and conditions',
    privacy: 'Privacy policy',
    switchLabel: 'Español',
    switchCode: 'es',
    rights: 'Nombra. All rights reserved.',
  ),
};

String _head(String title, String languageCode, String description) =>
    '''
<!doctype html>
<html lang="$languageCode">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <meta name="description" content="${escapeHtml(description)}">
  <link rel="icon" href="/logo.png">
  <link rel="stylesheet" href="/style.css">
</head>''';

String _nav(LegalKind current, String languageCode) {
  final labels = _labels[languageCode]!;
  final other = labels.switchCode;
  String link(LegalKind kind, String text) {
    final isCurrent = kind == current;
    return '<a href="${legalPagePath(kind, languageCode)}"${isCurrent ? ' aria-current="page"' : ''}>${escapeHtml(text)}</a>';
  }

  return '''
    <nav aria-label="${escapeHtml(labels.terms)} / ${escapeHtml(labels.privacy)}">
      ${link(LegalKind.terms, labels.terms)}
      ${link(LegalKind.privacy, labels.privacy)}
      <a href="${legalPagePath(current, other)}" hreflang="$other" lang="$other">${escapeHtml(labels.switchLabel)}</a>
    </nav>''';
}

/// One legal page (terms or privacy) as a full HTML document.
String renderLegalPage(LegalDocument document) {
  final labels = _labels[document.languageCode]!;
  final body = StringBuffer();
  body.writeln('      <p class="intro">${escapeHtml(document.intro)}</p>');
  for (final section in document.sections) {
    body.writeln('      <section>');
    body.writeln('        <h2>${escapeHtml(section.title)}</h2>');
    for (final paragraph in section.paragraphs) {
      body.writeln('        <p>${_linkify(escapeHtml(paragraph))}</p>');
    }
    if (section.items.isNotEmpty) {
      body.writeln('        <ul>');
      for (final item in section.items) {
        body.writeln('          <li>${_linkify(escapeHtml(item))}</li>');
      }
      body.writeln('        </ul>');
    }
    body.writeln('      </section>');
  }
  return '''
${_head('${document.title} · Nombra', document.languageCode, document.intro)}
<body>
  <header>
    <a class="brand" href="${legalBasePath(document.languageCode).isEmpty ? '/' : legalBasePath(document.languageCode)}"><img src="/logo.png" alt="" width="32" height="32"> Nombra</a>
${_nav(document.kind, document.languageCode)}
  </header>
  <main>
    <h1>${escapeHtml(document.title)}</h1>
    <p class="updated">${escapeHtml(document.updatedLabel)}</p>
$body  </main>
  <footer>
    <p>© ${escapeHtml(labels.rights)} <a href="mailto:$legalContactEmail">$legalContactEmail</a></p>
  </footer>
</body>
</html>
''';
}

/// The front page: the name of the app and a link to each text in each language.
String renderLegalIndex() {
  final links = StringBuffer();
  for (final code in ['es', 'en']) {
    final labels = _labels[code]!;
    links.writeln('''
    <section lang="$code">
      <h2>${code == 'es' ? 'Español' : 'English'}</h2>
      <ul>
        <li><a href="${legalPagePath(LegalKind.terms, code)}">${escapeHtml(labels.terms)}</a></li>
        <li><a href="${legalPagePath(LegalKind.privacy, code)}">${escapeHtml(labels.privacy)}</a></li>
      </ul>
    </section>''');
  }
  return '''
${_head('Nombra', 'es', 'Nombra: descarga archivos y nómbralos con tus reglas. / Download files and name them with your rules.')}
<body>
  <header>
    <a class="brand" href="/"><img src="/logo.png" alt="" width="32" height="32"> Nombra</a>
  </header>
  <main>
    <h1>Nombra</h1>
    <p class="intro">Descarga archivos desde un enlace y guárdalos con el nombre que definas con reglas.
      <span lang="en">Download files from a link and save them with a name you define with rules.</span></p>
$links  </main>
  <footer>
    <p><a href="mailto:$legalContactEmail">$legalContactEmail</a></p>
  </footer>
</body>
</html>
''';
}

/// Makes an e-mail address and a bare web address clickable.
String _linkify(String escaped) => escaped
    .replaceAllMapped(RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+'), (match) => '<a href="mailto:${match[0]}">${match[0]}</a>')
    .replaceAllMapped(
      RegExp(r'policies\.google\.com/privacy'),
      (match) => '<a href="https://policies.google.com/privacy" rel="noopener">${match[0]}</a>',
    );

/// Every page of the site: path under `web/` -> contents.
Map<String, String> renderLegalSite() => {
  'index.html': renderLegalIndex(),
  for (final code in ['es', 'en'])
    for (final kind in LegalKind.values)
      '${legalBasePath(code).isEmpty ? '' : '${legalBasePath(code).substring(1)}/'}${kind == LegalKind.terms ? 'terms' : 'privacy'}.html':
          renderLegalPage(legalDocument(kind, code)),
};
