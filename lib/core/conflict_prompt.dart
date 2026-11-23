import 'package:material_ui/material_ui.dart';

import '../features/download/data/file_finalizer.dart';
import '../features/rules/domain/storage_root.dart';
import '../l10n/app_localizations.dart';

/// Key of the root navigator, so dialogs can be shown from code that has no BuildContext.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Asks what to do when a file with the same name already exists; keeps both when no screen is available.
Future<ConflictChoice> promptConflict(String fileName, DestinationFolder folder) async {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return ConflictChoice.keepBoth;
  final l10n = AppLocalizations.of(context);
  final choice = await showDialog<ConflictChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.conflictTitle),
      content: Text(l10n.conflictBody(fileName, folder.path)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(ConflictChoice.cancel), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ConflictChoice.keepBoth),
          child: Text(l10n.conflictKeepBoth),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ConflictChoice.replace),
          child: Text(l10n.conflictReplace),
        ),
      ],
    ),
  );
  return choice ?? ConflictChoice.keepBoth;
}
