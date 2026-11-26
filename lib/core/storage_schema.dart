import 'package:shared_preferences/shared_preferences.dart';

/// Version of how the app lays out its data in `shared_preferences`. Raise it, and add a step to [storageMigrations],
/// whenever a stored value changes shape in a way `fromJson` cannot read on its own.
const int storageSchemaVersion = 1;

const String storageSchemaKey = 'schemaVersion';

/// One step per version: `storageMigrations[2]` moves data from version 1 to version 2.
final Map<int, Future<void> Function(SharedPreferences preferences)> storageMigrations = {
  // Version 1 only stamps the data: before it, `fromJson` read every older shape (the first quick mode, the rules'
  // flags) on its own.
};

/// Brings the stored data up to [storageSchemaVersion], one step at a time, and stamps the version.
///
/// Data written by a newer app (a higher version) is left alone: this build cannot know its shape.
Future<void> migrateStorage(
  SharedPreferences preferences, {
  int target = storageSchemaVersion,
  Map<int, Future<void> Function(SharedPreferences preferences)>? steps,
}) async {
  final migrations = steps ?? storageMigrations;
  final current = preferences.getInt(storageSchemaKey) ?? 0;
  if (current >= target) return;
  for (var version = current + 1; version <= target; version++) {
    await migrations[version]?.call(preferences);
    await preferences.setInt(storageSchemaKey, version);
  }
}
