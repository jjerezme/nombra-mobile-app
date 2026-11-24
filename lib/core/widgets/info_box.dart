import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// A small tinted box with a label and a value: the "it will be saved as / in" preview. The value is monospace; when it
/// is a placeholder (nothing to show yet) it is drawn as plain muted text. A long value continues on the next line.
class InfoBox extends StatelessWidget {
  const InfoBox({required this.label, required this.value, super.key, this.isPlaceholder = false});

  final String label;
  final String value;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppLayout.controlRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Text(label, style: context.text.labelSmall?.copyWith(color: colors.onSecondaryContainer)),
          Text(
            value,
            style: isPlaceholder
                ? context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)
                : context.monoStyles.mono.copyWith(fontSize: AppFontSize.md, color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}
