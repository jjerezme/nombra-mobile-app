import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/conflict_prompt.dart';
import '../features/download/home_screen.dart';
import '../features/rules/rule_editor_screen.dart';
import '../features/rules/rules_screen.dart';
import 'app_shell.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String rules = '/rules';
  static const String newRule = '/rules/new';
  static const String editRule = '/rules/:id';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
    ],
  );
});
