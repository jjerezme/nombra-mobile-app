import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(l10n.homeSubtitle),
            ],
          ),
        ),
      ),
    );
  }
}
