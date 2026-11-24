import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/segmented_toggle.dart';
import '../../l10n/app_localizations.dart';
import '../download/data/downloads_notifier.dart';
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
                      LabeledField(
                        label: l10n.settingsNamingMode,
                        hint: l10n.settingsNamingModeHint,
                        child: SegmentedToggle<NamingMode>(
                          options: [
                            ToggleOption(NamingMode.saved, l10n.modeSaved),
                            ToggleOption(NamingMode.quick, l10n.modeQuick),
                          ],
                          selected: settings.mode,
                          onChanged: notifier.setMode,
                        ),
                      ),
                      ToggleRow(
                        label: l10n.settingsShowRecents,
                        description: l10n.settingsShowRecentsHint,
                        value: settings.showRecents,
                        onChanged: (value) => notifier.setShowRecents(isShown: value),
                      ),
                      LabeledField(
                        label: l10n.settingsDefaultFolder,
                        hint: l10n.settingsDefaultFolderHint,
                        child: _FolderRow(
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

class _FolderRow extends StatelessWidget {
  const _FolderRow({required this.path, required this.onChange});

  final String path;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      spacing: AppSpacing.md,
      children: [
        Icon(Icons.folder_outlined, size: AppIconSize.md, color: context.colors.primary),
        Expanded(
          child: Text(path, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.monoStyles.mono),
        ),
        TextButton(onPressed: onChange, child: Text(l10n.change)),
      ],
    );
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
