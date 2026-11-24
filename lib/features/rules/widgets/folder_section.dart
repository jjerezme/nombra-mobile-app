import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/screen_header.dart';
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
    return AppSection(
      title: '${l10n.editorFolderTitle} ${l10n.editorOptional}',
      child: AppCard.stack(
        children: [
          LabeledField(
            hint: selected == null ? l10n.editorNoFolderDesc : l10n.editorFolderAlways,
            child: Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(AppLayout.controlRadius),
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Icon(
                    selected == null ? Icons.create_new_folder_outlined : Icons.folder_outlined,
                    size: AppIconSize.md,
                    color: selected == null ? colors.onSurfaceVariant : colors.primary,
                  ),
                  Expanded(
                    child: Text(
                      selected?.path ?? l10n.editorNoFolderTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: selected == null
                          ? context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)
                          : context.monoStyles.mono,
                    ),
                  ),
                  TextButton(
                    onPressed: onPickFolder,
                    child: Text(selected == null ? l10n.editorPickFolder : l10n.change),
                  ),
                  if (selected != null)
                    IconButton(
                      onPressed: onClearFolder,
                      tooltip: l10n.editorRemoveFolderTooltip,
                      icon: const Icon(Icons.close, size: AppIconSize.base),
                    ),
                ],
              ),
            ),
          ),
          LabeledField(
            label: l10n.editorIfExists,
            child: SegmentedToggle<ConflictPolicy>(
              options: [
                ToggleOption(ConflictPolicy.suffix, l10n.editorConflictSuffix),
                ToggleOption(ConflictPolicy.replace, l10n.editorConflictReplace),
                ToggleOption(ConflictPolicy.ask, l10n.editorConflictAsk),
              ],
              selected: conflict,
              onChanged: onConflictChanged,
            ),
          ),
        ],
      ),
    );
  }
}
