import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../l10n/app_localizations.dart';

/// "Final name": how the file will be called, read only. It comes from the rule (or the quick pattern, or the original
/// name), so it is changed there. A long name continues on the next line.
class ShareNameField extends StatelessWidget {
  const ShareNameField({required this.fileName, super.key});

  final String fileName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LabeledField(
      label: AppLocalizations.of(context).shareFinalName,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: AppSize.control),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppLayout.controlRadius),
        ),
        child: SelectableText(fileName, style: context.monoStyles.mono.copyWith(fontSize: AppFontSize.md)),
      ),
    );
  }
}
