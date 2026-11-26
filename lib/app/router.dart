import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/conflict_prompt.dart';
import '../core/providers.dart';
import '../features/developer/developer_screen.dart';
import '../features/download/home_screen.dart';
import '../features/legal/domain/legal_models.dart';
import '../features/legal/legal_screen.dart';
import '../features/rules/rule_editor_screen.dart';
import '../features/rules/rules_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String rules = '/rules';
  static const String settings = '/settings';
  static const String newRule = '/rules/new';
  static const String editRule = '/rules/:id';
  static const String terms = '/legal/terms';
  static const String privacy = '/legal/privacy';

  /// Developer mode: the route does not exist in production.
  static const String developer = '/developer';

  /// Location of the editor for the rule with [id].
  static String rule(String id) => '/rules/${Uri.encodeComponent(id)}';
}

final routerProvider = Provider<GoRouter>((ref) {
  final isProduction = ref.watch(appEnvironmentProvider).isProduction;
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // An unknown location (stale link, removed route) goes home instead of showing an error page.
    onException: (context, state, router) => router.go(AppRoutes.home),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.rules, builder: (context, state) => const RulesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen())],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.newRule,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RuleEditorScreen(),
      ),
      GoRoute(
        path: AppRoutes.editRule,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => RuleEditorScreen(ruleId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.terms,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LegalScreen(kind: LegalKind.terms),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LegalScreen(kind: LegalKind.privacy),
      ),
      if (!isProduction)
        GoRoute(
          path: AppRoutes.developer,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const DeveloperScreen(),
        ),
    ],
  );
});
