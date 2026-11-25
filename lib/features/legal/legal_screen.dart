import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import 'domain/legal_content.dart';
import 'domain/legal_models.dart';

/// Terms and conditions, or the privacy policy: the text of `legal_content` in the language of the app.
class LegalScreen extends StatelessWidget {
  const LegalScreen({required this.kind, super.key});

  final LegalKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final document = legalDocument(kind, Localizations.localeOf(context).languageCode);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppPage.paddingWithBack,
          children: [
            ScreenHeader(
              title: document.title,
              subtitle: document.updatedLabel,
              onBack: () => Navigator.of(context).maybePop(),
              backTooltip: l10n.backTooltip,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppLayout.sectionGap,
              children: [
                Text(document.intro, style: context.text.bodyMedium),
                for (final section in document.sections) _Section(section: section),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Semantics(header: true, child: Text(section.title, style: context.text.titleMedium)),
        for (final paragraph in section.paragraphs) Text(paragraph, style: context.text.bodyMedium),
        for (final item in section.items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              ExcludeSemantics(child: Text('•', style: context.text.bodyMedium)),
              Expanded(child: Text(item, style: context.text.bodyMedium)),
            ],
          ),
      ],
    );
  }
}
