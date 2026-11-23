import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

class ToggleOption<T> {
  const ToggleOption(this.value, this.label);

  final T value;
  final String label;
}

/// Two or three exclusive options in one pill-shaped track; the selected one is raised.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({required this.options, required this.selected, required this.onChanged, super.key});

  final List<ToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: option.value == selected,
                child: Material(
                  color: option.value == selected ? colors.surface : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  elevation: option.value == selected ? 1 : 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () => onChanged(option.value),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: minTouchTarget),
                      child: Center(
                        child: Text(
                          option.label,
                          textAlign: TextAlign.center,
                          style: context.text.labelMedium?.copyWith(
                            fontSize: AppFontSize.md,
                            color: option.value == selected ? colors.onSurface : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
