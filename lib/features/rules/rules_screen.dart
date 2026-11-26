import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/router.dart';
import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import 'data/rules_notifier.dart';
import 'widgets/rule_card.dart';

class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rules = ref.watch(rulesProvider);
    final header = ScreenHeader(title: l10n.rulesTitle, subtitle: l10n.rulesSubtitle);
    // Room under the last card for the floating button.
    final padding = AppPage.padding.copyWith(bottom: AppSize.fab + AppSpacing.xxxl);
    return Scaffold(
      body: SafeArea(
        child: rules.isEmpty
            ? ListView(
                padding: padding,
                children: [
                  header,
                  _EmptyRules(title: l10n.rulesEmptyTitle, body: l10n.rulesEmptyBody),
                ],
              )
            : ListView(
                padding: padding,
                children: [
                  header,
                  Column(
                    spacing: AppLayout.itemGap,
                    children: [
                      for (final rule in rules)
                        RuleCard(
                          key: ValueKey(rule.id),
                          rule: rule,
                          onTap: () => context.push(AppRoutes.rule(rule.id)),
                        ),
                    ],
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newRule),
        icon: const Icon(Icons.add),
        label: Text(l10n.newRule),
      ),
    );
  }
}

class _EmptyRules extends StatelessWidget {
  const _EmptyRules({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        spacing: AppSpacing.sm,
        children: [
          Icon(Icons.tune, size: AppIconSize.lg, color: context.colors.onSurfaceVariant),
          Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
          Text(
            body,
            style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
