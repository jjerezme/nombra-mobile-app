import '../../settings/app_settings.dart';
import 'file_kind.dart';
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

/// The rule to use: the default of the file's kind, then the last one used, then the default rule, then the first.
RenameRule? selectRule(AppSettings settings, List<RenameRule> rules, {FileKind? kind}) {
  final enabled = rules.where((rule) => rule.isEnabled).toList();
  if (enabled.isEmpty) return null;
  RenameRule? byId(String? id) => enabled.where((rule) => rule.id == id).firstOrNull;
  final kindDefault = kind == null ? null : byId(settings.defaultRuleByKind[kind.name]);
  return kindDefault ??
      byId(settings.lastRuleId) ??
      enabled.where((rule) => rule.isDefault).firstOrNull ??
      enabled.first;
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
      fileName: buildQuickFileName(settings.prefix, settings.suffix, source),
      folder: chosenFolder ?? settings.lastFolder,
      folderSource: chosenFolder == null ? FolderSource.lastUsed : FolderSource.chosen,
    );
  }
  final rule = selected ?? selectRule(settings, rules, kind: fileKindOf(extension: source.extension));
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
