import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validation.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/pill_choice.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/data/rules_notifier.dart';
import '../../rules/domain/name_resolver.dart';
import '../../rules/widgets/pattern_section.dart';
import '../../settings/app_settings.dart';

/// How the file is named: a switch to apply a rule or keep the original name and, when on, one row of chips (custom
/// pattern, saved rules, add). Shared by Home and the share sheet.
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
    final rules = ref.watch(rulesProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final activeId = selectedRuleId ?? selectRule(settings, rules)?.id;
    final isApplying = settings.mode != NamingMode.none;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppLayout.sectionGap,
      children: [
        // Off: the file keeps its original name. On: it is named by a custom pattern or by one of the saved rules.
        SwitchListTile(
          value: isApplying,
          onChanged: (value) {
            if (value) {
              final lastRule = rules.where((rule) => rule.id == settings.lastRuleId).firstOrNull;
              lastRule == null ? notifier.setMode(NamingMode.quick) : notifier.chooseRule(lastRule.id);
            } else {
              notifier.setMode(NamingMode.none);
            }
          },
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.ruleApply, style: context.text.bodyLarge),
          subtitle: isApplying ? null : Text(l10n.modeNoneHint),
        ),
        // One row of chips that scrolls sideways: a custom pattern, each saved rule and, at the end, "add".
        if (isApplying)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                PillChoice(
                  label: l10n.modeQuick,
                  isSelected: settings.mode == NamingMode.quick,
                  onTap: () => notifier.setMode(NamingMode.quick),
                ),
                for (final rule in rules)
                  PillChoice(
                    label: rule.name,
                    isSelected: settings.mode == NamingMode.saved && rule.id == activeId,
                    onTap: () {
                      notifier.chooseRule(rule.id);
                      onRuleSelected?.call(rule.id);
                    },
                  ),
                // An action, not a rule: same size as the rules, tinted and with a plus.
                if (onAddRule != null) PillChoice.action(label: l10n.ruleAdd, icon: Icons.add, onTap: onAddRule!),
              ],
            ),
          ),
        if (settings.mode == NamingMode.quick) _QuickOptions(settings: settings, notifier: notifier),
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

  /// Starts the sequence again at 1.
  void _reset() {
    _controller.text = '1';
    setState(() => _error = null);
    widget.onChanged(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        Text(widget.label, style: context.text.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: TextField(
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
            ),
            // Same look as the paste button of the URL field.
            IconButton.outlined(
              onPressed: widget.value == 1 && _error == null ? null : _reset,
              tooltip: l10n.quickNextReset,
              icon: const Icon(Icons.restart_alt, size: AppIconSize.base),
              constraints: const BoxConstraints.tightFor(width: AppSize.control, height: AppSize.control),
              style: IconButton.styleFrom(
                side: BorderSide(color: colors.outlineVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppLayout.controlRadius)),
              ),
            ),
          ],
        ),
        Text(widget.hint, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
      ],
    );
  }
}
