import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_choice.dart';
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
    return AppCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
            child: Text(l10n.editorTransformTitle, style: context.text.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.tight,
              children: [
                Text(l10n.editorCase, style: context.text.bodyMedium),
                SegmentedToggle<CaseMode>(
                  options: [
                    ToggleOption(CaseMode.keep, l10n.editorCaseKeep),
                    ToggleOption(CaseMode.upper, l10n.editorCaseUpper),
                    ToggleOption(CaseMode.lower, l10n.editorCaseLower),
                  ],
                  selected: rule.caseMode,
                  onChanged: (mode) => onChanged(rule.copyWith(caseMode: mode)),
                ),
              ],
            ),
          ),
          _SwitchRow(
            label: l10n.editorStripCopy,
            value: rule.removeCopySuffix,
            onChanged: (value) => onChanged(rule.copyWith(removeCopySuffix: value)),
          ),
          _SwitchRow(
            label: l10n.editorReplaceSpaces,
            value: rule.replaceSpaces,
            onChanged: (value) => onChanged(rule.copyWith(replaceSpaces: value)),
          ),
          if (rule.replaceSpaces)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Expanded(
                    child: Text(
                      l10n.editorReplaceWith,
                      style: context.text.bodySmall?.copyWith(fontSize: AppFontSize.caption),
                    ),
                  ),
                  for (final (char, name) in spaceChars)
                    PillChoice(
                      label: char,
                      semanticLabel: l10n.editorReplaceWithChar(name),
                      isSelected: rule.spaceChar == char,
                      onTap: () => onChanged(rule.copyWith(spaceChar: char)),
                    ),
                ],
              ),
            ),
          _SwitchRow(
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.value, required this.onChanged, this.description});

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final detail = description;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minTouchTarget),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.tight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs,
                    children: [
                      Text(label, style: context.text.bodyMedium),
                      if (detail != null)
                        Text(detail, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
