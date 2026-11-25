import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/account/data/auth_gateway.dart';
import 'package:nombra/features/account/data/backup_sync.dart';
import 'package:nombra/features/account/domain/account_models.dart';
import 'package:nombra/features/account/domain/rules_merge.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';

import '../../helpers/account_fakes.dart';
import '../../helpers/fakes.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 30));

RenameRule rule(String id, String name, {int counter = 1}) => RenameRule(
  id: id,
  name: name,
  tokens: const [PatternTokens.name],
  folder: DestinationFolder(StorageRoot.download),
  counter: counter,
);

void main() {
  late TestEnvironment env;
  late FakeAuthGateway auth;
  late FakeBackupGateway backup;

  ProviderContainer containerWith({List<RenameRule> local = const []}) {
    final container = ProviderContainer(overrides: [...env.overrides, ...accountOverrides(auth, backup)]);
    addTearDown(container.dispose);
    // The app keeps the backup alive from its root widget; here the test does.
    container
      ..listen(backupSyncProvider, (_, _) {})
      ..listen(accountUserProvider, (_, _) {});
    for (final item in local) {
      container.read(rulesProvider.notifier).upsert(item);
    }
    return container;
  }

  setUp(() async {
    env = await TestEnvironment.create();
    auth = FakeAuthGateway();
    backup = FakeBackupGateway();
  });

  group('mergeRules', () {
    test('keeps the rules of both sides; for a shared rule the cloud wins but the counter keeps the higher number', () {
      final merged = mergeRules(
        [rule('a', 'Local A', counter: 9), rule('b', 'Solo local')],
        [rule('a', 'Nube A', counter: 3), rule('c', 'Solo nube')],
      );
      final byId = {for (final r in merged) r.id: r};
      expect(byId.keys, unorderedEquals(['a', 'b', 'c']));
      expect(byId['a']!.name, 'Nube A');
      expect(byId['a']!.counter, 9);
    });

    test('encodeRules and decodeRules round trip, and a bad value is null', () {
      final rules = [rule('a', 'A', counter: 4)];
      expect(decodeRules(encodeRules(rules))!.single.counter, 4);
      expect(decodeRules('no es json'), isNull);
    });
  });

  group('signing in', () {
    test('nothing is sent while nobody is signed in', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      await settle();
      expect(backup.saves, isEmpty);
      expect(container.read(backupSyncProvider).phase, SyncPhase.off);
    });

    test('with no backup yet, the rules of this device are uploaded', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      expect(backup.saves, hasLength(1));
      expect(decodeRules(backup.saves.single.rulesJson)!.single.id, 'a');
      expect(backup.saves.single.writer, 'this-device');
      expect(container.read(backupSyncProvider).phase, SyncPhase.upToDate);
    });

    test('with no backup and no rules, nothing is uploaded', () async {
      final container = containerWith();
      auth.emit(testUser);
      await settle();
      expect(backup.saves, isEmpty);
      expect(container.read(backupSyncProvider).phase, SyncPhase.upToDate);
    });

    test('a new phone with no rules gets the ones in the cloud, without uploading them again', () async {
      backup.stored[testUser.uid] = RulesBackup(rulesJson: encodeRules([rule('c', 'De la nube')]), writer: 'phone-1');
      final container = containerWith();
      auth.emit(testUser);
      await settle();
      expect(container.read(rulesProvider).single.name, 'De la nube');
      expect(backup.saves, isEmpty);
    });

    test('rules on both sides are merged and the result goes back to the cloud', () async {
      backup.stored[testUser.uid] = RulesBackup(rulesJson: encodeRules([rule('c', 'De la nube')]), writer: 'phone-1');
      final container = containerWith(local: [rule('a', 'Local')]);
      auth.emit(testUser);
      await settle();
      expect(container.read(rulesProvider).map((r) => r.id), unorderedEquals(['a', 'c']));
      expect(decodeRules(backup.saves.single.rulesJson)!.map((r) => r.id), unorderedEquals(['a', 'c']));
    });

    test('a failure reading the cloud shows the error state, and retry works', () async {
      backup.failFetch = true;
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      expect(container.read(backupSyncProvider).phase, SyncPhase.error);
      backup.failFetch = false;
      await container.read(backupSyncProvider.notifier).retry();
      expect(container.read(backupSyncProvider).phase, SyncPhase.upToDate);
      expect(backup.saves, hasLength(1));
    });
  });

  group('while signed in', () {
    test('a change to the rules is sent', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      container.read(rulesProvider.notifier).upsert(rule('b', 'B'));
      await settle();
      expect(backup.saves, hasLength(2));
      expect(decodeRules(backup.saves.last.rulesJson)!.map((r) => r.id), unorderedEquals(['a', 'b']));
    });

    test('a change made on another device replaces the local rules and is not sent back', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      final before = backup.saves.length;
      backup.remoteWrite(testUser.uid, encodeRules([rule('a', 'A editada'), rule('z', 'Z')]));
      await settle();
      expect(container.read(rulesProvider).map((r) => r.name), unorderedEquals(['A editada', 'Z']));
      expect(backup.saves, hasLength(before));
    });

    test('the echo of this device\'s own write is ignored', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      backup.remoteWrite(testUser.uid, encodeRules([rule('x', 'Otra')]), writer: 'this-device');
      await settle();
      expect(container.read(rulesProvider).single.id, 'a');
    });

    test('a failed send shows the error state', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      backup.failSave = true;
      container.read(rulesProvider.notifier).upsert(rule('b', 'B'));
      await settle();
      expect(container.read(backupSyncProvider).phase, SyncPhase.error);
    });

    test('signing out stops the backup; the rules stay on the device', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      await container.read(backupSyncProvider.notifier).signOut();
      await settle();
      final saves = backup.saves.length;
      container.read(rulesProvider.notifier).upsert(rule('b', 'B'));
      await settle();
      expect(backup.saves, hasLength(saves));
      expect(container.read(rulesProvider), hasLength(2));
      expect(container.read(backupSyncProvider).phase, SyncPhase.off);
    });

    test('deleting the backup removes it from the cloud and signs out', () async {
      final container = containerWith(local: [rule('a', 'A')]);
      auth.emit(testUser);
      await settle();
      await container.read(backupSyncProvider.notifier).deleteBackupAndSignOut();
      await settle();
      expect(backup.deleted, [testUser.uid]);
      expect(backup.stored, isEmpty);
      expect(auth.currentUser, isNull);
      expect(container.read(rulesProvider), hasLength(1));
    });
  });
}
