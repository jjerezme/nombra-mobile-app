import '../../settings/app_settings.dart';
import 'filename_builder.dart';
import 'rename_rule.dart';
import 'storage_root.dart';

enum FolderSource { rule, lastUsed, chosen }

/// Where and under which name a file will be saved, given the current choices.
class ResolvedTarget {
  const ResolvedTarget({required this.fileName, required this.folder, required this.folderSource, this.rule});

  final String fileName;
  final DestinationFolder folder;
  final FolderSource folderSource;

  /// Null in quick mode.
  final RenameRule? rule;
}

/// The rule to use: the last one used, then the default rule, then the first.
RenameRule? selectRule(AppSettings settings, List<RenameRule> rules) {
  if (rules.isEmpty) return null;
  RenameRule? byId(String? id) => rules.where((rule) => rule.id == id).firstOrNull;
  return byId(settings.lastRuleId) ?? rules.where((rule) => rule.isDefault).firstOrNull ?? rules.first;
}

ResolvedTarget resolveTarget({
  required AppSettings settings,
  required List<RenameRule> rules,
  required SourceFile source,
  required DateTime now,
  RenameRule? selected,
  DestinationFolder? chosenFolder,
}) {
  if (settings.mode == NamingMode.quick) {
    return ResolvedTarget(
      fileName: buildQuickFileName(settings.quickTokens, source, now: now, counter: settings.nextQuickNumber),
      folder: chosenFolder ?? settings.lastFolder,
      folderSource: chosenFolder == null ? FolderSource.lastUsed : FolderSource.chosen,
    );
  }
  // No rule: the file keeps its original name.
  final rule = settings.mode == NamingMode.none ? null : selected ?? selectRule(settings, rules);
  if (rule == null) {
    return ResolvedTarget(
      fileName: source.name,
      folder: chosenFolder ?? settings.lastFolder,
      folderSource: chosenFolder == null ? FolderSource.lastUsed : FolderSource.chosen,
    );
  }
  final ruleFolder = rule.folder;
  return ResolvedTarget(
    fileName: buildFileName(rule, source, now: now),
    folder: chosenFolder ?? ruleFolder ?? settings.lastFolder,
    folderSource: chosenFolder != null
        ? FolderSource.chosen
        : ruleFolder != null
        ? FolderSource.rule
        : FolderSource.lastUsed,
    rule: rule,
  );
}
