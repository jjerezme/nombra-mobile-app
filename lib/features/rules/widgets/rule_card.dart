import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/tag_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/filename_builder.dart';
import '../domain/rename_rule.dart';
import '../domain/sample_file.dart';

/// Short labels of the extra options a rule has turned on, in the order they apply to the name. The conflict policy is
/// always listed because every rule has one.
List<String> ruleOptions(AppLocalizations l10n, RenameRule rule) => [
  switch (rule.caseMode) {
    CaseMode.upper => l10n.editorCaseUpper,
    CaseMode.lower => l10n.editorCaseLower,
    CaseMode.keep => null,
  },
  if (rule.removeCopySuffix) l10n.ruleOptCopySuffix,
  if (rule.replaceSpaces) l10n.ruleOptSpaces(rule.spaceChar),
  if (rule.sanitize) l10n.ruleOptSanitize,
  l10n.ruleOptConflict(switch (rule.conflict) {
    ConflictPolicy.suffix => l10n.editorConflictSuffix,
    ConflictPolicy.replace => l10n.editorConflictReplace,
    ConflictPolicy.ask => l10n.editorConflictAsk,
  }),
].nonNulls.toList();

/// A rule in the list: name, tokens, example, extra options and destination folder. Tapping the card opens the rule.
/// Every card has the same rows, in the same order, aligned to the same left edge, close together.
class RuleCard extends StatelessWidget {
  const RuleCard({required this.rule, required this.onTap, super.key});

  final RenameRule rule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final mono = context.monoStyles.monoSmall;
    final example = buildFileName(rule, sampleFile, now: DateTime.now());
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Row(
            spacing: AppSpacing.sm,
            children: [
              Flexible(child: Text(rule.name, style: context.text.titleMedium)),
              if (rule.isDefault) TagChip(label: l10n.ruleDefaultBadge, isHighlighted: true),
            ],
          ),
          _DetailRow(
            icon: Icons.data_array,
            child: _Line(_visible(rule.pattern), style: mono.copyWith(color: colors.primary)),
          ),
          _DetailRow(
            icon: Icons.arrow_forward,
            child: _Line(example, style: mono.copyWith(color: colors.onSurfaceVariant)),
          ),
          _DetailRow(
            icon: Icons.tune,
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [for (final option in ruleOptions(l10n, rule)) TagChip(label: option)],
            ),
          ),
          _DetailRow(
            icon: Icons.folder_outlined,
            child: _Line(rule.folder?.path ?? l10n.ruleNoFolder, style: mono),
          ),
        ],
      ),
    );
  }

  /// A blank space in the pattern would be invisible; it is drawn as the same mark the editor uses.
  String _visible(String pattern) => pattern.replaceAll(PatternTokens.space, PatternTokens.spaceMark);
}

/// An icon and its content: the icon column is the same width on every row so the content lines up.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        // Same height as a line of text ([_Line]), so the icon is centered on the first line.
        SizedBox(
          height: AppIconSize.base,
          child: Icon(icon, size: AppIconSize.sm, color: context.colors.onSurfaceVariant),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// A line of text exactly as tall as the icon of its row ([AppIconSize.base]), so the icon and the first line share one
/// center, and a name that wraps keeps an even line spacing.
class _Line extends StatelessWidget {
  const _Line(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? AppFontSize.md;
    return Text(
      text,
      style: style,
      strutStyle: StrutStyle(
        fontFamily: style.fontFamily,
        fontSize: fontSize,
        height: AppIconSize.base / fontSize,
        forceStrutHeight: true,
      ),
    );
  }
}
