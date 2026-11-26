/// Public Android folders where files can be saved without storage permissions.
enum StorageRoot {
  download('Download'),
  documents('Documents'),
  pictures('Pictures'),
  movies('Movies'),
  music('Music');

  const StorageRoot(this.dirName);

  final String dirName;

  static StorageRoot fromName(String? name) =>
      StorageRoot.values.firstWhere((root) => root.name == name, orElse: () => StorageRoot.download);
}

/// A public folder plus an optional subfolder, shown as `/Download/Nombra`.
class DestinationFolder {
  DestinationFolder(this.root, [String subfolder = '']) : subfolder = normalizeSubfolder(subfolder);

  factory DestinationFolder.fromJson(Map<String, dynamic> json) =>
      DestinationFolder(StorageRoot.fromName(json['root'] as String?), json['subfolder'] as String? ?? '');

  final StorageRoot root;
  final String subfolder;

  /// Removes characters that are not valid in a folder name and the outer slashes.
  static String normalizeSubfolder(String value) {
    final cleaned = value.replaceAll(r'\', '/').replaceAll(RegExp(r'[:*?"<>|]'), '');
    final parts = cleaned
        .split('/')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && part != '..' && part != '.');
    return parts.join('/');
  }

  /// `/Download/Nombra`
  String get path => subfolder.isEmpty ? '/${root.dirName}' : '/${root.dirName}/$subfolder';

  Map<String, dynamic> toJson() => {'root': root.name, 'subfolder': subfolder};

  @override
  bool operator ==(Object other) => other is DestinationFolder && other.root == root && other.subfolder == subfolder;

  @override
  int get hashCode => Object.hash(root, subfolder);
}
