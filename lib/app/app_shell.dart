import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// Bottom navigation between Download and Rules.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Back from another tab returns to Download first; only from Download does it leave the app.
    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: _scaffold(l10n),
    );
  }

  Widget _scaffold(AppLocalizations l10n) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.file_download_outlined), label: l10n.navDownload),
          NavigationDestination(icon: const Icon(Icons.tune), label: l10n.navRules),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: l10n.navSettings),
        ],
      ),
    );
  }
}
