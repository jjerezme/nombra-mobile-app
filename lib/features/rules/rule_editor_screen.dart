import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/tokens.dart';
import '../../app/router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../naming/widgets/folder_picker_sheet.dart';
import 'data/rules_notifier.dart';
import 'domain/filename_builder.dart';
import 'domain/rename_rule.dart';
import 'domain/sample_file.dart';
import '../settings/app_settings.dart';
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
  late final String _baseline;

  /// The id points to a rule that no longer exists (deleted, or the stored list was reset).
  bool _isMissing = false;
  InputError? _nameError;
  bool _showPatternError = false;

  /// Set once the rule is saved, deleted or the changes are discarded, so leaving is not blocked.
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(rulesProvider.notifier);
    final existing = widget.ruleId == null ? null : notifier.byId(widget.ruleId!);
    _isMissing = widget.ruleId != null && existing == null;
    _isNew = existing == null;
    _draft =
        existing ??
        RenameRule(
          id: notifier.newId(),
          name: '',
          tokens: const [PatternTokens.date, '_', PatternTokens.name],
          // A new rule starts with the default folder of Settings; it can be changed or removed.
          folder: ref.read(settingsProvider).lastFolder,
        );
    _name = TextEditingController(text: _draft.name);
    _baseline = _snapshot();
  }

  String _snapshot() => jsonEncode(_draft.copyWith(name: _name.text.trim()).toJson());

  bool get _isDirty => _snapshot() != _baseline;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _update(RenameRule next) => setState(() => _draft = next);

  Future<void> _pickFolder() async {
    final folder = await showFolderPicker(context, _draft.folder ?? ref.read(settingsProvider).lastFolder);
    if (folder != null) _update(_draft.copyWith(folder: folder));
  }

  /// Leaves the editor even when there is nothing to pop (e.g. opened from a link).
  void _leave() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.rules);
      }
    });
  }

  void _save() {
    final rules = ref.read(rulesProvider);
    final nameError = validateRuleName(
      _name.text,
      otherNames: [
        for (final rule in rules)
          if (rule.id != _draft.id) rule.name,
      ],
    );
    final hasPattern = patternHasContent(_draft.tokens);
    if (nameError != null || !hasPattern) {
      setState(() {
        _nameError = nameError;
        _showPatternError = !hasPattern;
      });
      return;
    }
    ref.read(rulesProvider.notifier).upsert(_draft.copyWith(name: _name.text.trim()));
    _leave();
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final isDiscarded = await showConfirmDialog(
      context,
      title: l10n.editorDiscardTitle,
      message: l10n.editorDiscardBody,
      confirmLabel: l10n.discard,
    );
    if (isDiscarded && mounted) _leave();
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
    _leave();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    if (_isMissing) return _MissingRule(onBack: _leave);
    final example = buildFileName(_draft, sampleFile, now: DateTime.now());
    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppPage.paddingWithBack,
                  children: [
                    ScreenHeader(
                      title: _isNew ? l10n.editorTitleNew : l10n.editorTitleEdit,
                      onBack: () => Navigator.of(context).maybePop(),
                      backTooltip: l10n.editorBackTooltip,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppLayout.sectionGap,
                      children: [
                        LabeledField(
                          label: l10n.editorRuleName,
                          child: TextField(
                            controller: _name,
                            maxLength: maxRuleNameLength,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => setState(() => _nameError = null),
                            decoration: InputDecoration(
                              counterText: '',
                              errorText: _nameError?.message(l10n, max: maxRuleNameLength),
                              constraints: const BoxConstraints(minHeight: AppSize.control),
                            ),
                          ),
                        ),
                        AppSection(
                          title: l10n.editorPattern,
                          child: AppCard(
                            child: PatternSection(
                              tokens: _draft.tokens,
                              errorText: _showPatternError ? l10n.errPatternEmpty : null,
                              onChanged: (tokens) {
                                _showPatternError = false;
                                _update(_draft.copyWith(tokens: tokens));
                              },
                            ),
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
                          TextButton.icon(
                            onPressed: _delete,
                            style: TextButton.styleFrom(foregroundColor: colors.error),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(l10n.editorDeleteRule),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Pinned at the bottom, always in view: the example of the name and the main action.
              _ExampleBar(sampleName: sampleFile.name, example: example),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppLayout.gutter, 0, AppLayout.gutter, AppSpacing.md),
                child: FilledButton(onPressed: _save, child: Text(l10n.save)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The example of the final name, pinned below the form so it stays in view while the rule changes.
class _ExampleBar extends StatelessWidget {
  const _ExampleBar({required this.sampleName, required this.example});

  final String sampleName;
  final String example;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppLayout.gutter, AppSpacing.sm, AppLayout.gutter, AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppLayout.cardPadding),
        decoration: BoxDecoration(
          color: colors.inverseSurface,
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.tight,
          children: [
            Text(
              l10n.editorExample(sampleName),
              style: context.text.bodySmall?.copyWith(color: colors.onInverseSurface.withValues(alpha: 0.7)),
            ),
            Text(example, style: context.monoStyles.monoLarge.copyWith(color: colors.inversePrimary)),
          ],
        ),
      ),
    );
  }
}

class _MissingRule extends StatelessWidget {
  const _MissingRule({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.lg,
            children: [
              Text(l10n.ruleNotFound, style: context.text.bodyLarge),
              FilledButton(onPressed: onBack, child: Text(l10n.editorBackTooltip)),
            ],
          ),
        ),
      ),
    );
  }
}
