import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/segmented_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/rename_rule.dart';

/// Transformations applied to the original name: case, copy suffixes, spaces and sanitizing.
class TransformSection extends StatelessWidget {
  const TransformSection({required this.rule, required this.onChanged, super.key});

  final RenameRule rule;
  final ValueChanged<RenameRule> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spaceChars = [('-', l10n.editorSpaceDash), ('_', l10n.editorSpaceUnderscore), ('.', l10n.editorSpaceDot)];
    return AppSection(
      title: l10n.editorTransformTitle,
      child: AppCard.stack(
        children: [
          LabeledField(
            label: l10n.editorCase,
            child: SegmentedToggle<CaseMode>(
              options: [
                ToggleOption(CaseMode.keep, l10n.editorCaseKeep),
                ToggleOption(CaseMode.upper, l10n.editorCaseUpper),
                ToggleOption(CaseMode.lower, l10n.editorCaseLower),
              ],
              selected: rule.caseMode,
              onChanged: (mode) => onChanged(rule.copyWith(caseMode: mode)),
            ),
          ),
          ToggleRow(
            label: l10n.editorStripCopy,
            value: rule.removeCopySuffix,
            onChanged: (value) => onChanged(rule.copyWith(removeCopySuffix: value)),
          ),
          ToggleRow(
            label: l10n.editorReplaceSpaces,
            value: rule.replaceSpaces,
            onChanged: (value) => onChanged(rule.copyWith(replaceSpaces: value)),
          ),
          if (rule.replaceSpaces)
            LabeledField(
              label: l10n.editorReplaceWith,
              child: SegmentedToggle<String>(
                options: [for (final (char, name) in spaceChars) ToggleOption(char, '$char $name')],
                selected: rule.spaceChar,
                onChanged: (char) => onChanged(rule.copyWith(spaceChar: char)),
              ),
            ),
          ToggleRow(
            label: l10n.editorSanitize,
            description: l10n.editorSanitizeDesc,
            value: rule.sanitize,
            onChanged: (value) => onChanged(rule.copyWith(sanitize: value)),
          ),
        ],
      ),
    );
  }
}
