import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// A small pill with a short label that only informs (an option of a rule, "default", where a folder comes from). It is
/// not tappable.
class TagChip extends StatelessWidget {
  const TagChip({required this.label, super.key, this.isHighlighted = false});

  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: isHighlighted ? colors.primaryContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: isHighlighted ? colors.onPrimaryContainer : colors.onSecondaryContainer,
        ),
      ),
    );
  }
}
