import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/domain/name_resolver.dart';
import '../../rules/domain/rename_rule.dart';

String folderSourceLabel(AppLocalizations l10n, FolderSource source, RenameRule? rule) => switch (source) {
  FolderSource.rule => l10n.folderSourceRule(rule?.name ?? ''),
  FolderSource.lastUsed => l10n.folderSourceLastUsed,
  FolderSource.chosen => l10n.folderSourceChosen,
};

/// "Save to" row: where the file will go, and a button to change it.
class DestinationCard extends StatelessWidget {
  const DestinationCard({required this.path, required this.sourceLabel, required this.onChange, super.key});

  final String path;
  final String sourceLabel;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
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
          Icon(Icons.folder_outlined, size: AppIconSize.md, color: colors.primary),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.saveIn(sourceLabel), style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                Text(path, style: context.monoStyles.mono),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: Text(l10n.change)),
        ],
      ),
    );
  }
}
