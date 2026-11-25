import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/rules/domain/file_kind.dart';
import 'package:nombra/features/rules/domain/filename_builder.dart';
import 'package:nombra/features/rules/domain/name_resolver.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';
import 'package:nombra/features/settings/app_settings.dart';

void main() {
  final now = DateTime(2026, 11, 23);
  const source = SourceFile(name: 'a.pdf');
  final dated = RenameRule(
    id: 'dated',
    name: 'Dated',
    tokens: const [PatternTokens.date, '_', PatternTokens.name],
    folder: DestinationFolder(StorageRoot.download, 'Nombra'),
    isDefault: true,
  );
  final plain = RenameRule(id: 'plain', name: 'Plain', tokens: const [PatternTokens.name]);

  test('DestinationFolder normalizes the subfolder and prints its path', () {
    expect(DestinationFolder(StorageRoot.documents, r' /Facturas\2026/../x: ').path, '/Documents/Facturas/2026/x');
    expect(DestinationFolder(StorageRoot.music).path, '/Music');
  });

  test('RenameRule survives a JSON round trip', () {
    final rule = dated.copyWith(
      caseMode: CaseMode.upper,
      replaceSpaces: true,
      conflict: ConflictPolicy.ask,
      counter: 9,
    );
    final copy = RenameRule.fromJson(rule.toJson());
    expect(copy.toJson(), rule.toJson());
    expect(copy.folder, rule.folder);
  });

  test('fileKindOf prefers the mime type and falls back to the extension', () {
    expect(fileKindOf(mimeType: 'image/png'), FileKind.image);
    expect(fileKindOf(extension: 'MP4'), FileKind.video);
    expect(fileKindOf(extension: 'pdf'), FileKind.document);
    expect(fileKindOf(extension: 'zip'), FileKind.other);
  });

  group('selectRule', () {
    final rules = [plain, dated];

    test('uses the last used rule, then the default', () {
      expect(selectRule(AppSettings(lastRuleId: 'plain'), rules)?.id, 'plain');
      expect(selectRule(AppSettings(), rules)?.id, 'dated');
    });

    test('no rules: nothing is selected', () {
      expect(selectRule(AppSettings(), const []), isNull);
    });

    test('a rule stored as switched off by an earlier version is a normal rule', () {
      final stored = RenameRule.fromJson({...plain.toJson(), 'isEnabled': false});
      expect(selectRule(AppSettings(lastRuleId: 'plain'), [stored, dated])?.id, 'plain');
    });
  });

  group('resolveTarget', () {
    test('saved mode: rule name and rule folder', () {
      final target = resolveTarget(
        settings: AppSettings(mode: NamingMode.saved),
        rules: [dated],
        source: source,
        now: now,
      );
      expect(target.fileName, '2026-11-23_a.pdf');
      expect(target.folder.path, '/Download/Nombra');
      expect(target.folderSource, FolderSource.rule);
    });

    test('a rule without folder uses the last used folder', () {
      final settings = AppSettings(lastFolder: DestinationFolder(StorageRoot.pictures, 'Viajes'));
      final target = resolveTarget(settings: settings, rules: [plain], source: source, now: now);
      expect(target.folder.path, '/Pictures/Viajes');
      expect(target.folderSource, FolderSource.lastUsed);
    });

    test('a chosen folder wins', () {
      final chosen = DestinationFolder(StorageRoot.documents);
      final target = resolveTarget(
        settings: AppSettings(),
        rules: [dated],
        source: source,
        now: now,
        chosenFolder: chosen,
      );
      expect(target.folder, chosen);
      expect(target.folderSource, FolderSource.chosen);
    });

    test('no rule: the original name, even with rules available, in the last folder', () {
      final settings = AppSettings(mode: NamingMode.none, lastFolder: DestinationFolder(StorageRoot.movies, 'x'));
      final target = resolveTarget(settings: settings, rules: [dated], source: source, now: now);
      expect(target.fileName, 'a.pdf');
      expect(target.rule, isNull);
      expect(target.folder.path, '/Movies/x');
      expect(target.folderSource, FolderSource.lastUsed);
    });

    test('no rule ignores a rule that was passed in as selected', () {
      final target = resolveTarget(
        settings: AppSettings(mode: NamingMode.none),
        rules: [dated],
        source: source,
        now: now,
        selected: dated,
      );
      expect(target.fileName, 'a.pdf');
    });

    test('quick mode uses the quick pattern', () {
      final settings = AppSettings(mode: NamingMode.quick, quickTokens: ['x_', PatternTokens.name, '_y']);
      final target = resolveTarget(settings: settings, rules: [dated], source: source, now: now);
      expect(target.fileName, 'x_a_y.pdf');
      expect(target.rule, isNull);
    });
  });

  test('settings saved by the first quick version (prefix, suffix, sequence) become a quick pattern', () {
    final settings = AppSettings.fromJson({
      'prefix': 'p_',
      'suffix': '_s',
      'quickReplaceName': true,
      'quickSequence': true,
      'quickDigits': 3,
    });
    expect(settings.quickTokens, ['p_', '{n:3}', '_s']);
    expect(AppSettings.fromJson(const {}).quickTokens, [PatternTokens.name]);
  });

  test('the quick sequence continues only while the pattern is the same', () {
    final settings = AppSettings(quickTokens: ['a', '{n:3}'], quickNext: 9, quickNextKey: 'a\u0001{n:3}');
    expect(settings.nextQuickNumber, 9);
    expect(settings.copyWith(quickTokens: ['b', '{n:3}']).nextQuickNumber, 1);
  });

  test('AppSettings survives a JSON round trip', () {
    final settings = AppSettings(
      mode: NamingMode.quick,
      lastRuleId: 'r',
      quickTokens: ['p_', PatternTokens.date, '{n:3}'],
      quickNext: 4,
      quickNextKey: 'k',
      lastFolder: DestinationFolder(StorageRoot.movies, 'a'),
    );
    expect(AppSettings.fromJson(settings.toJson()).toJson(), settings.toJson());
  });
}
