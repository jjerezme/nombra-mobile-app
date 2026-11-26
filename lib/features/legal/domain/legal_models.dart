/// Which legal text.
enum LegalKind { terms, privacy }

/// A titled part of a legal text: some paragraphs and, after them, an optional list.
class LegalSection {
  const LegalSection({required this.title, this.paragraphs = const [], this.items = const []});

  final String title;
  final List<String> paragraphs;
  final List<String> items;
}

/// A legal text in one language. The app shows it on a screen and `scripts/export_legal.dart` feeds the same data to the
/// web page, so the two cannot say different things.
class LegalDocument {
  const LegalDocument({
    required this.kind,
    required this.languageCode,
    required this.title,
    required this.updatedLabel,
    required this.intro,
    required this.sections,
  });

  final LegalKind kind;
  final String languageCode;
  final String title;

  /// "Last updated: November 25, 2026", already in the language of the text.
  final String updatedLabel;
  final String intro;
  final List<LegalSection> sections;
}

/// Public contact, shown in both texts and on the web.
const String legalContactEmail = 'jjerezme@gmail.com';

/// Where the web version lives (Firebase Hosting of the production project).
const String legalWebBase = 'https://nombra-prod.web.app';
