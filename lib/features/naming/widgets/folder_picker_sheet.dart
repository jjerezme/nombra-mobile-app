import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pill_choice.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/domain/storage_root.dart';

/// Lets the user pick a public folder (Download, Documents, ...) and an optional subfolder.
Future<DestinationFolder?> showFolderPicker(BuildContext context, DestinationFolder initial) {
  return showModalBottomSheet<DestinationFolder>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _FolderPickerSheet(initial: initial),
  );
}

class _FolderPickerSheet extends StatefulWidget {
  const _FolderPickerSheet({required this.initial});

  final DestinationFolder initial;

  @override
  State<_FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<_FolderPickerSheet> {
  late StorageRoot _root = widget.initial.root;
  late final TextEditingController _subfolder = TextEditingController(text: widget.initial.subfolder);

  @override
  void dispose() {
    _subfolder.dispose();
    super.dispose();
  }

  DestinationFolder get _folder => DestinationFolder(_root, _subfolder.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.lg,
        children: [
          Text(l10n.folderPickerTitle, style: context.text.titleLarge),
          Text(l10n.folderPickerRoot, style: context.text.labelMedium),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final root in StorageRoot.values)
                PillChoice(label: root.dirName, isSelected: root == _root, onTap: () => setState(() => _root = root)),
            ],
          ),
          Text(l10n.folderPickerSubfolder, style: context.text.labelMedium),
          TextField(
            controller: _subfolder,
            onChanged: (_) => setState(() {}),
            style: context.monoStyles.mono,
            decoration: InputDecoration(
              hintText: l10n.folderPickerSubfolderHint,
              constraints: const BoxConstraints(minHeight: AppSize.control),
            ),
          ),
          Text(_folder.path, style: context.monoStyles.mono.copyWith(color: context.colors.primary)),
          FilledButton(onPressed: () => Navigator.of(context).pop(_folder), child: Text(l10n.folderPickerUse)),
        ],
      ),
    );
  }
}
