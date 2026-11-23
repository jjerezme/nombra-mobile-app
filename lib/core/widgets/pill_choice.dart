import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// A rounded option that can be selected, used for rules and small exclusive choices.
class PillChoice extends StatelessWidget {
  const PillChoice({required this.label, required this.isSelected, required this.onTap, super.key, this.semanticLabel});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: isSelected ? colors.primary : colors.surface,
        shape: StadiumBorder(side: BorderSide(color: isSelected ? colors.primary : colors.outline)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minTouchTarget, minWidth: minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
