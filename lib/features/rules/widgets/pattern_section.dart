import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/rename_rule.dart';

/// The pattern as a row of tokens, and the palette to add more.
class PatternSection extends StatelessWidget {
  const PatternSection({required this.tokens, required this.onChanged, super.key});

  final List<String> tokens;
  final ValueChanged<List<String>> onChanged;

  Future<void> _addText(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final text = await showTextDialog(context, title: l10n.editorTextDialogTitle, hint: l10n.editorTextDialogHint);
    if (text != null) onChanged([...tokens, text]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AppCard(
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.editorPattern, style: context.text.titleSmall),
              IconButton(
                onPressed: tokens.isEmpty ? null : () => onChanged(tokens.sublist(0, tokens.length - 1)),
                tooltip: l10n.editorBackspaceTooltip,
                icon: const Icon(Icons.backspace_outlined, size: AppIconSize.base),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: AppSize.control),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              border: Border.all(color: colors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final token in tokens) _TokenChip(label: token, isToken: PatternTokens.isToken(token)),
                Text('.ext', style: context.monoStyles.mono.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(l10n.editorTapToInsert, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          Wrap(
            spacing: AppSpacing.tight,
            runSpacing: AppSpacing.tight,
            children: [
              for (final token in PatternTokens.palette)
                _PaletteChip(label: token, onTap: () => onChanged([...tokens, token])),
              _PaletteChip(label: l10n.editorAddText, onTap: () => _addText(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({required this.label, required this.isToken});

  final String label;
  final bool isToken;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: AppIconSize.md),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isToken ? colors.primaryContainer : colors.surface,
        border: isToken ? null : Border.all(color: colors.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: context.monoStyles.mono.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: isToken ? FontWeight.w400 : FontWeight.w600,
        ),
      ),
    );
  }
}

class _PaletteChip extends StatelessWidget {
  const _PaletteChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg - AppSpacing.xxs),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg - AppSpacing.xxs)),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minTouchTarget, minWidth: minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: context.monoStyles.mono.copyWith(color: colors.onPrimaryContainer, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
