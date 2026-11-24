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

/// A row with a switch: label, optional description and the switch on the right. The whole row is tappable.
class ToggleRow extends StatelessWidget {
  const ToggleRow({required this.label, required this.value, required this.onChanged, super.key, this.description});

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final detail = description;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppLayout.controlRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minTouchTarget),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs,
                  children: [
                    Text(label, style: context.text.bodyMedium),
                    if (detail != null)
                      Text(detail, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row with an icon, a title and a hint that does something when tapped (settings actions).
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
    final color = isDestructive ? colors.error : colors.onSurface;
    final hintText = hint;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppLayout.controlRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minTouchTarget),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            Icon(icon, size: AppIconSize.md, color: color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.bodyLarge?.copyWith(color: color)),
                  if (hintText != null)
                    Text(hintText, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
