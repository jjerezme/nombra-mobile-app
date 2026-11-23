import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'data/rules_notifier.dart';
import 'widgets/rule_card.dart';

class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rules = ref.watch(rulesProvider);
    final notifier = ref.read(rulesProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  Text(l10n.rulesTitle, style: context.text.headlineSmall),
                  Text(
                    l10n.rulesSubtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontSize: AppFontSize.caption,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSize.fab + AppSpacing.xxxl,
                ),
                itemCount: rules.length,
                onReorderItem: notifier.reorder,
                proxyDecorator: (child, index, animation) => Material(type: MaterialType.transparency, child: child),
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return Padding(
                    key: ValueKey(rule.id),
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: RuleCard(
                      rule: rule,
                      index: index,
                      onTap: () => context.push('/rules/${rule.id}'),
                      onToggle: (isEnabled) => notifier.setEnabled(rule.id, isEnabled: isEnabled),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/rules/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newRule),
      ),
    );
  }
}
