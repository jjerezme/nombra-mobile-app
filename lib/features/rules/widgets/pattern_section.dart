import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validation.dart';
import '../../../core/widgets/input_sheets.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/rename_rule.dart';

/// The pattern as a row of tokens, and the palette to add more. At most [PatternTokens.maxCount] tokens fit; a text
/// token is edited by tapping it, and so are the digits of a number token.
class PatternSection extends StatelessWidget {
  const PatternSection({required this.tokens, required this.onChanged, this.errorText, super.key});

  final List<String> tokens;
  final ValueChanged<List<String>> onChanged;

  /// Shown under the pattern when it cannot be saved.
  final String? errorText;

  bool get _isFull => tokens.length >= PatternTokens.maxCount;

  Future<String?> _askText(BuildContext context, {String initialText = ''}) {
    final l10n = AppLocalizations.of(context);
    return showTextSheet(
      context,
      title: l10n.editorTextDialogTitle,
      hint: l10n.editorTextDialogHint,
      initialText: initialText,
      validator: (value) => validatePatternText(value)?.message(l10n),
    );
  }

  /// Asks how many digits the number has; null when cancelled.
  Future<String?> _askCounter(BuildContext context, {int digits = PatternTokens.defaultCounterDigits}) async {
    final chosen = await showDigitsSheet(context, initial: digits);
    return chosen == null ? null : PatternTokens.counterWith(chosen);
  }

  Future<void> _add(BuildContext context, String token) async {
    if (_isFull) return;
    var next = token;
    if (token == PatternTokens.counter) {
      final counter = await _askCounter(context);
      if (counter == null) return;
      next = counter;
    } else if (token == PatternTokens.textPlaceholder) {
      final text = await _askText(context);
      if (text == null) return;
      next = text;
    }
    onChanged([...tokens, next]);
  }

  Future<void> _edit(BuildContext context, int index) async {
    final token = tokens[index];
    String? replacement;
    if (PatternTokens.isCounter(token)) {
      replacement = await _askCounter(context, digits: PatternTokens.counterDigits(token));
    } else if (PatternTokens.isEditable(token)) {
      replacement = await _askText(context, initialText: token);
    }
    if (replacement == null || replacement == token) return;
    onChanged([...tokens]..[index] = replacement);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppLayout.labelGap,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppSize.control),
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            border: Border.all(color: errorText == null ? colors.primary : colors.error, width: 1.5),
            borderRadius: BorderRadius.circular(AppLayout.controlRadius),
          ),
          // The tokens and the delete button share one center line, also when there are no tokens.
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var i = 0; i < tokens.length; i++)
                      _TokenChip(
                        label: _labelOf(tokens[i]),
                        isToken: PatternTokens.isToken(tokens[i]),
                        onTap: PatternTokens.isCounter(tokens[i]) || PatternTokens.isEditable(tokens[i])
                            ? () => _edit(context, i)
                            : null,
                      ),
                    Text('.ext', style: context.monoStyles.mono.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton(
                onPressed: tokens.isEmpty ? null : () => onChanged(tokens.sublist(0, tokens.length - 1)),
                tooltip: l10n.editorBackspaceTooltip,
                icon: const Icon(Icons.backspace_outlined, size: AppIconSize.base),
              ),
            ],
          ),
        ),
        if (errorText != null) Text(errorText!, style: context.text.bodySmall?.copyWith(color: colors.error)),
        Text(
          _isFull ? l10n.editorMaxTokens(PatternTokens.maxCount) : l10n.editorTapToInsert,
          style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            // A token already in the pattern leaves the palette; separators and free text stay.
            for (final token in PatternTokens.palette.where((token) => !PatternTokens.isUsed(token, tokens)))
              _PaletteChip(
                label: token == PatternTokens.counter ? '{n}' : _labelOf(token),
                semanticLabel: token == PatternTokens.space ? l10n.editorSpaceToken : null,
                onTap: _isFull ? null : () => _add(context, token),
              ),
            _PaletteChip(
              label: l10n.editorAddText,
              onTap: _isFull ? null : () => _add(context, PatternTokens.textPlaceholder),
            ),
          ],
        ),
      ],
    );
  }

  /// What a token looks like inside the pattern box: a blank space is shown as a visible mark.
  String _labelOf(String token) => token.trim().isEmpty ? PatternTokens.spaceMark : token;
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({required this.label, required this.isToken, this.onTap});

  final String label;
  final bool isToken;

  /// Opens the editor of this token; null when there is nothing to edit.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: isToken ? colors.primaryContainer : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: isToken ? BorderSide.none : BorderSide(color: colors.primary.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: AppIconSize.md),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.monoStyles.mono.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: isToken ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteChip extends StatelessWidget {
  const _PaletteChip({required this.label, required this.onTap, this.semanticLabel});

  final String label;
  final String? semanticLabel;

  /// Null when the pattern is full: the chip is shown dimmed and does nothing.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onTap != null;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.4,
        child: Material(
          color: colors.primaryContainer.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minTouchTarget, minWidth: minTouchTarget),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: context.monoStyles.mono.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks, in a bottom sheet, how many digits the sequential number has (`{n:3}` writes `007`); null when cancelled.
Future<int?> showDigitsSheet(BuildContext context, {required int initial}) {
  return showInputSheet<int>(
    context: context,
    builder: (context) => _DigitsSheet(initial: initial),
  );
}

class _DigitsSheet extends StatefulWidget {
  const _DigitsSheet({required this.initial});

  final int initial;

  @override
  State<_DigitsSheet> createState() => _DigitsSheetState();
}

class _DigitsSheetState extends State<_DigitsSheet> {
  late int _digits = widget.initial.clamp(1, PatternTokens.maxCounterDigits);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return SheetScaffold(
      title: l10n.editorDigitsTitle,
      actions: SheetActions(
        onCancel: () => Navigator.of(context).pop(),
        onAccept: () => Navigator.of(context).pop(_digits),
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppLayout.sectionGap,
          children: [
            IconButton.outlined(
              onPressed: _digits > 1 ? () => setState(() => _digits--) : null,
              tooltip: l10n.editorDigitsLess,
              icon: const Icon(Icons.remove),
            ),
            Flexible(
              child: Text(
                l10n.editorDigitsCount(_digits),
                style: context.text.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton.outlined(
              onPressed: _digits < PatternTokens.maxCounterDigits ? () => setState(() => _digits++) : null,
              tooltip: l10n.editorDigitsMore,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Center(
          child: Text(
            l10n.editorDigitsExample(PatternTokens.counterExample(_digits)),
            style: context.monoStyles.mono.copyWith(color: colors.primary),
          ),
        ),
      ],
    );
  }
}
