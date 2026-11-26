import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/router.dart';
import '../../core/constants/tokens.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/segmented_toggle.dart';
import '../../l10n/app_localizations.dart';
import '../account/widgets/account_section.dart';
import '../download/data/downloads_notifier.dart';
import '../naming/widgets/destination_card.dart';
import '../naming/widgets/folder_picker_sheet.dart';
import '../rules/data/rules_notifier.dart';
import 'app_settings.dart';

/// Version and build number of the installed app.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// Appearance, language, download defaults and data management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppPage.padding,
          children: [
            ScreenHeader(title: l10n.settingsTitle, subtitle: l10n.settingsSubtitle),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppLayout.sectionGap,
              children: [
                const AccountSection(),
                AppSection(
                  title: l10n.settingsAppearance,
                  child: AppCard.stack(
                    children: [
                      LabeledField(
                        label: l10n.settingsTheme,
                        child: SegmentedToggle<AppThemeMode>(
                          options: [
                            ToggleOption(AppThemeMode.system, l10n.themeSystem),
                            ToggleOption(AppThemeMode.light, l10n.themeLight),
                            ToggleOption(AppThemeMode.dark, l10n.themeDark),
                          ],
                          selected: settings.themeMode,
                          onChanged: notifier.setThemeMode,
                        ),
                      ),
                      LabeledField(
                        label: l10n.settingsLanguage,
                        child: SegmentedToggle<String?>(
                          options: [
                            ToggleOption(null, l10n.languageSystem),
                            ToggleOption('es', l10n.languageEs),
                            ToggleOption('en', l10n.languageEn),
                          ],
                          selected: settings.languageCode,
                          onChanged: notifier.setLanguage,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSection(
                  title: l10n.settingsDownloads,
                  child: AppCard.stack(
                    children: [
                      ToggleRow(
                        label: l10n.settingsShowRecents,
                        description: l10n.settingsShowRecentsHint,
                        value: settings.showRecents,
                        onChanged: (value) => notifier.setShowRecents(isShown: value),
                      ),
                      LabeledField(
                        label: l10n.settingsDefaultFolder,
                        hint: l10n.settingsDefaultFolderHint,
                        child: DestinationCard(
                          path: settings.lastFolder.path,
                          onChange: () async {
                            final folder = await showFolderPicker(context, settings.lastFolder);
                            if (folder != null) notifier.setLastFolder(folder);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                AppSection(
                  title: l10n.settingsData,
                  child: AppCard.stack(
                    children: [
                      ActionRow(
                        icon: Icons.history,
                        title: l10n.settingsForgetRemembered,
                        hint: l10n.settingsForgetRememberedHint,
                        onTap: () => _confirm(
                          context,
                          title: l10n.settingsConfirmForgetTitle,
                          message: l10n.settingsConfirmForgetBody,
                          confirmLabel: l10n.accept,
                          onConfirmed: notifier.forgetRememberedRules,
                        ),
                      ),
                      ActionRow(
                        icon: Icons.delete_sweep_outlined,
                        title: l10n.settingsClearHistory,
                        hint: l10n.settingsClearHistoryHint,
                        isDestructive: true,
                        onTap: () => _confirm(
                          context,
                          title: l10n.settingsConfirmHistoryTitle,
                          message: l10n.settingsConfirmHistoryBody,
                          confirmLabel: l10n.delete,
                          onConfirmed: ref.read(downloadsProvider.notifier).clearFinished,
                        ),
                      ),
                      ActionRow(
                        icon: Icons.tune,
                        title: l10n.settingsClearRules,
                        hint: l10n.settingsClearRulesHint,
                        isDestructive: true,
                        onTap: () => _confirm(
                          context,
                          title: l10n.settingsConfirmRulesTitle,
                          message: l10n.settingsConfirmRulesBody(ref.read(rulesProvider).length),
                          confirmLabel: l10n.delete,
                          onConfirmed: () {
                            ref.read(rulesProvider.notifier).clear();
                            notifier.forgetRememberedRules();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                AppSection(
                  title: l10n.settingsLegal,
                  child: AppCard.stack(
                    children: [
                      ActionRow(
                        icon: Icons.description_outlined,
                        title: l10n.legalTerms,
                        onTap: () => context.push(AppRoutes.terms),
                      ),
                      ActionRow(
                        icon: Icons.privacy_tip_outlined,
                        title: l10n.legalPrivacy,
                        onTap: () => context.push(AppRoutes.privacy),
                      ),
                    ],
                  ),
                ),
                // Development flavor only: production has neither the row nor the route.
                if (!ref.watch(appEnvironmentProvider).isProduction)
                  AppCard.stack(
                    children: [
                      ActionRow(
                        icon: Icons.code,
                        title: l10n.settingsDeveloper,
                        onTap: () => context.push(AppRoutes.developer),
                      ),
                    ],
                  ),
                _About(info: ref.watch(packageInfoProvider).asData?.value),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirmed,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final done = AppLocalizations.of(context).settingsDone;
    final isConfirmed = await showConfirmDialog(context, title: title, message: message, confirmLabel: confirmLabel);
    if (!isConfirmed) return;
    onConfirmed();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(done)));
  }
}

class _About extends StatelessWidget {
  const _About({required this.info});

  final PackageInfo? info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final packageInfo = info;
    return Column(
      spacing: AppSpacing.xs,
      children: [
        const AppLogo(size: AppSize.thumb),
        Text(l10n.appName, style: context.text.titleMedium),
        if (packageInfo != null)
          Text(
            l10n.settingsVersion(packageInfo.version, packageInfo.buildNumber),
            style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
      ],
    );
  }
}
