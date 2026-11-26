import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';

/// A choice of a short list (a rule, a pattern token): the Material 3 [ChoiceChip]. [PillChoice.action] is an
/// [ActionChip]: same size and shape, but it does something (add) instead of picking a value.
class PillChoice extends StatelessWidget {
  const PillChoice({required this.label, required this.isSelected, required this.onTap, super.key, this.semanticLabel})
    : icon = null;

  const PillChoice.action({required this.label, required this.icon, required this.onTap, super.key, this.semanticLabel})
    : isSelected = false;

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Read by a screen reader instead of [label] (a space token reads as "space", not as an empty chip).
  final String? semanticLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final leading = icon;
    final chip = leading == null
        ? ChoiceChip(label: Text(label), selected: isSelected, onSelected: (_) => onTap())
        : ActionChip(
            avatar: Icon(leading, size: AppIconSize.base),
            label: Text(label),
            onPressed: onTap,
          );
    final spoken = semanticLabel;
    if (spoken == null) return chip;
    return Semantics(
      button: true,
      selected: isSelected,
      label: spoken,
      excludeSemantics: true,
      onTap: onTap,
      child: chip,
    );
  }
}
