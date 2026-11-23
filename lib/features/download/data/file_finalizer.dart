import 'dart:io';

import 'package:background_downloader/background_downloader.dart';

import '../../rules/domain/file_kind.dart';
import '../../rules/domain/filename_builder.dart';
import '../../rules/domain/rename_rule.dart';
import '../../rules/domain/storage_root.dart';

enum ConflictChoice { replace, keepBoth, cancel }

typedef ConflictPrompt = Future<ConflictChoice> Function(String fileName, DestinationFolder folder);

/// Access to Android shared storage (MediaStore), isolated so it can be faked in tests.
abstract interface class SharedStorageGateway {
  /// Where a file with the name of [filePath] already is in [destination]/[directory], or null.
  Future<String?> pathInStorage(String filePath, SharedStorage destination, String directory);

  /// Moves [filePath] into [destination]/[directory]; null when it failed.
  Future<String?> move(String filePath, SharedStorage destination, String directory);
}

class PluginStorageGateway implements SharedStorageGateway {
  const PluginStorageGateway();

  @override
  Future<String?> pathInStorage(String filePath, SharedStorage destination, String directory) =>
      FileDownloader().pathInSharedStorage(filePath, destination, directory: directory);

  @override
  Future<String?> move(String filePath, SharedStorage destination, String directory) =>
      FileDownloader().moveFileToSharedStorage(filePath, destination, directory: directory);
}

class SaveFailure implements Exception {
  const SaveFailure(this.message);

  final String message;

  @override
  String toString() => 'SaveFailure: $message';
}

/// The user cancelled when asked what to do with an existing file.
class SaveCancelled implements Exception {
  const SaveCancelled();
}

class SavedFile {
  const SavedFile({required this.fileName, required this.folderPath, this.fallbackKind});

  final String fileName;
  final String folderPath;

  /// Set when the file went to Download because its type does not fit the chosen folder.
  final FileKind? fallbackKind;
}

/// The shared storage that matches [root], or Download when [kind] cannot live there
/// (Android only allows pictures in Pictures, videos in Movies and audio in Music).
(SharedStorage, bool) storageFor(StorageRoot root, FileKind kind) => switch (root) {
  StorageRoot.download => (SharedStorage.downloads, false),
  StorageRoot.documents => (SharedStorage.files, false),
  StorageRoot.pictures => kind == FileKind.image ? (SharedStorage.images, false) : (SharedStorage.downloads, true),
  StorageRoot.movies => kind == FileKind.video ? (SharedStorage.video, false) : (SharedStorage.downloads, true),
  StorageRoot.music => kind == FileKind.audio ? (SharedStorage.audio, false) : (SharedStorage.downloads, true),
};

/// Gives a file its final name and moves it into the chosen public folder.
class FileFinalizer {
  const FileFinalizer(this._storage);

  final SharedStorageGateway _storage;

  Future<SavedFile> save({
    required String sourcePath,
    required String fileName,
    required DestinationFolder folder,
    required ConflictPolicy policy,
    ConflictPrompt? onConflict,
  }) async {
    final kind = fileKindOf(extension: splitFileName(fileName).$2);
    final (destination, didFallBack) = storageFor(folder.root, kind);
    final directory = folder.subfolder;
    final work = await Directory.systemTemp.createTemp('nombra_');
    try {
      var current = sourcePath;
      var candidate = fileName;
      var number = 0;
      var effective = policy;
      while (true) {
        final target = '${work.path}/$candidate';
        await _moveFile(current, target);
        current = target;
        final existing = await _storage.pathInStorage(current, destination, directory);
        if (existing == null) break;
        if (effective == ConflictPolicy.ask) {
          final choice = await onConflict?.call(candidate, folder) ?? ConflictChoice.keepBoth;
          if (choice == ConflictChoice.cancel) throw const SaveCancelled();
          effective = choice == ConflictChoice.replace ? ConflictPolicy.replace : ConflictPolicy.suffix;
        }
        if (effective == ConflictPolicy.replace && await _tryDelete(existing)) break;
        effective = ConflictPolicy.suffix;
        number++;
        candidate = withNumberSuffix(fileName, number);
      }
      final stored = await _storage.move(current, destination, directory);
      if (stored == null) throw SaveFailure('Could not move $candidate to ${folder.path}');
      final savedFolder = didFallBack ? DestinationFolder(StorageRoot.download, folder.subfolder) : folder;
      return SavedFile(fileName: candidate, folderPath: savedFolder.path, fallbackKind: didFallBack ? kind : null);
    } finally {
      if (work.existsSync()) work.deleteSync(recursive: true);
    }
  }

  Future<void> _moveFile(String from, String to) async {
    if (from == to) return;
    final file = File(from);
    try {
      await file.rename(to);
    } on FileSystemException {
      await file.copy(to);
      await file.delete();
    }
  }

  Future<bool> _tryDelete(String path) async {
    try {
      await File(path).delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }
}
