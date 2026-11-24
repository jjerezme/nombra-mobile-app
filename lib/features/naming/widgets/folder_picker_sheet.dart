import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validation.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/input_sheets.dart';
import '../../../core/widgets/pill_choice.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/domain/storage_root.dart';

/// Lets the user pick a public folder (Download, Documents, ...) and an optional subfolder.
Future<DestinationFolder?> showFolderPicker(BuildContext context, DestinationFolder initial) {
  return showInputSheet<DestinationFolder>(
    context: context,
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

  InputError? get _error => validateSubfolder(_subfolder.text);

  DestinationFolder get _folder => DestinationFolder(_root, _subfolder.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetScaffold(
      title: l10n.folderPickerTitle,
      actions: FilledButton(
        onPressed: _error == null ? () => Navigator.of(context).pop(_folder) : null,
        child: Text(l10n.folderPickerUse),
      ),
      children: [
        LabeledField(
          label: l10n.folderPickerRoot,
          // One row of chips that scrolls sideways: all the folders are one swipe away on a narrow screen.
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                for (final root in StorageRoot.values)
                  PillChoice(label: root.dirName, isSelected: root == _root, onTap: () => setState(() => _root = root)),
              ],
            ),
          ),
        ),
        LabeledField(
          label: l10n.folderPickerSubfolder,
          hint: _folder.path,
          child: TextField(
            controller: _subfolder,
            onChanged: (_) => setState(() {}),
            style: context.monoStyles.mono,
            decoration: InputDecoration(
              errorText: _error?.message(l10n, max: maxSubfolderLength),
              constraints: const BoxConstraints(minHeight: AppSize.control),
            ),
          ),
        ),
      ],
    );
  }
}
