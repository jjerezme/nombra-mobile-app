import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../download/data/downloads_notifier.dart';
import '../download/domain/download_models.dart';
import '../download/widgets/download_tile.dart';
import '../../l10n/app_localizations.dart';
import '../naming/widgets/destination_card.dart';
import '../naming/widgets/folder_picker_sheet.dart';
import '../naming/widgets/rule_selector.dart';
import '../rules/data/rules_notifier.dart';
import '../rules/domain/filename_builder.dart';
import '../rules/domain/name_resolver.dart';
import '../rules/domain/storage_root.dart';
import '../settings/app_settings.dart';
import 'data/share_channel.dart';
import 'domain/share_payload.dart';
import 'widgets/share_header.dart';
import 'widgets/share_name_field.dart';

/// "Save with Nombra": a bottom sheet over the app that shared a file or a link.
class ShareSheetScreen extends ConsumerStatefulWidget {
  const ShareSheetScreen({super.key});

  @override
  ConsumerState<ShareSheetScreen> createState() => _ShareSheetScreenState();
}

class _ShareSheetScreenState extends ConsumerState<ShareSheetScreen> {
  String? _manualBase;
  DestinationFolder? _chosenFolder;
  bool _remember = true;
  List<String>? _savedIds;

  void _close() => unawaited(ref.read(shareChannelProvider).close());

  Future<void> _changeFolder(DestinationFolder current) async {
    final folder = await showFolderPicker(context, current);
    if (folder != null) setState(() => _chosenFolder = folder);
  }

  Future<void> _save(List<ShareItem> items, ResolvedTarget target) async {
    final settings = ref.read(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final downloads = ref.read(downloadsProvider.notifier);
    final first = items.first;
    settingsNotifier.setLastFolder(target.folder);
    final rule = target.rule;
    if (_remember && rule != null) settingsNotifier.rememberDefaultFor(first.kind, rule.id);

    String? fixedName;
    final manual = _manualBase;
    if (manual != null && manual.trim().isNotEmpty && items.length == 1) {
      final extension = first.source.extension;
      fixedName = extension.isEmpty ? manual.trim() : '${manual.trim()}.$extension';
    }
    DownloadPlan planFor(ShareItem item) => DownloadPlan(
      url: item.url,
      folder: target.folder,
      rule: rule,
      prefix: settings.prefix,
      suffix: settings.suffix,
      fixedFileName: fixedName,
    );

    setState(() => _savedIds = const []);
    final ids = <String>[];
    for (final item in items) {
      final path = item.path;
      ids.add(
        path == null
            ? await downloads.start(planFor(item), displayName: fixedName ?? target.fileName)
            : await downloads.saveLocalFile(planFor(item), path: path, fileName: item.name),
      );
    }
    if (mounted) setState(() => _savedIds = ids);
  }

  /// Closes the sheet shortly after everything has been saved.
  void _closeWhenDone(List<DownloadItem> downloads) {
    final ids = _savedIds;
    if (ids == null || ids.isEmpty) return;
    final tracked = downloads.where((item) => ids.contains(item.id));
    if (tracked.isNotEmpty && tracked.every((item) => item.status == DownloadStatus.done)) {
      Timer(const Duration(milliseconds: 900), _close);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    ref.listen(downloadsProvider, (previous, next) => _closeWhenDone(next));
    final payload = ref.watch(sharePayloadProvider);
    final items = payload.maybeWhen(data: itemsOf, orElse: () => const <ShareItem>[]);
    return Scaffold(
      backgroundColor: Colors.transparent, // style-ok
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: ColoredBox(color: colors.scrim.withValues(alpha: 0.45)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
              child: Material(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
                    child: payload.isLoading
                        ? const SizedBox(
                            height: AppSize.button,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : items.isEmpty
                        ? _Message(text: l10n.shareNothing, onClose: _close)
                        : _Content(
                            items: items,
                            chosenFolder: _chosenFolder,
                            manualBase: _manualBase,
                            remember: _remember,
                            savedIds: _savedIds,
                            onManualChanged: (value) => setState(() => _manualBase = value),
                            onRuleSelected: (_) => setState(() => _manualBase = null),
                            onRememberChanged: (value) => setState(() => _remember = value),
                            onChangeFolder: _changeFolder,
                            onSave: _save,
                            onClose: _close,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.lg,
      children: [
        Text(text, style: context.text.bodyLarge),
        FilledButton(onPressed: onClose, child: Text(AppLocalizations.of(context).shareClose)),
      ],
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.items,
    required this.chosenFolder,
    required this.manualBase,
    required this.remember,
    required this.savedIds,
    required this.onManualChanged,
    required this.onRuleSelected,
    required this.onRememberChanged,
    required this.onChangeFolder,
    required this.onSave,
    required this.onClose,
  });

  final List<ShareItem> items;
  final DestinationFolder? chosenFolder;
  final String? manualBase;
  final bool remember;
  final List<String>? savedIds;
  final ValueChanged<String> onManualChanged;
  final ValueChanged<String> onRuleSelected;
  final ValueChanged<bool> onRememberChanged;
  final ValueChanged<DestinationFolder> onChangeFolder;
  final void Function(List<ShareItem> items, ResolvedTarget target) onSave;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final settings = ref.watch(settingsProvider);
    final rules = ref.watch(rulesProvider);
    final first = items.first;
    final target = resolveTarget(
      settings: settings,
      rules: rules,
      source: first.source,
      now: DateTime.now(),
      chosenFolder: chosenFolder,
      selected: settings.mode == NamingMode.saved ? selectRule(settings, rules, kind: first.kind) : null,
    );
    final (autoBase, extension) = splitFileName(target.fileName);
    final saved = savedIds;
    final tracked = saved == null
        ? const <DownloadItem>[]
        : ref.watch(downloadsProvider).where((item) => saved.contains(item.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.roomy,
      children: [
        Center(
          child: Container(
            width: AppSize.handleWidth,
            height: AppSize.handleHeight,
            decoration: BoxDecoration(color: colors.outline, borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        ),
        ShareHeader(items: items),
        if (saved != null) ...[
          for (final item in tracked)
            DownloadTile(item: item, onRetry: () => ref.read(downloadsProvider.notifier).retry(item.id)),
          if (tracked.any(
            (item) =>
                item.plan.url != null && item.status != DownloadStatus.done && item.status != DownloadStatus.failed,
          ))
            Text(l10n.shareLeaveHint, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          FilledButton(onPressed: onClose, child: Text(l10n.shareClose)),
        ] else ...[
          RuleSelector(selectedRuleId: target.rule?.id, onRuleSelected: onRuleSelected),
          if (items.length == 1)
            ShareNameField(
              baseName: manualBase ?? autoBase,
              extension: extension,
              isManual: manualBase != null,
              onChanged: onManualChanged,
            ),
          DestinationCard(
            path: target.folder.path,
            sourceLabel: folderSourceLabel(l10n, target.folderSource, target.rule),
            onChange: () => onChangeFolder(target.folder),
          ),
          if (settings.mode == NamingMode.saved)
            CheckboxListTile(
              value: remember,
              onChanged: (value) => onRememberChanged(value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(l10n.shareRememberDefault(kindLabel(l10n, first.kind)), style: context.text.bodyMedium),
            ),
          Row(
            spacing: AppSpacing.snug,
            children: [
              Expanded(
                child: OutlinedButton(onPressed: onClose, child: Text(l10n.cancel)),
              ),
              Expanded(
                child: FilledButton(onPressed: () => onSave(items, target), child: Text(l10n.save)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
