import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/segmented_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/rename_rule.dart';
import '../domain/storage_root.dart';

/// Optional fixed destination folder of a rule, and what to do when the name already exists.
class FolderSection extends StatelessWidget {
  const FolderSection({
    required this.folder,
    required this.conflict,
    required this.onPickFolder,
    required this.onClearFolder,
    required this.onConflictChanged,
    super.key,
  });

  final DestinationFolder? folder;
  final ConflictPolicy conflict;
  final VoidCallback onPickFolder;
  final VoidCallback onClearFolder;
  final ValueChanged<ConflictPolicy> onConflictChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final selected = folder;
    return AppCard(
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Text.rich(
            TextSpan(
              text: l10n.editorFolderTitle,
              style: context.text.titleSmall,
              children: [
                TextSpan(
                  text: ' ${l10n.editorOptional}',
                  style: context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (selected != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.tight,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.4),
                    border: Border.all(color: colors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.xl - AppSpacing.xxs),
                  ),
                  child: Row(
                    spacing: AppSpacing.sm,
                    children: [
                      Icon(Icons.folder_outlined, size: AppIconSize.md, color: colors.primary),
                      Expanded(
                        child: Text(
                          selected.path,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.monoStyles.mono,
                        ),
                      ),
                      TextButton(onPressed: onPickFolder, child: Text(l10n.change)),
                      IconButton(
                        onPressed: onClearFolder,
                        tooltip: l10n.editorRemoveFolderTooltip,
                        icon: const Icon(Icons.close, size: AppIconSize.base),
                      ),
                    ],
                  ),
                ),
                Text(l10n.editorFolderAlways, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                border: Border.all(color: colors.outline),
                borderRadius: BorderRadius.circular(AppRadius.xl - AppSpacing.xxs),
              ),
              child: Column(
                spacing: AppSpacing.sm,
                children: [
                  Icon(Icons.create_new_folder_outlined, size: AppIconSize.lg, color: colors.onSurfaceVariant),
                  Text(l10n.editorNoFolderTitle, style: context.text.labelLarge?.copyWith(fontSize: AppFontSize.md)),
                  Text(
                    l10n.editorNoFolderDesc,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  OutlinedButton(
                    onPressed: onPickFolder,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, AppSize.control),
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    ),
                    child: Text(l10n.editorPickFolder),
                  ),
                ],
              ),
            ),
          Text(l10n.editorIfExists, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          SegmentedToggle<ConflictPolicy>(
            options: [
              ToggleOption(ConflictPolicy.suffix, l10n.editorConflictSuffix),
              ToggleOption(ConflictPolicy.replace, l10n.editorConflictReplace),
              ToggleOption(ConflictPolicy.ask, l10n.editorConflictAsk),
            ],
            selected: conflict,
            onChanged: onConflictChanged,
          ),
        ],
      ),
    );
  }
}
