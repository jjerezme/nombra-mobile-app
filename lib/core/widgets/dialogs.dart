import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Asks for confirmation; true when the user accepts.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(confirmLabel)),
      ],
    ),
  );
  return result ?? false;
}

/// Asks for one line of text; null when cancelled. [validator] returns the error to show (null when valid) and
/// the dialog stays open until the text is valid.
Future<String?> showTextDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String initialText = '',
  String? Function(String value)? validator,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextDialog(title: title, hint: hint, initialText: initialText, validator: validator),
  );
}

class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.title, required this.hint, required this.initialText, this.validator});

  final String title;
  final String hint;
  final String initialText;
  final String? Function(String value)? validator;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  // Owned by the State: it is disposed with the dialog, after the closing animation, not before.
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _accept() {
    final text = _controller.text;
    final error = widget.validator?.call(text) ?? (text.trim().isEmpty ? '' : null);
    if (error != null) {
      setState(() => _error = error.isEmpty ? null : error);
      return;
    }
    Navigator.of(context).pop(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: (_) => setState(() => _error = null),
        onSubmitted: (_) => _accept(),
        decoration: InputDecoration(hintText: widget.hint, errorText: _error),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        TextButton(onPressed: _accept, child: Text(l10n.accept)),
      ],
    );
  }
}
