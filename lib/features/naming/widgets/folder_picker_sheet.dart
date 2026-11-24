import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/validation.dart';
import '../../../core/widgets/form_parts.dart';
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

  InputError? get _error => validateSubfolder(_subfolder.text);

  DestinationFolder get _folder => DestinationFolder(_root, _subfolder.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // useSafeArea of the sheet leaves the bottom out, so the Android navigation bar is avoided here.
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppLayout.sheetGutter,
          AppSpacing.sm,
          AppLayout.sheetGutter,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppLayout.sectionGap,
          children: [
            Text(l10n.folderPickerTitle, style: context.text.titleLarge),
            LabeledField(
              label: l10n.folderPickerRoot,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final root in StorageRoot.values)
                    PillChoice(
                      label: root.dirName,
                      isSelected: root == _root,
                      onTap: () => setState(() => _root = root),
                    ),
                ],
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
            FilledButton(
              onPressed: _error == null ? () => Navigator.of(context).pop(_folder) : null,
              child: Text(l10n.folderPickerUse),
            ),
          ],
        ),
      ),
    );
  }
}
