import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// "Final name": the proposed name without extension, editable by hand, and the fixed extension.
class ShareNameField extends StatelessWidget {
  const ShareNameField({
    required this.baseName,
    required this.extension,
    required this.isManual,
    required this.onChanged,
    super.key,
  });

  final String baseName;
  final String extension;

  /// Whether the user typed the name; keeps the field from being rebuilt on every keystroke.
  final bool isManual;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(l10n.shareFinalName, style: context.text.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
        Container(
          constraints: const BoxConstraints(minHeight: AppSize.button),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.tight, 0),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            border: Border.all(color: colors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            spacing: AppSpacing.tight,
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey(isManual ? 'manual' : baseName),
                  initialValue: baseName,
                  onChanged: onChanged,
                  style: context.monoStyles.mono.copyWith(fontSize: AppFontSize.md),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (extension.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.snug, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text('.$extension', style: context.monoStyles.mono.copyWith(color: colors.tertiary)),
                ),
            ],
          ),
        ),
        Text(l10n.shareExtensionKept, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}
