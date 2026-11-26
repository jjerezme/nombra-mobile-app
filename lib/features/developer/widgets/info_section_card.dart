import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/dev_info.dart';

/// A collapsible card with label and value rows, closed at first. The values can be selected to copy them.
class InfoSectionCard extends StatelessWidget {
  const InfoSectionCard({required this.title, required this.rows, super.key});

  final String title;
  final List<InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final muted = context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(title, style: context.text.titleSmall),
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.md,
                children: [
                  Expanded(child: Text(row.label, style: muted)),
                  Expanded(
                    flex: 2,
                    child: SelectableText(row.value, textAlign: TextAlign.end, style: context.text.bodySmall),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
