import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A small label that only informs (an option of a rule, "default", where a folder comes from): the Material [Chip],
/// compact and not tappable.
class TagChip extends StatelessWidget {
  const TagChip({required this.label, super.key, this.isHighlighted = false});

  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = isHighlighted ? colors.onPrimaryContainer : colors.onSecondaryContainer;
    return Chip(
      label: Text(label),
      labelStyle: context.text.labelSmall?.copyWith(color: textColor),
      backgroundColor: isHighlighted ? colors.primaryContainer : colors.secondaryContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
