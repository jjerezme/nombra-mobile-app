import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nombra/features/download/data/file_finalizer.dart';
import 'package:nombra/features/rules/domain/filename_builder.dart';
import 'package:nombra/features/rules/domain/rename_rule.dart';
import 'package:nombra/features/rules/domain/storage_root.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeStorageGateway gateway;
  late FileFinalizer finalizer;
  late Directory source;

  Future<String> makeFile(String name) async {
    final file = File('${source.path}/$name');
    await file.writeAsString('data');
    return file.path;
  }

  setUp(() async {
    gateway = FakeStorageGateway();
    finalizer = FileFinalizer(gateway);
    source = await Directory.systemTemp.createTemp('nombra_test_');
    addTearDown(() => source.deleteSync(recursive: true));
  });

  test('renames the file and moves it to the matching storage and subfolder', () async {
    final path = await makeFile('tmp123');
    final saved = await finalizer.save(
      sourcePath: path,
      fileName: 'Factura_001.pdf',
      folder: DestinationFolder(StorageRoot.documents, 'Facturas'),
      policy: ConflictPolicy.suffix,
    );
    expect(saved.fileName, 'Factura_001.pdf');
    expect(saved.folderPath, '/Documents/Facturas');
    expect(saved.fallbackKind, isNull);
    expect(gateway.moved.single.fileName, 'Factura_001.pdf');
    expect(gateway.moved.single.destination, SharedStorage.files);
    expect(gateway.moved.single.directory, 'Facturas');
    expect(File(path).existsSync(), isFalse);
  });

  test('a name made of dots or separators never leaves the work folder: it is replaced', () async {
    for (final name in ['..', '.', '../..']) {
      final path = await makeFile('tmp_${name.length}');
      final saved = await finalizer.save(
        sourcePath: path,
        fileName: name,
        folder: DestinationFolder(StorageRoot.download),
        policy: ConflictPolicy.suffix,
      );
      expect(saved.fileName, startsWith(fallbackBaseName));
    }
  });

  test('suffix policy numbers the name until it is free', () async {
    gateway.existing.addAll(['Nombra/a.pdf', 'Nombra/a (1).pdf']);
    final saved = await finalizer.save(
      sourcePath: await makeFile('t'),
      fileName: 'a.pdf',
      folder: DestinationFolder(StorageRoot.download, 'Nombra'),
      policy: ConflictPolicy.suffix,
    );
    expect(saved.fileName, 'a (2).pdf');
  });

  test('ask policy: replace falls back to numbering when the old file cannot be deleted', () async {
    gateway.existing.add('Nombra/a.pdf');
    final deleted = await File('${source.path}/existing.pdf').create();
    // The fake reports the existing file at /storage/..., which cannot be deleted: replace falls back to numbering.
    final saved = await finalizer.save(
      sourcePath: await makeFile('t'),
      fileName: 'a.pdf',
      folder: DestinationFolder(StorageRoot.download, 'Nombra'),
      policy: ConflictPolicy.ask,
      onConflict: (name, folder) async => ConflictChoice.replace,
    );
    expect(deleted.existsSync(), isTrue);
    expect(saved.fileName, 'a (1).pdf');
  });

  test('ask policy: keep both numbers the name; cancel aborts', () async {
    gateway.existing.add('Nombra/a.pdf');
    final folder = DestinationFolder(StorageRoot.download, 'Nombra');
    final kept = await finalizer.save(
      sourcePath: await makeFile('t1'),
      fileName: 'a.pdf',
      folder: folder,
      policy: ConflictPolicy.ask,
      onConflict: (name, folder) async => ConflictChoice.keepBoth,
    );
    expect(kept.fileName, 'a (1).pdf');
    expect(
      () async => finalizer.save(
        sourcePath: await makeFile('t2'),
        fileName: 'a.pdf',
        folder: folder,
        policy: ConflictPolicy.ask,
        onConflict: (name, folder) async => ConflictChoice.cancel,
      ),
      throwsA(isA<SaveCancelled>()),
    );
  });

  test('a document chosen for Pictures goes to Download and reports the fallback', () async {
    final saved = await finalizer.save(
      sourcePath: await makeFile('t'),
      fileName: 'a.pdf',
      folder: DestinationFolder(StorageRoot.pictures, 'Nombra'),
      policy: ConflictPolicy.suffix,
    );
    expect(saved.folderPath, '/Download/Nombra');
    expect(saved.fallbackKind, isNotNull);
    expect(gateway.moved.single.destination, SharedStorage.downloads);
  });

  test('an image in Pictures keeps its folder', () async {
    final saved = await finalizer.save(
      sourcePath: await makeFile('t'),
      fileName: 'a.jpg',
      folder: DestinationFolder(StorageRoot.pictures, 'Nombra'),
      policy: ConflictPolicy.suffix,
    );
    expect(saved.folderPath, '/Pictures/Nombra');
    expect(gateway.moved.single.destination, SharedStorage.images);
  });

  test('throws SaveFailure when the move fails', () async {
    gateway.failMove = true;
    expect(
      () async => finalizer.save(
        sourcePath: await makeFile('t'),
        fileName: 'a.pdf',
        folder: DestinationFolder(StorageRoot.download),
        policy: ConflictPolicy.suffix,
      ),
      throwsA(isA<SaveFailure>()),
    );
  });
}
