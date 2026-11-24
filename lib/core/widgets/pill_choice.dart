import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// A rounded option that can be selected, used for rules and small exclusive choices.
class PillChoice extends StatelessWidget {
  const PillChoice({required this.label, required this.isSelected, required this.onTap, super.key, this.semanticLabel})
    : icon = null;

  /// Same size and shape as a choice, but tinted and with an icon: it does something (add) instead of picking a value.
  const PillChoice.action({required this.label, required this.icon, required this.onTap, super.key, this.semanticLabel})
    : isSelected = false;

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? semanticLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leading = icon;
    final isAction = leading != null;
    final textColor = isSelected
        ? colors.onPrimary
        : isAction
        ? colors.onPrimaryContainer
        : colors.onSurface;
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: isSelected
            ? colors.primary
            : isAction
            ? colors.primaryContainer
            : colors.surface,
        shape: StadiumBorder(side: BorderSide(color: isSelected || isAction ? colors.primary : colors.outline)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minTouchTarget, minWidth: minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(
                widthFactor: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.xs,
                  children: [
                    if (leading != null) Icon(leading, size: AppIconSize.sm, color: textColor),
                    Text(
                      label,
                      style: context.text.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: isSelected || isAction ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
