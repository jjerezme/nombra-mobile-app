import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/core/storage_schema.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> prefs([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('fresh data is stamped with the current version', () async {
    final preferences = await prefs();
    await migrateStorage(preferences);
    expect(preferences.getInt(storageSchemaKey), storageSchemaVersion);
  });

  test('runs the pending steps in order and stamps each version', () async {
    final preferences = await prefs({storageSchemaKey: 1});
    final ran = <int>[];
    await migrateStorage(preferences, target: 3, steps: {2: (_) async => ran.add(2), 3: (_) async => ran.add(3)});
    expect(ran, [2, 3]);
    expect(preferences.getInt(storageSchemaKey), 3);
  });

  test('data already at the target is not touched', () async {
    final preferences = await prefs({storageSchemaKey: 2});
    final ran = <int>[];
    await migrateStorage(preferences, target: 2, steps: {2: (_) async => ran.add(2)});
    expect(ran, isEmpty);
  });

  test('data from a newer app keeps its version and is not migrated', () async {
    final preferences = await prefs({storageSchemaKey: 9});
    await migrateStorage(preferences, target: 2, steps: {1: (_) async => fail('must not run')});
    expect(preferences.getInt(storageSchemaKey), 9);
  });

  test('a step that fails stops there, so the next start tries again from that version', () async {
    final preferences = await prefs({storageSchemaKey: 1});
    await expectLater(
      migrateStorage(preferences, target: 3, steps: {2: (_) async => throw StateError('boom'), 3: (_) async {}}),
      throwsStateError,
    );
    expect(preferences.getInt(storageSchemaKey), 1);
  });
}
