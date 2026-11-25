import '../../rules/domain/file_kind.dart';
import '../../rules/domain/filename_builder.dart';

/// A file received from another app, already copied to the app's cache.
class SharedFile {
  const SharedFile({required this.path, required this.name, this.mimeType, this.size});

  factory SharedFile.fromMap(Map<Object?, Object?> map) => SharedFile(
    path: map['path']! as String,
    name: map['name']! as String,
    mimeType: map['mimeType'] as String?,
    size: (map['size'] as num?)?.toInt(),
  );

  final String path;
  final String name;
  final String? mimeType;
  final int? size;
}

/// What another app shared: text (maybe with a link) and/or files.
class SharePayload {
  const SharePayload({this.text, this.files = const []});

  factory SharePayload.fromMap(Map<Object?, Object?> map) => SharePayload(
    text: map['text'] as String?,
    files: ((map['files'] as List<Object?>?) ?? const [])
        .map((file) => SharedFile.fromMap(file! as Map<Object?, Object?>))
        .toList(),
  );

  final String? text;
  final List<SharedFile> files;

  String? get url => text == null ? null : firstUrlIn(text!);

  /// The text has a plain http link, which is refused: it tells the user why there is nothing to save.
  bool get hasInsecureUrl => url == null && text != null && hasInsecureLink(text!);

  /// Something Nombra can save: files, or a link.
  bool get isEmpty => files.isEmpty && url == null;
}

/// One thing to save: a local file, or a URL to download.
class ShareItem {
  const ShareItem({required this.name, this.path, this.url, this.mimeType, this.size, this.domain = ''});

  /// Local file name, or the name taken from the URL (empty when the URL has none).
  final String name;
  final String? path;
  final String? url;
  final String? mimeType;
  final int? size;
  final String domain;

  bool get isUrl => url != null;

  SourceFile get source => SourceFile(name: name.isEmpty ? fallbackBaseName : name, domain: domain);

  FileKind get kind => fileKindOf(mimeType: mimeType, extension: source.extension);
}

List<ShareItem> itemsOf(SharePayload payload) {
  if (payload.files.isNotEmpty) {
    return [
      for (final file in payload.files)
        ShareItem(name: file.name, path: file.path, mimeType: file.mimeType, size: file.size),
    ];
  }
  final url = payload.url;
  if (url == null) return const [];
  final source = sourceFromUrl(url);
  return [ShareItem(name: source.name, url: url, domain: source.domain)];
}
