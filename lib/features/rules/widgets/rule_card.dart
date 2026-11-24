import 'package:material_ui/material_ui.dart';

import '../../../core/constants/tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/filename_builder.dart';
import '../domain/rename_rule.dart';
import '../domain/sample_file.dart';

/// A rule in the list: name, pattern, example, folder, and an on/off switch.
class RuleCard extends StatelessWidget {
  const RuleCard({required this.rule, required this.index, required this.onTap, required this.onToggle, super.key});

  final RenameRule rule;
  final int index;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final mono = context.monoStyles.monoSmall;
    final example = buildFileName(rule, sampleFile, now: DateTime.now());
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Semantics(
              label: l10n.ruleReorderHandle,
              child: SizedBox(
                width: AppSize.dragHandle,
                height: AppSize.control,
                child: Icon(Icons.drag_indicator, size: AppIconSize.base, color: colors.onSurfaceVariant),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  Row(
                    spacing: AppSpacing.sm,
                    children: [
                      Flexible(
                        child: Text(rule.name, style: context.text.labelLarge?.copyWith(fontSize: AppFontSize.body)),
                      ),
                      if (rule.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tight, vertical: AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.md - AppSpacing.xxs),
                          ),
                          child: Text(
                            l10n.ruleDefaultBadge,
                            style: context.text.labelSmall?.copyWith(
                              fontSize: AppFontSize.xs,
                              fontWeight: FontWeight.w600,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    rule.pattern,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono.copyWith(color: colors.onPrimaryContainer),
                  ),
                  Text(
                    '→ $example',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Row(
                    spacing: AppSpacing.tight,
                    children: [
                      Icon(Icons.folder_outlined, size: AppIconSize.sm, color: colors.primary),
                      Expanded(
                        child: Text(
                          rule.folder?.path ?? l10n.ruleNoFolder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: mono,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Semantics(
            label: l10n.ruleToggleLabel(rule.name),
            child: Switch(value: rule.isEnabled, onChanged: onToggle),
          ),
        ],
      ),
    );
  }
}
