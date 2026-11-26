import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// A control with its label above and an optional hint below: the one way fields are laid out in the app.
class LabeledField extends StatelessWidget {
  const LabeledField({required this.child, super.key, this.label, this.hint});

  final String? label;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hintText = hint;
    final labelText = label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppLayout.labelGap,
      children: [
        if (labelText != null)
          Text(labelText, style: context.text.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
        child,
        if (hintText != null) Text(hintText, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}

/// A row with a switch: the Material [SwitchListTile] (label, optional description, the switch on the right).
class ToggleRow extends StatelessWidget {
  const ToggleRow({required this.label, required this.value, required this.onChanged, super.key, this.description});

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final detail = description;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: detail == null ? null : Text(detail),
    );
  }
}

/// An action in a list: the Material [ListTile] with a leading icon, a title and an optional hint. A destructive one
/// is drawn in the error color.
class ActionRow extends StatelessWidget {
  const ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.hint,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hintText = hint;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      iconColor: isDestructive ? colors.error : colors.onSurface,
      textColor: isDestructive ? colors.error : colors.onSurface,
      leading: Icon(icon),
      title: Text(title),
      subtitle: hintText == null ? null : Text(hintText),
    );
  }
}
