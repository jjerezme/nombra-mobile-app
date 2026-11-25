import 'legal_content_en.dart';
import 'legal_content_es.dart';
import 'legal_models.dart';

/// The legal text of [kind] in [languageCode] (`es` or `en`; anything else gets Spanish, the app's main language).
LegalDocument legalDocument(LegalKind kind, String languageCode) {
  final isEnglish = languageCode == 'en';
  return switch (kind) {
    LegalKind.terms => isEnglish ? termsEn : termsEs,
    LegalKind.privacy => isEnglish ? privacyEn : privacyEs,
  };
}
