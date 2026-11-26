import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';

class ToggleOption<T> {
  const ToggleOption(this.value, this.label);

  final T value;
  final String label;
}

/// Two or three exclusive options: the Material 3 [SegmentedButton], full width, without the check icon.
///
/// Each label stays on one line: with little room it shrinks a little instead of wrapping or being cut.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({required this.options, required this.selected, required this.onChanged, super.key});

  final List<ToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: [
        for (final option in options)
          ButtonSegment<T>(
            value: option.value,
            label: FittedBox(fit: BoxFit.scaleDown, child: Text(option.label, maxLines: 1, softWrap: false)),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpacing.sm))),
    );
  }
}
