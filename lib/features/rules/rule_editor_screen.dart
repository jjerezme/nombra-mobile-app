import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dialogs.dart';
import '../../l10n/app_localizations.dart';
import '../naming/widgets/folder_picker_sheet.dart';
import 'data/rules_notifier.dart';
import 'domain/filename_builder.dart';
import 'domain/rename_rule.dart';
import 'domain/sample_file.dart';
import 'domain/storage_root.dart';
import 'widgets/folder_section.dart';
import 'widgets/pattern_section.dart';
import 'widgets/transform_section.dart';

/// Creates a rule, or edits the rule with [ruleId].
class RuleEditorScreen extends ConsumerStatefulWidget {
  const RuleEditorScreen({super.key, this.ruleId});

  final String? ruleId;

  @override
  ConsumerState<RuleEditorScreen> createState() => _RuleEditorScreenState();
}

class _RuleEditorScreenState extends ConsumerState<RuleEditorScreen> {
  late RenameRule _draft;
  late final TextEditingController _name;
  late final bool _isNew;
  bool _showNameError = false;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(rulesProvider.notifier);
    final existing = widget.ruleId == null ? null : notifier.byId(widget.ruleId!);
    _isNew = existing == null;
    _draft =
        existing ??
        RenameRule(id: notifier.newId(), name: '', tokens: const [PatternTokens.date, '_', PatternTokens.name]);
    _name = TextEditingController(text: _draft.name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _update(RenameRule next) => setState(() => _draft = next);

  Future<void> _pickFolder() async {
    final folder = await showFolderPicker(context, _draft.folder ?? DestinationFolder(StorageRoot.download, 'Nombra'));
    if (folder != null) _update(_draft.copyWith(folder: folder));
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    ref.read(rulesProvider.notifier).upsert(_draft.copyWith(name: name));
    context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final isConfirmed = await showConfirmDialog(
      context,
      title: l10n.editorDeleteTitle,
      message: l10n.editorDeleteBody(_draft.name),
      confirmLabel: l10n.delete,
    );
    if (!isConfirmed || !mounted) return;
    ref.read(rulesProvider.notifier).remove(_draft.id);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final example = buildFileName(_draft, sampleFile, now: DateTime.now());
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.xxl),
          children: [
            Row(
              children: [
                IconButton(onPressed: context.pop, tooltip: l10n.editorBackTooltip, icon: const Icon(Icons.arrow_back)),
                Expanded(
                  child: Text(_isNew ? l10n.editorTitleNew : l10n.editorTitleEdit, style: context.text.titleLarge),
                ),
                TextButton(onPressed: _save, child: Text(l10n.save)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.cozy,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.tight,
                  children: [
                    Text(
                      l10n.editorRuleName,
                      style: context.text.labelMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    TextField(
                      controller: _name,
                      onChanged: (_) => setState(() => _showNameError = false),
                      decoration: InputDecoration(
                        errorText: _showNameError ? l10n.editorNameRequired : null,
                        constraints: const BoxConstraints(minHeight: AppSize.control),
                      ),
                    ),
                  ],
                ),
                PatternSection(
                  tokens: _draft.tokens,
                  onChanged: (tokens) => _update(_draft.copyWith(tokens: tokens)),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.inverseSurface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.tight,
                    children: [
                      Text(
                        l10n.editorExample(sampleFile.name),
                        style: context.text.bodySmall?.copyWith(color: colors.onInverseSurface.withValues(alpha: 0.7)),
                      ),
                      Text(example, style: context.monoStyles.monoLarge.copyWith(color: colors.inversePrimary)),
                    ],
                  ),
                ),
                TransformSection(rule: _draft, onChanged: _update),
                FolderSection(
                  folder: _draft.folder,
                  conflict: _draft.conflict,
                  onPickFolder: _pickFolder,
                  onClearFolder: () => _update(_draft.copyWith(clearFolder: true)),
                  onConflictChanged: (policy) => _update(_draft.copyWith(conflict: policy)),
                ),
                if (!_isNew && !_draft.isDefault)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: _delete,
                      style: TextButton.styleFrom(foregroundColor: colors.error),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.editorDeleteRule),
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
