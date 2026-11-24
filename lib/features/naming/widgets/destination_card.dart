import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// The one way a folder is shown and changed: the selected path (or a message when there is none) and a button that
/// opens the folder picker. Used by Download, the share sheet, Settings and the rule editor.
class DestinationCard extends StatelessWidget {
  const DestinationCard({required this.path, required this.onChange, super.key, this.emptyLabel});

  /// Selected path; null when no folder is chosen (then [emptyLabel] is shown and the button says "Choose").
  final String? path;
  final VoidCallback onChange;

  /// Text shown instead of the path when [path] is null.
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final selected = path;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppLayout.controlRadius),
      ),
      child: Row(
        spacing: AppSpacing.md,
        children: [
          Icon(
            selected == null ? Icons.create_new_folder_outlined : Icons.folder_outlined,
            size: AppIconSize.md,
            color: selected == null ? colors.onSurfaceVariant : colors.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selected != null)
                  Text(selected, style: context.monoStyles.mono)
                else
                  Text(emptyLabel ?? '', style: context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: Text(selected == null ? l10n.editorPickFolder : l10n.change)),
        ],
      ),
    );
  }
}
