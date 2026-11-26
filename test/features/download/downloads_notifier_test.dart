import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/download/domain/download_models.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';
import 'package:nombra/features/settings/app_settings.dart';

import '../../helpers/fakes.dart';

/// The task the plugin reports when it finishes: same id, a real file on disk.
DownloadTask finishedTask(String id, File file) => DownloadTask(
  taskId: id,
  url: 'https://cdn.ejemplo.com/docs/Informe%20Q3.pdf',
  filename: file.uri.pathSegments.last,
  directory: file.parent.path,
  baseDirectory: BaseDirectory.root,
);

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  late TestEnvironment env;
  late Directory tempDir;

  setUp(() async {
    env = await TestEnvironment.create();
    tempDir = await Directory.systemTemp.createTemp('nombra_dl_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
  });

  final rule = RenameRule(
    id: 'r1',
    name: 'Facturas',
    tokens: const ['Factura_', PatternTokens.counter],
    folder: DestinationFolder(StorageRoot.documents, 'Facturas'),
    counter: 14,
  );

  DownloadPlan planFor(RenameRule? rule) => DownloadPlan(
    url: 'https://cdn.ejemplo.com/docs/Informe%20Q3.pdf',
    folder: rule?.folder ?? DestinationFolder(StorageRoot.download, 'Nombra'),
    rule: rule,
  );

  test('start enqueues a task with the item id and lists the item as queued', () async {
    final container = env.container();
    final id = await container.read(downloadsProvider.notifier).start(planFor(null), displayName: 'a.pdf');
    final items = container.read(downloadsProvider);
    expect(items.single.id, id);
    expect(items.single.status, DownloadStatus.queued);
    expect(env.engine.enqueued.single.taskId, id);
    expect(env.engine.enqueued.single.url, 'https://cdn.ejemplo.com/docs/Informe%20Q3.pdf');
  });

  test('a completed download is renamed with the rule counter and saved in its folder', () async {
    final container = env.container();
    container.read(rulesProvider.notifier).upsert(rule);
    final id = await container.read(downloadsProvider.notifier).start(planFor(rule), displayName: 'x.pdf');
    final downloaded = await File('${tempDir.path}/Informe Q3.pdf').writeAsString('data');

    env.engine.controller.add(TaskStatusUpdate(finishedTask(id, downloaded), TaskStatus.complete));
    await settle();

    final item = container.read(downloadsProvider).single;
    expect(item.status, DownloadStatus.done);
    expect(item.fileName, 'Factura_014.pdf');
    expect(item.folderPath, '/Documents/Facturas');
    expect(env.gateway.moved.single.directory, 'Facturas');
    expect(container.read(rulesProvider.notifier).byId('r1')!.counter, 15);

    // The result is announced with a notification that names the final file and its folder.
    final notification = env.notifications.shown.single;
    expect(notification.title, 'Saved');
    expect(notification.text, contains('Factura_014.pdf'));
    expect(notification.text, contains('/Documents/Facturas'));
  });

  test('progress updates fill the item', () async {
    final container = env.container();
    final id = await container.read(downloadsProvider.notifier).start(planFor(null), displayName: 'a.pdf');
    final task = finishedTask(id, File('${tempDir.path}/a.pdf'));
    env.engine.controller.add(TaskProgressUpdate(task, 0.5, 2000, 3.1));
    await settle();
    final item = container.read(downloadsProvider).single;
    expect(item.status, DownloadStatus.running);
    expect(item.progress, 0.5);
    expect(item.totalBytes, 2000);
    expect(item.receivedBytes, 1000);
    expect(item.speedMegabytes, 3.1);
  });

  test('a failed task keeps the HTTP code and can be retried', () async {
    final container = env.container();
    final notifier = container.read(downloadsProvider.notifier);
    final id = await notifier.start(planFor(null), displayName: 'a.pdf');
    final task = finishedTask(id, File('${tempDir.path}/a.pdf'));
    env.engine.controller.add(TaskStatusUpdate(task, TaskStatus.failed, null, null, null, 403));
    await settle();
    var item = container.read(downloadsProvider).single;
    expect(item.status, DownloadStatus.failed);
    expect(item.error, DownloadError.http);
    expect(item.httpCode, 403);

    await notifier.retry(id);
    item = container.read(downloadsProvider).single;
    expect(item.status, DownloadStatus.queued);
    expect(item.error, isNull);
    expect(env.engine.enqueued, hasLength(2));
  });

  test('a 404 is reported as not found', () async {
    final container = env.container();
    final id = await container.read(downloadsProvider.notifier).start(planFor(null), displayName: 'a.pdf');
    env.engine.controller.add(TaskStatusUpdate(finishedTask(id, File('${tempDir.path}/a.pdf')), TaskStatus.notFound));
    await settle();
    expect(container.read(downloadsProvider).single.error, DownloadError.notFound);
  });

  test('a storage failure marks the item as a save error', () async {
    final container = env.container();
    final id = await container.read(downloadsProvider.notifier).start(planFor(null), displayName: 'a.pdf');
    env.gateway.failMove = true;
    final downloaded = await File('${tempDir.path}/a.pdf').writeAsString('data');
    env.engine.controller.add(TaskStatusUpdate(finishedTask(id, downloaded), TaskStatus.complete));
    await settle();
    expect(container.read(downloadsProvider).single.error, DownloadError.save);
  });

  test('saveLocalFile saves a shared file with the fixed name the user typed', () async {
    final container = env.container();
    final file = await File('${tempDir.path}/IMG_1.jpg').writeAsString('data');
    final plan = DownloadPlan(folder: DestinationFolder(StorageRoot.pictures, 'Nombra'), fixedFileName: 'mi-foto.jpg');
    await container.read(downloadsProvider.notifier).saveLocalFile(plan, path: file.path, fileName: 'IMG_1.jpg');
    final item = container.read(downloadsProvider).single;
    expect(item.status, DownloadStatus.done);
    expect(item.fileName, 'mi-foto.jpg');
    expect(item.folderPath, '/Pictures/Nombra');
  });

  group('quick sequence', () {
    AppSettings quickSettings({String prefix = 'Foto_'}) =>
        AppSettings(mode: NamingMode.quick, quickTokens: [prefix, '{n:3}']);

    Future<String> saveShared(ProviderContainer container, DownloadPlan plan, String name) async {
      final file = await File('${tempDir.path}/$name').writeAsString('data');
      await container.read(downloadsProvider.notifier).saveLocalFile(plan, path: file.path, fileName: name);
      return container.read(downloadsProvider).first.fileName;
    }

    test('each file takes the next number and the next one is kept', () async {
      final container = env.container();
      final settings = quickSettings();
      DownloadPlan plan() => DownloadPlan.quick(settings: settings, folder: DestinationFolder(StorageRoot.pictures));

      expect(await saveShared(container, plan(), 'IMG_1.jpg'), 'Foto_001.jpg');
      expect(await saveShared(container, plan(), 'IMG_2.jpg'), 'Foto_002.jpg');

      // A new container (the app was closed and reopened) goes on from the saved number.
      final reopened = env.container();
      expect(reopened.read(settingsProvider).quickNext, 3);
      expect(await saveShared(reopened, plan(), 'IMG_3.jpg'), 'Foto_003.jpg');
    });

    test('changing the pattern starts the sequence again at 1', () async {
      final container = env.container();
      final folder = DestinationFolder(StorageRoot.pictures);
      await saveShared(container, DownloadPlan.quick(settings: quickSettings(), folder: folder), 'a.jpg');
      await saveShared(container, DownloadPlan.quick(settings: quickSettings(), folder: folder), 'b.jpg');

      final other = quickSettings(prefix: 'Otra_');
      expect(await saveShared(container, DownloadPlan.quick(settings: other, folder: folder), 'c.jpg'), 'Otra_001.jpg');
    });

    test('a name typed by hand does not use up a number', () async {
      final container = env.container();
      final folder = DestinationFolder(StorageRoot.pictures);
      final settings = quickSettings();
      final fixed = DownloadPlan.quick(settings: settings, folder: folder, fixedFileName: 'mio.jpg');
      expect(await saveShared(container, fixed, 'a.jpg'), 'mio.jpg');
      expect(
        await saveShared(container, DownloadPlan.quick(settings: settings, folder: folder), 'b.jpg'),
        'Foto_001.jpg',
      );
    });

    test('the plan keeps the pattern it was made with', () {
      final plan = DownloadPlan.quick(settings: quickSettings(), folder: DestinationFolder(StorageRoot.pictures));
      final restored = DownloadPlan.fromJson(plan.toJson());
      expect(restored.quickTokens, ['Foto_', '{n:3}']);
      expect(restored.quickSignature, plan.quickSignature);
    });

    test('a pattern without a number does not touch the saved sequence', () async {
      final container = env.container();
      final folder = DestinationFolder(StorageRoot.pictures);
      final settings = AppSettings(mode: NamingMode.quick, quickTokens: ['Foto_', PatternTokens.name]);
      final name = await saveShared(container, DownloadPlan.quick(settings: settings, folder: folder), 'a.jpg');
      expect(name, 'Foto_a.jpg');
      expect(container.read(settingsProvider).quickNextKey, isNull);
    });

    test('plans stored by the first quick version keep their name', () {
      final plan = DownloadPlan.fromJson({
        'folder': DestinationFolder(StorageRoot.pictures).toJson(),
        'prefix': 'Foto_',
        'suffix': '',
        'quickReplaceName': true,
        'quickSequence': true,
        'quickDigits': 3,
      });
      expect(plan.quickTokens, ['Foto_', '{n:3}']);
    });
  });

  test('history is persisted and restored', () async {
    final container = env.container();
    await container.read(downloadsProvider.notifier).start(planFor(null), displayName: 'a.pdf');
    final second = env.container();
    expect(second.read(downloadsProvider).single.fileName, 'a.pdf');
  });

  group('actions on a finished download', () {
    Future<(ProviderContainer, String)> savedItem() async {
      final container = env.container();
      container.read(rulesProvider.notifier).upsert(rule);
      final id = await container.read(downloadsProvider.notifier).start(planFor(rule), displayName: 'x.pdf');
      final downloaded = await File('${tempDir.path}/Informe Q3.pdf').writeAsString('data');
      env.engine.controller.add(TaskStatusUpdate(finishedTask(id, downloaded), TaskStatus.complete));
      await settle();
      return (container, id);
    }

    test('the saved path is the shared storage root plus the folder and the final name', () async {
      final (container, _) = await savedItem();
      expect(
        container.read(downloadsProvider).single.savedPath,
        '/storage/emulated/0/Documents/Facturas/Factura_014.pdf',
      );
    });

    test('open asks the system to open the saved file', () async {
      final (container, id) = await savedItem();
      expect(await container.read(downloadsProvider.notifier).open(id), isTrue);
      expect(env.gateway.opened, ['/storage/emulated/0/Documents/Facturas/Factura_014.pdf']);
    });

    test('open reports false when the file cannot be opened, or the item is not saved yet', () async {
      final (container, id) = await savedItem();
      final notifier = container.read(downloadsProvider.notifier);
      env.gateway.failOpen = true;
      expect(await notifier.open(id), isFalse);
      final pending = await notifier.start(planFor(null), displayName: 'b.pdf');
      env.gateway.failOpen = false;
      expect(await notifier.open(pending), isFalse);
      expect(await notifier.open('missing'), isFalse);
    });

    test('dismiss takes the item off the list and leaves the file alone', () async {
      final (container, id) = await savedItem();
      container.read(downloadsProvider.notifier).dismiss(id);
      expect(container.read(downloadsProvider), isEmpty);
      expect(env.gateway.existing, contains('Facturas/Factura_014.pdf'));
    });
  });
}
