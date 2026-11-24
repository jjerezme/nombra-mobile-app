import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation.dart';
import '../download/data/downloads_notifier.dart';
import '../download/domain/download_models.dart';
import '../download/widgets/download_tile.dart';
import '../../l10n/app_localizations.dart';
import '../naming/widgets/destination_card.dart';
import '../naming/widgets/folder_picker_sheet.dart';
import '../naming/widgets/rule_selector.dart';
import '../rules/data/rules_notifier.dart';
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
  DestinationFolder? _chosenFolder;
  bool _remember = true;
  List<String>? _savedIds;
  bool _isClosing = false;

  void _close() {
    if (_isClosing) return;
    _isClosing = true;
    unawaited(ref.read(shareChannelProvider).close());
  }

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

    DownloadPlan planFor(ShareItem item) => settings.mode == NamingMode.quick
        ? DownloadPlan.quick(settings: settings, folder: target.folder, url: item.url)
        : DownloadPlan(url: item.url, folder: target.folder, rule: rule);

    // The permission dialog needs this screen in front, so it is asked before the sheet goes to the background.
    await downloads.prepareNotifications();
    setState(() => _savedIds = const []);
    final saves = [
      for (final item in items)
        item.path == null
            ? downloads.start(planFor(item), displayName: target.fileName)
            : downloads.saveLocalFile(planFor(item), path: item.path!, fileName: item.name),
    ];
    // Saving goes on in the background, with its notification: the sheet does not stay on screen.
    unawaited(ref.read(shareChannelProvider).minimize());
    final ids = await Future.wait(saves);
    if (!mounted) return;
    setState(() => _savedIds = ids);
    _closeWhenDone(ref.read(downloadsProvider));
  }

  /// Finishes the (hidden) activity once every save is done or failed.
  void _closeWhenDone(List<DownloadItem> downloads) {
    final ids = _savedIds;
    if (ids == null || ids.isEmpty) return;
    final tracked = downloads.where((item) => ids.contains(item.id));
    final isFinished = tracked.every(
      (item) => item.status == DownloadStatus.done || item.status == DownloadStatus.failed,
    );
    if (tracked.isEmpty || isFinished) _close();
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.sheetGutter,
                      AppSpacing.md,
                      AppLayout.sheetGutter,
                      AppSpacing.xxl,
                    ),
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
                            remember: _remember,
                            savedIds: _savedIds,
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
    required this.remember,
    required this.savedIds,
    required this.onRememberChanged,
    required this.onChangeFolder,
    required this.onSave,
    required this.onClose,
  });

  final List<ShareItem> items;
  final DestinationFolder? chosenFolder;
  final bool remember;
  final List<String>? savedIds;
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
    final isNameValid = settings.mode != NamingMode.quick || patternHasContent(settings.quickTokens);
    final saved = savedIds;
    final tracked = saved == null
        ? const <DownloadItem>[]
        : ref.watch(downloadsProvider).where((item) => saved.contains(item.id)).toList();

    final body = <Widget>[
      ShareHeader(items: items),
      if (saved != null) ...[
        for (final item in tracked)
          DownloadTile(item: item, onRetry: () => ref.read(downloadsProvider.notifier).retry(item.id)),
        if (tracked.any(
          (item) => item.plan.url != null && item.status != DownloadStatus.done && item.status != DownloadStatus.failed,
        ))
          Text(l10n.shareLeaveHint, style: context.text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ] else ...[
        RuleSelector(selectedRuleId: target.rule?.id),
        if (items.length == 1) ShareNameField(fileName: target.fileName),
        DestinationCard(
          path: target.folder.path,
          tag: folderSourceLabel(l10n, target.folderSource),
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
      ],
    ];
    // The buttons are pinned at the bottom: only the content above them scrolls.
    final actions = saved != null
        ? FilledButton(onPressed: onClose, child: Text(l10n.shareClose))
        : Row(
            spacing: AppLayout.buttonGap,
            children: [
              Expanded(
                child: OutlinedButton(onPressed: onClose, child: Text(l10n.cancel)),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: isNameValid ? () => onSave(items, target) : null,
                  child: Text(l10n.save),
                ),
              ),
            ],
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppLayout.sectionGap,
      children: [
        Center(
          child: Container(
            width: AppSize.handleWidth,
            height: AppSize.handleHeight,
            decoration: BoxDecoration(color: colors.outline, borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: AppLayout.sectionGap, children: body),
          ),
        ),
        actions,
      ],
    );
  }
}
