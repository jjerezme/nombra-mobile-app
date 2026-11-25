import '../../rules/domain/file_kind.dart';
import '../../settings/app_settings.dart';
import '../../rules/domain/filename_builder.dart';
import '../../rules/domain/rename_rule.dart';
import '../../rules/domain/storage_root.dart';

/// Everything decided before saving: where, under which rule, and optionally a hand-typed name.
class DownloadPlan {
  const DownloadPlan({
    required this.folder,
    this.url,
    this.rule,
    this.fixedFileName,
    this.quickTokens,
    this.quickSignature = '',
  });

  /// Quick mode: the plan keeps the quick pattern it was created with, whatever the user changes while it runs.
  factory DownloadPlan.quick({
    required AppSettings settings,
    required DestinationFolder folder,
    String? url,
    String? fixedFileName,
  }) => DownloadPlan(
    url: url,
    folder: folder,
    fixedFileName: fixedFileName,
    quickTokens: settings.quickTokens,
    quickSignature: settings.quickSignature,
  );

  factory DownloadPlan.fromJson(Map<String, dynamic> json) => DownloadPlan(
    url: json['url'] as String?,
    folder: DestinationFolder.fromJson(json['folder'] as Map<String, dynamic>),
    rule: json['rule'] == null ? null : RenameRule.fromJson(json['rule'] as Map<String, dynamic>),
    fixedFileName: json['fixedFileName'] as String?,
    quickTokens: _quickTokensFrom(json),
    quickSignature: json['quickSignature'] as String? ?? '',
  );

  /// Null when the file is already on the device (a shared file).
  final String? url;
  final DestinationFolder folder;

  /// Snapshot of the rule; null means quick mode (or the original name when [quickTokens] is null too).
  final RenameRule? rule;

  /// A name the user typed by hand; wins over the rule and the quick pattern.
  final String? fixedFileName;

  /// The quick pattern; null keeps the original name.
  final List<String>? quickTokens;

  /// `AppSettings.quickSignature` when the plan was made: the sequence only goes on while it matches.
  final String quickSignature;

  ConflictPolicy get conflict => rule?.conflict ?? ConflictPolicy.suffix;

  bool get usesCounter => rule?.tokens.any((token) => RegExp(r'^\{n:\d+\}$').hasMatch(token)) ?? false;

  /// Final file name for [source]. [takeCounter] is only called when the rule has a counter token, and
  /// [takeQuickNumber] only when the quick pattern has one; a name typed by hand uses neither.
  String nameFor(
    SourceFile source, {
    required DateTime now,
    required int Function(String ruleId) takeCounter,
    required int Function(String signature) takeQuickNumber,
  }) {
    final fixed = fixedFileName;
    if (fixed != null) return fixed;
    final selected = rule;
    if (selected != null) {
      return buildFileName(selected, source, now: now, counter: usesCounter ? takeCounter(selected.id) : null);
    }
    final tokens = quickTokens;
    if (tokens == null) return buildQuickFileName(defaultQuickTokens, source, now: now);
    final counter = tokens.any(PatternTokens.isCounter) ? takeQuickNumber(quickSignature) : 1;
    return buildQuickFileName(tokens, source, now: now, counter: counter);
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'folder': folder.toJson(),
    'rule': rule?.toJson(),
    'fixedFileName': fixedFileName,
    'quickTokens': quickTokens,
    'quickSignature': quickSignature,
  };
}

/// Root of the device's main shared storage; the folders of [DownloadItem.folderPath] hang from it.
const String primaryStorageRoot = '/storage/emulated/0';

enum DownloadStatus { queued, running, finalizing, done, failed }

enum DownloadError { http, notFound, failed, save }

class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.fileName,
    required this.status,
    required this.plan,
    required this.createdAt,
    this.progress = 0,
    this.receivedBytes,
    this.totalBytes,
    this.speedMegabytes,
    this.folderPath = '',
    this.finishedAt,
    this.error,
    this.httpCode,
    this.fallbackKind,
  });

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
    id: json['id'] as String,
    fileName: json['fileName'] as String,
    status: DownloadStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => DownloadStatus.failed),
    plan: DownloadPlan.fromJson(json['plan'] as Map<String, dynamic>),
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    folderPath: json['folderPath'] as String? ?? '',
    finishedAt: json['finishedAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(json['finishedAt'] as int),
    error: DownloadError.values.where((e) => e.name == json['error']).firstOrNull,
    httpCode: json['httpCode'] as int?,
    fallbackKind: FileKind.values.where((k) => k.name == json['fallbackKind']).firstOrNull,
  );

  final String id;
  final String fileName;
  final DownloadStatus status;
  final DownloadPlan plan;
  final DateTime createdAt;
  final double progress;
  final int? receivedBytes;
  final int? totalBytes;
  final double? speedMegabytes;

  /// `/Download/Nombra`, set when the file is saved.
  final String folderPath;
  final DateTime? finishedAt;
  final DownloadError? error;
  final int? httpCode;

  /// Set when the file could not go in the chosen folder and was saved in Download.
  final FileKind? fallbackKind;

  /// Where the saved file is on the device (`/storage/emulated/0/Download/Nombra/file.pdf`); only meaningful once saved.
  String get savedPath => '$primaryStorageRoot$folderPath/$fileName';

  bool get isActive =>
      status == DownloadStatus.queued || status == DownloadStatus.running || status == DownloadStatus.finalizing;

  DownloadItem copyWith({
    String? fileName,
    DownloadStatus? status,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    double? speedMegabytes,
    String? folderPath,
    DateTime? finishedAt,
    DownloadError? error,
    int? httpCode,
    FileKind? fallbackKind,
    bool clearError = false,
  }) => DownloadItem(
    id: id,
    fileName: fileName ?? this.fileName,
    status: status ?? this.status,
    plan: plan,
    createdAt: createdAt,
    progress: progress ?? this.progress,
    receivedBytes: receivedBytes ?? this.receivedBytes,
    totalBytes: totalBytes ?? this.totalBytes,
    speedMegabytes: speedMegabytes ?? this.speedMegabytes,
    folderPath: folderPath ?? this.folderPath,
    finishedAt: finishedAt ?? this.finishedAt,
    error: clearError ? null : error ?? this.error,
    httpCode: clearError ? null : httpCode ?? this.httpCode,
    fallbackKind: fallbackKind ?? this.fallbackKind,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'status': status.name,
    'plan': plan.toJson(),
    'createdAt': createdAt.millisecondsSinceEpoch,
    'folderPath': folderPath,
    'finishedAt': finishedAt?.millisecondsSinceEpoch,
    'error': error?.name,
    'httpCode': httpCode,
    'fallbackKind': fallbackKind?.name,
  };
}

/// The quick pattern of a stored plan; plans saved by the first quick version have prefix and suffix instead.
List<String>? _quickTokensFrom(Map<String, dynamic> json) {
  final tokens = json['quickTokens'] as List<dynamic>?;
  if (tokens != null) return tokens.cast<String>();
  final prefix = json['prefix'] as String? ?? '';
  final suffix = json['suffix'] as String? ?? '';
  final isLegacy = prefix.isNotEmpty || suffix.isNotEmpty || (json['quickSequence'] as bool? ?? false);
  if (!isLegacy) return null;
  return legacyQuickTokens(
    prefix: prefix,
    suffix: suffix,
    replaceName: json['quickReplaceName'] as bool? ?? false,
    sequence: json['quickSequence'] as bool? ?? false,
    digits: json['quickDigits'] as int? ?? 3,
  );
}
