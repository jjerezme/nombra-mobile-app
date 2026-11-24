import 'dart:async';
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart' show addTearDown;
import 'package:nombra/core/providers.dart';
import 'package:nombra/features/download/data/download_engine.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/download/data/file_finalizer.dart';
import 'package:nombra/features/download/data/notification_gateway.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDownloadEngine implements DownloadEngine {
  final StreamController<TaskUpdate> controller = StreamController<TaskUpdate>.broadcast();
  final List<DownloadTask> enqueued = [];
  bool enqueueResult = true;

  @override
  Stream<TaskUpdate> get updates => controller.stream;

  @override
  Future<bool> enqueue(DownloadTask task) async {
    enqueued.add(task);
    return enqueueResult;
  }

  @override
  Future<void> restore() async {}

  @override
  Future<bool> isTracked(String taskId) async => true;

  @override
  Future<void> cancel(String taskId) async {}

  @override
  void configureNotifications({required String running, required String? complete, required String error}) {}

  @override
  Future<void> requestNotificationPermission() async {}
}

class FakeNotificationGateway implements NotificationGateway {
  final List<({int id, String title, String text})> shown = [];

  @override
  Future<void> show({required int id, required String title, required String text, required String channelName}) async {
    shown.add((id: id, title: title, text: text));
  }
}

class StoredCall {
  StoredCall(this.fileName, this.destination, this.directory);

  final String fileName;
  final SharedStorage destination;
  final String directory;
}

class FakeStorageGateway implements SharedStorageGateway {
  /// Names (`directory/fileName`) that already exist in storage.
  final Set<String> existing = {};
  final List<StoredCall> moved = [];
  bool failMove = false;

  String _name(String path) => path.split('/').last;

  @override
  Future<String?> pathInStorage(String filePath, SharedStorage destination, String directory) async {
    final key = '$directory/${_name(filePath)}';
    return existing.contains(key) ? '/storage/$key' : null;
  }

  @override
  Future<String?> move(String filePath, SharedStorage destination, String directory) async {
    if (failMove) return null;
    moved.add(StoredCall(_name(filePath), destination, directory));
    existing.add('$directory/${_name(filePath)}');
    return '/storage/$directory/${_name(filePath)}';
  }
}

/// Rules for tests that need some: the app itself starts with none.
List<RenameRule> sampleRules() => [
  RenameRule(
    id: 'date-name',
    name: 'Fecha + nombre',
    tokens: const [PatternTokens.date, '_', PatternTokens.name],
    folder: DestinationFolder(StorageRoot.download, 'Nombra'),
    isDefault: true,
  ),
  RenameRule(
    id: 'original',
    name: 'Original',
    tokens: const [PatternTokens.name],
    folder: DestinationFolder(StorageRoot.download),
  ),
  RenameRule(
    id: 'clean',
    name: 'Limpio',
    tokens: const [PatternTokens.name],
    caseMode: CaseMode.lower,
    replaceSpaces: true,
    removeCopySuffix: true,
    sanitize: true,
    folder: DestinationFolder(StorageRoot.documents, 'Nombra'),
  ),
  RenameRule(
    id: 'invoices',
    name: 'Facturas',
    tokens: const ['Factura_', PatternTokens.date, '_', PatternTokens.counter],
    folder: DestinationFolder(StorageRoot.documents, 'Facturas'),
  ),
];

/// Preferences with [rules] already stored.
Map<String, Object> storedRules(List<RenameRule> rules) => {
  'rules': jsonEncode(rules.map((rule) => rule.toJson()).toList()),
};

class TestEnvironment {
  TestEnvironment._(this.preferences, this.engine, this.gateway);

  final FakeNotificationGateway notifications = FakeNotificationGateway();

  static Future<TestEnvironment> create({Map<String, Object> preferences = const {}}) async {
    SharedPreferences.setMockInitialValues(preferences);
    return TestEnvironment._(await SharedPreferences.getInstance(), FakeDownloadEngine(), FakeStorageGateway());
  }

  final SharedPreferences preferences;
  final FakeDownloadEngine engine;
  final FakeStorageGateway gateway;

  List<Override> get overrides => [
    sharedPreferencesProvider.overrideWithValue(preferences),
    downloadEngineProvider.overrideWithValue(engine),
    storageGatewayProvider.overrideWithValue(gateway),
    notificationGatewayProvider.overrideWithValue(notifications),
  ];

  ProviderContainer container() {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }
}
