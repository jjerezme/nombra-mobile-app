import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../l10n/app_localizations.dart';
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

  Future<void> _changeFolder(DestinationFolder current) async {
    final folder = await showFolderPicker(context, current);
    if (folder != null) setState(() => _chosenFolder = folder);
  }

  Future<void> _download(ResolvedTarget target) async {
    final settings = ref.read(settingsProvider);
    final url = _url.text.trim();
    if (!isHttpUrl(url)) {
      setState(() => _showUrlError = true);
      return;
    }
    final plan = DownloadPlan(
      url: url,
      folder: target.folder,
      rule: target.rule,
      prefix: settings.prefix,
      suffix: settings.suffix,
    );
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 0, 0, AppSpacing.lg),
              child: Text(l10n.appName, style: context.text.headlineSmall),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.lg,
                children: [
                  Text(l10n.homeUrlLabel, style: context.text.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
                  Row(
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                        ),
                      ),
                    ],
                  ),
                  RuleSelector(onEditRules: () => context.go('/rules')),
                  _NamePreview(
                    label: l10n.homeSavedAs,
                    fileName: isValid ? target.fileName : l10n.homePreviewEmpty,
                    isPlaceholder: !isValid,
                  ),
                  DestinationCard(
                    path: target.folder.path,
                    sourceLabel: folderSourceLabel(l10n, target.folderSource, target.rule),
                    onChange: () => _changeFolder(target.folder),
                  ),
                  FilledButton.icon(
                    onPressed: () => _download(target),
                    icon: const Icon(Icons.file_download_outlined, size: AppIconSize.md),
                    label: Text(l10n.homeDownload),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xl, AppSpacing.xs, AppSpacing.md),
              child: Text(l10n.homeRecents, style: context.text.titleMedium),
            ),
            if (downloads.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Text(
                  l10n.homeRecentsEmpty,
                  style: context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
              )
            else
              Column(
                spacing: AppSpacing.sm,
                children: [
                  for (final item in downloads)
                    DownloadTile(item: item, onRetry: () => ref.read(downloadsProvider.notifier).retry(item.id)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NamePreview extends StatelessWidget {
  const _NamePreview({required this.label, required this.fileName, required this.isPlaceholder});

  final String label;
  final String fileName;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Text(label, style: context.text.labelSmall?.copyWith(color: colors.onSecondaryContainer)),
          Text(
            fileName,
            style: isPlaceholder
                ? context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)
                : context.monoStyles.mono.copyWith(fontSize: AppFontSize.md, color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}
