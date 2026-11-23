import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pill_choice.dart';
import '../../../core/widgets/segmented_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/data/rules_notifier.dart';
import '../../rules/domain/name_resolver.dart';
import '../../settings/app_settings.dart';

/// Saved rule or quick prefix/suffix: the naming choice shared by Home and the share sheet.
class RuleSelector extends ConsumerWidget {
  const RuleSelector({super.key, this.selectedRuleId, this.onEditRules, this.onRuleSelected});

  /// The rule currently in effect, so the chip is highlighted even before the user taps one.
  final String? selectedRuleId;

  /// Opens the rules screen; hidden when null (the share sheet has no router).
  final VoidCallback? onEditRules;

  /// Called after the user picks a rule.
  final ValueChanged<String>? onRuleSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final rules = ref.watch(rulesProvider).where((rule) => rule.isEnabled).toList();
    final notifier = ref.read(settingsProvider.notifier);
    final activeId = selectedRuleId ?? selectRule(settings, rules)?.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.ruleLabel, style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                l10n.ruleRemembered,
                textAlign: TextAlign.end,
                style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        SegmentedToggle<NamingMode>(
          options: [ToggleOption(NamingMode.saved, l10n.modeSaved), ToggleOption(NamingMode.quick, l10n.modeQuick)],
          selected: settings.mode,
          onChanged: notifier.setMode,
        ),
        if (settings.mode == NamingMode.saved)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (rules.isEmpty) Text(l10n.noEnabledRules, style: context.text.bodySmall),
              for (final rule in rules)
                PillChoice(
                  label: rule.name,
                  isSelected: rule.id == activeId,
                  onTap: () {
                    notifier.setRule(rule.id);
                    onRuleSelected?.call(rule.id);
                  },
                ),
              if (onEditRules != null) TextButton(onPressed: onEditRules, child: Text(l10n.editRules)),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: _AffixField(
                  label: l10n.prefix,
                  hint: l10n.prefixHint,
                  value: settings.prefix,
                  onChanged: notifier.setPrefix,
                ),
              ),
              Expanded(
                child: _AffixField(
                  label: l10n.suffix,
                  hint: l10n.suffixHint,
                  value: settings.suffix,
                  onChanged: notifier.setSuffix,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AffixField extends StatelessWidget {
  const _AffixField({required this.label, required this.hint, required this.value, required this.onChanged});

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(label, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          style: context.monoStyles.mono,
          decoration: InputDecoration(
            hintText: hint,
            constraints: const BoxConstraints(minHeight: AppSize.control),
          ),
        ),
      ],
    );
  }
}
