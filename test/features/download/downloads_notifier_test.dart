import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/download/data/downloads_notifier.dart';
import 'package:nombra/features/download/domain/download_models.dart';
import 'package:nombra/features/rules/data/rules_notifier.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';

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

  test('history is persisted and restored', () async {
    final container = env.container();
    await container.read(downloadsProvider.notifier).start(planFor(null), displayName: 'a.pdf');
    final second = env.container();
    expect(second.read(downloadsProvider).single.fileName, 'a.pdf');
  });
}
