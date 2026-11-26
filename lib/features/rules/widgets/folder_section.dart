import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/segmented_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../../naming/widgets/destination_card.dart';
import '../domain/rename_rule.dart';
import '../domain/storage_root.dart';

/// Optional fixed destination folder of a rule, and what to do when the name already exists.
class FolderSection extends StatelessWidget {
  const FolderSection({
    required this.folder,
    required this.conflict,
    required this.onPickFolder,
    required this.onConflictChanged,
    super.key,
  });

  final DestinationFolder? folder;
  final ConflictPolicy conflict;
  final VoidCallback onPickFolder;
  final ValueChanged<ConflictPolicy> onConflictChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = folder;
    return AppSection(
      title: '${l10n.editorFolderTitle} ${l10n.editorOptional}',
      child: AppCard.stack(
        children: [
          LabeledField(
            hint: selected == null ? l10n.editorNoFolderDesc : l10n.editorFolderAlways,
            child: DestinationCard(path: selected?.path, emptyLabel: l10n.editorNoFolderTitle, onChange: onPickFolder),
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
