import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validation.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/pill_choice.dart';
import '../../../core/widgets/segmented_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/data/rules_notifier.dart';
import '../../rules/domain/name_resolver.dart';
import '../../rules/widgets/pattern_section.dart';
import '../../settings/app_settings.dart';

/// Saved rule or quick pattern: the naming choice shared by Home and the share sheet.
class RuleSelector extends ConsumerWidget {
  const RuleSelector({super.key, this.selectedRuleId, this.onAddRule, this.onRuleSelected});

  /// The rule currently in effect, so the chip is highlighted even before the user taps one.
  final String? selectedRuleId;

  /// Opens the new rule screen; the "add" chip is hidden when null (the share sheet has no router).
  final VoidCallback? onAddRule;

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
      spacing: AppLayout.sectionGap,
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
          options: [
            ToggleOption(NamingMode.none, l10n.modeNone),
            ToggleOption(NamingMode.saved, l10n.modeSaved),
            ToggleOption(NamingMode.quick, l10n.modeQuick),
          ],
          selected: settings.mode,
          onChanged: notifier.setMode,
        ),
        if (settings.mode == NamingMode.none)
          Text(l10n.modeNoneHint, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant))
        else if (settings.mode == NamingMode.saved)
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
              // An action, not a rule: tinted and with a plus, so it is not read as one more rule to pick.
              if (onAddRule != null)
                ActionChip(
                  onPressed: onAddRule,
                  avatar: Icon(Icons.add, size: AppIconSize.sm, color: context.colors.onPrimaryContainer),
                  label: Text(l10n.ruleAdd),
                  labelStyle: context.text.labelMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: context.colors.primaryContainer,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
            ],
          )
        else
          _QuickOptions(settings: settings, notifier: notifier),
      ],
    );
  }
}

/// Quick mode: the name is built from the same tokens as a rule. It is not a saved rule: this one pattern is kept and
/// used every time a file is saved in quick mode.
class _QuickOptions extends StatelessWidget {
  const _QuickOptions({required this.settings, required this.notifier});

  final AppSettings settings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppLayout.sectionGap,
      children: [
        LabeledField(
          label: l10n.editorPattern,
          child: PatternSection(
            tokens: settings.quickTokens,
            onChanged: notifier.setQuickTokens,
            errorText: patternHasContent(settings.quickTokens) ? null : l10n.errPatternEmpty,
          ),
        ),
        if (settings.quickUsesCounter)
          _NextNumberField(
            label: l10n.quickNext,
            hint: l10n.quickNextHint,
            value: settings.nextQuickNumber,
            onChanged: notifier.setQuickNext,
          ),
      ],
    );
  }
}

/// Next sequential number: editable by hand, and refreshed when a file takes it (unless the field has the focus).
class _NextNumberField extends StatefulWidget {
  const _NextNumberField({required this.label, required this.hint, required this.value, required this.onChanged});

  final String label;
  final String hint;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_NextNumberField> createState() => _NextNumberFieldState();
}

class _NextNumberFieldState extends State<_NextNumberField> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.value}');
  final FocusNode _focus = FocusNode();
  InputError? _error;

  @override
  void didUpdateWidget(_NextNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A change that did not come from typing (a file took the number, or the pattern changed and the sequence
    // started again) replaces the text, even while the field has the focus.
    if (widget.value != oldWidget.value && int.tryParse(_controller.text.trim()) != widget.value) {
      _controller.text = '${widget.value}';
      _error = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _changed(String text) {
    final error = validateSequenceNumber(text);
    setState(() => _error = error);
    if (error == null) widget.onChanged(int.parse(text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(widget.label, style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
        TextField(
          controller: _controller,
          focusNode: _focus,
          keyboardType: TextInputType.number,
          onChanged: _changed,
          style: context.monoStyles.mono,
          decoration: InputDecoration(
            errorText: _error?.message(l10n),
            constraints: const BoxConstraints(minHeight: AppSize.control),
          ),
        ),
        Text(widget.hint, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
      ],
    );
  }
}
