import 'package:material_ui/material_ui.dart';

import '../constants/tokens.dart';
import '../theme/app_theme.dart';

/// A small tinted box for information. With a label and a value it is the "it will be saved as / in" preview (the
/// value is monospace and a long one continues on the next line); [InfoBox.note] holds a plain sentence instead.
class InfoBox extends StatelessWidget {
  const InfoBox({required String this.label, required String this.value, super.key}) : note = null;

  /// A tinted box with just a sentence, for a short explanation.
  const InfoBox.note(String this.note, {super.key}) : label = null, value = null;

  final String? label;
  final String? value;
  final String? note;

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
      child: note != null
          ? Text(note!, style: context.text.bodyMedium?.copyWith(color: colors.onSecondaryContainer))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(label!, style: context.text.labelSmall?.copyWith(color: colors.onSecondaryContainer)),
                Text(
                  value!,
                  style: context.monoStyles.mono.copyWith(fontSize: AppFontSize.md, color: colors.onSurface),
                ),
              ],
            ),
    );
  }
}
