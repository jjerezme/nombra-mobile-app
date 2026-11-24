import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/info_box.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';
import '../naming/widgets/destination_card.dart';
import '../naming/widgets/folder_picker_sheet.dart';
import '../naming/widgets/rule_selector.dart';
import '../rules/data/rules_notifier.dart';
import '../rules/domain/filename_builder.dart';
import '../rules/domain/name_resolver.dart';
import '../rules/domain/storage_root.dart';
import '../settings/app_settings.dart';
import 'data/downloads_notifier.dart';
import 'domain/download_models.dart';
import 'widgets/download_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _url = TextEditingController();
  DestinationFolder? _chosenFolder;
  bool _showUrlError = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() {
      _url.text = firstUrlIn(text) ?? text;
      _showUrlError = false;
    });
  }

  Future<void> _confirmClear() async {
    final l10n = AppLocalizations.of(context);
    final isConfirmed = await showConfirmDialog(
      context,
      title: l10n.settingsConfirmHistoryTitle,
      message: l10n.settingsConfirmHistoryBody,
      confirmLabel: l10n.delete,
    );
    if (isConfirmed && mounted) ref.read(downloadsProvider.notifier).clearFinished();
  }

  Future<void> _changeFolder(DestinationFolder current) async {
    final folder = await showFolderPicker(context, current);
    if (folder != null) setState(() => _chosenFolder = folder);
  }

  Future<void> _download(ResolvedTarget target) async {
    final settings = ref.read(settingsProvider);
    final url = _url.text.trim();
    final isQuickInvalid = settings.mode == NamingMode.quick && !patternHasContent(settings.quickTokens);
    if (isQuickInvalid) return;
    if (!isHttpUrl(url)) {
      setState(() => _showUrlError = true);
      return;
    }
    final plan = settings.mode == NamingMode.quick
        ? DownloadPlan.quick(settings: settings, folder: target.folder, url: url)
        : DownloadPlan(url: url, folder: target.folder, rule: target.rule);
    ref.read(settingsProvider.notifier).setLastFolder(target.folder);
    setState(() {
      _url.clear();
      _chosenFolder = null;
      _showUrlError = false;
    });
    await ref.read(downloadsProvider.notifier).start(plan, displayName: target.fileName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final settings = ref.watch(settingsProvider);
    final rules = ref.watch(rulesProvider);
    final downloads = ref.watch(downloadsProvider);
    // With "show recent files" off only the downloads still in progress are listed.
    final recents = settings.showRecents ? downloads : downloads.where((item) => item.isActive).toList();
    final hasHistory = downloads.any((item) => !item.isActive);
    final url = _url.text.trim();
    final isValid = isHttpUrl(url);
    final fromUrl = isValid ? sourceFromUrl(url) : null;
    final source = SourceFile(
      name: (fromUrl == null || fromUrl.name.isEmpty) ? fallbackBaseName : fromUrl.name,
      domain: fromUrl?.domain ?? '',
    );
    final target = resolveTarget(
      settings: settings,
      rules: rules,
      source: source,
      now: DateTime.now(),
      chosenFolder: _chosenFolder,
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppPage.padding,
          children: [
            ScreenHeader(title: l10n.appName, trailing: const AppLogo()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppLayout.sectionGap,
              children: [
                AppCard.stack(
                  children: [
                    LabeledField(
                      label: l10n.homeUrlLabel,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpacing.sm,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _url,
                              keyboardType: TextInputType.url,
                              onChanged: (_) => setState(() => _showUrlError = false),
                              style: context.monoStyles.mono,
                              decoration: InputDecoration(
                                errorText: _showUrlError ? l10n.homeUrlInvalid : null,
                                constraints: const BoxConstraints(minHeight: AppSize.control),
                              ),
                            ),
                          ),
                          IconButton.outlined(
                            onPressed: _paste,
                            tooltip: l10n.homePasteTooltip,
                            icon: const Icon(Icons.content_paste, size: AppIconSize.base),
                            constraints: const BoxConstraints.tightFor(width: AppSize.control, height: AppSize.control),
                            style: IconButton.styleFrom(
                              side: BorderSide(color: colors.outlineVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppLayout.controlRadius),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    RuleSelector(onAddRule: () => context.push(AppRoutes.newRule)),
                    InfoBox(
                      label: l10n.homeSavedAs,
                      value: isValid ? target.fileName : l10n.homePreviewEmpty,
                      isPlaceholder: !isValid,
                    ),
                    DestinationCard(
                      path: target.folder.path,
                      tag: folderSourceLabel(l10n, target.folderSource),
                      onChange: () => _changeFolder(target.folder),
                    ),
                    FilledButton(onPressed: () => _download(target), child: Text(l10n.homeDownload)),
                  ],
                ),
                if (recents.isNotEmpty || settings.showRecents)
                  AppSection(
                    title: l10n.homeRecents,
                    action: hasHistory && settings.showRecents
                        ? TextButton(onPressed: _confirmClear, child: Text(l10n.homeClearRecents))
                        : null,
                    child: recents.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            child: Text(
                              l10n.homeRecentsEmpty,
                              style: context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          )
                        : Column(
                            spacing: AppLayout.itemGap,
                            children: [
                              for (final item in recents)
                                DownloadTile(
                                  item: item,
                                  onRetry: () => ref.read(downloadsProvider.notifier).retry(item.id),
                                ),
                            ],
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
