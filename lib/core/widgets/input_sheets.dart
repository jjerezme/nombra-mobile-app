import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// Shows [builder] in a modal sheet at the bottom of the screen. Everything the user types or picks, apart from a
/// yes/no question, goes through a sheet like this one.
Future<T?> showInputSheet<T>({required BuildContext context, required WidgetBuilder builder}) {
  // The root navigator: the sheet covers the whole screen, navigation bar included, instead of sitting above it.
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: builder,
  );
}

/// The layout every bottom sheet shares: a title, the content, and the buttons, with the standard margins. It keeps
/// clear of the keyboard and of the Android navigation bar.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({required this.title, required this.children, super.key, this.actions});

  final String title;
  final List<Widget> children;

  /// Buttons at the bottom, normally a [SheetActions].
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final bottom = actions;
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
            Text(title, style: context.text.titleLarge),
            ...children,
            ?bottom,
          ],
        ),
      ),
    );
  }
}

/// Cancel and accept side by side. [onAccept] null disables the accept button.
class SheetActions extends StatelessWidget {
  const SheetActions({required this.onCancel, required this.onAccept, super.key, this.acceptLabel});

  final VoidCallback onCancel;
  final VoidCallback? onAccept;

  /// Text of the accept button; "Accept" when null.
  final String? acceptLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      spacing: AppLayout.buttonGap,
      children: [
        Expanded(
          child: OutlinedButton(onPressed: onCancel, child: Text(l10n.cancel)),
        ),
        Expanded(
          child: FilledButton(onPressed: onAccept, child: Text(acceptLabel ?? l10n.accept)),
        ),
      ],
    );
  }
}

/// Asks for one line of text in a bottom sheet; null when cancelled. [validator] returns the error to show (null when
/// valid) and the sheet stays open until the text is valid.
Future<String?> showTextSheet(
  BuildContext context, {
  required String title,
  required String hint,
  String initialText = '',
  String? Function(String value)? validator,
}) {
  return showInputSheet<String>(
    context: context,
    builder: (context) => _TextSheet(title: title, hint: hint, initialText: initialText, validator: validator),
  );
}

class _TextSheet extends StatefulWidget {
  const _TextSheet({required this.title, required this.hint, required this.initialText, this.validator});

  final String title;
  final String hint;
  final String initialText;
  final String? Function(String value)? validator;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  // Owned by the State: it is disposed with the sheet, after the closing animation, not before.
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
    return SheetScaffold(
      title: widget.title,
      actions: SheetActions(onCancel: () => Navigator.of(context).pop(), onAccept: _accept),
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() => _error = null),
          onSubmitted: (_) => _accept(),
          style: context.monoStyles.mono,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: _error,
            constraints: const BoxConstraints(minHeight: AppSize.control),
          ),
        ),
      ],
    );
  }
}
