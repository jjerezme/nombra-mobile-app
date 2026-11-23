import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/current_l10n.dart';
import '../../../core/providers.dart';
import '../../rules/data/rules_notifier.dart';
import '../../rules/domain/filename_builder.dart';
import '../domain/download_models.dart';
import 'download_engine.dart';
import 'file_finalizer.dart';

const String _downloadsKey = 'downloads';
const int _historyLimit = 50;

final downloadEngineProvider = Provider<DownloadEngine>((ref) => const PluginDownloadEngine());

final storageGatewayProvider = Provider<SharedStorageGateway>((ref) => const PluginStorageGateway());

final finalizerProvider = Provider<FileFinalizer>((ref) => FileFinalizer(ref.watch(storageGatewayProvider)));

/// Asks what to do with an existing file; set by the app, which owns the navigator.
final conflictPromptProvider = Provider<ConflictPrompt?>((ref) => null);

/// Download history and the downloads in flight, newest first.
class DownloadsNotifier extends Notifier<List<DownloadItem>> {
  @override
  List<DownloadItem> build() {
    final engine = ref.watch(downloadEngineProvider);
    final subscription = engine.updates.listen(_onUpdate);
    ref.onDispose(subscription.cancel);
    Future.microtask(() => _restore(engine));
    return _load();
  }

  List<DownloadItem> _load() {
    final raw = ref.read(sharedPreferencesProvider).getString(_downloadsKey);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((json) => DownloadItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Object {
      return const [];
    }
  }

  void _set(List<DownloadItem> next) {
    // Work that outlives the provider (a download finishing after dispose) has nowhere to write.
    if (!ref.mounted) return;
    state = next.take(_historyLimit).toList();
    ref
        .read(sharedPreferencesProvider)
        .setString(_downloadsKey, jsonEncode(state.map((item) => item.toJson()).toList()));
  }

  DownloadItem? _find(String id) => ref.mounted ? state.where((item) => item.id == id).firstOrNull : null;

  void _patch(String id, DownloadItem Function(DownloadItem item) change) {
    if (!ref.mounted) return;
    _set([for (final item in state) item.id == id ? change(item) : item]);
  }

  /// Items that were in flight when the app closed: reconnect them, or mark them failed when the task is gone.
  Future<void> _restore(DownloadEngine engine) async {
    await engine.restore();
    if (!ref.mounted) return;
    for (final item in state.where(
      (item) => item.status == DownloadStatus.queued || item.status == DownloadStatus.running,
    )) {
      if (!await engine.isTracked(item.id)) {
        _patch(item.id, (current) => current.copyWith(status: DownloadStatus.failed, error: DownloadError.failed));
      }
    }
  }

  void _onUpdate(TaskUpdate update) {
    final item = _find(update.task.taskId);
    if (item == null) return;
    switch (update) {
      case TaskStatusUpdate():
        _onStatus(item, update);
      case TaskProgressUpdate():
        if (update.progress < 0 || item.status == DownloadStatus.finalizing || item.status == DownloadStatus.done) {
          return;
        }
        final total = update.expectedFileSize > 0 ? update.expectedFileSize : null;
        _set([
          for (final current in state)
            current.id == item.id
                ? current.copyWith(
                    status: DownloadStatus.running,
                    progress: update.progress,
                    totalBytes: total,
                    receivedBytes: total == null ? null : (total * update.progress).round(),
                    speedMegabytes: update.networkSpeed >= 0 ? update.networkSpeed : null,
                  )
                : current,
        ]);
    }
  }

  void _onStatus(DownloadItem item, TaskStatusUpdate update) {
    switch (update.status) {
      case TaskStatus.enqueued:
        _patch(item.id, (current) => current.copyWith(status: DownloadStatus.queued));
      case TaskStatus.running || TaskStatus.waitingToRetry || TaskStatus.paused:
        _patch(item.id, (current) => current.copyWith(status: DownloadStatus.running));
      case TaskStatus.complete:
        _finalize(item.id, () async {
          final task = update.task;
          return task is DownloadTask ? task.filePath() : '';
        }, SourceFile(name: '', domain: Uri.tryParse(item.plan.url ?? '')?.host ?? ''));
      case TaskStatus.notFound:
        _fail(item.id, DownloadError.notFound, httpCode: 404);
      case TaskStatus.failed:
        final code = update.responseStatusCode;
        _fail(item.id, code == null || code < 400 ? DownloadError.failed : DownloadError.http, httpCode: code);
      case TaskStatus.canceled:
        _set(state.where((current) => current.id != item.id).toList());
    }
  }

  void _fail(String id, DownloadError error, {int? httpCode}) {
    _patch(
      id,
      (item) =>
          item.copyWith(status: DownloadStatus.failed, error: error, httpCode: httpCode, finishedAt: DateTime.now()),
    );
  }

  /// Names the downloaded (or shared) file at [pathOf] with the plan and moves it into its folder.
  Future<void> _finalize(String id, Future<String> Function() pathOf, SourceFile origin) async {
    final item = _find(id);
    if (item == null) return;
    _patch(id, (current) => current.copyWith(status: DownloadStatus.finalizing, progress: 1));
    try {
      final path = await pathOf();
      final source = SourceFile(
        name: origin.name.isEmpty ? path.split(RegExp(r'[/\\]')).last : origin.name,
        domain: origin.domain,
      );
      final plan = item.plan;
      final rules = ref.read(rulesProvider.notifier);
      final fileName = plan.nameFor(source, now: DateTime.now(), takeCounter: rules.takeCounter);
      final saved = await ref
          .read(finalizerProvider)
          .save(
            sourcePath: path,
            fileName: fileName,
            folder: plan.folder,
            policy: plan.conflict,
            onConflict: ref.read(conflictPromptProvider),
          );
      _patch(
        id,
        (current) => current.copyWith(
          status: DownloadStatus.done,
          fileName: saved.fileName,
          folderPath: saved.folderPath,
          fallbackKind: saved.fallbackKind,
          finishedAt: DateTime.now(),
          clearError: true,
        ),
      );
    } on SaveCancelled {
      _set(state.where((current) => current.id != id).toList());
    } on Object {
      _fail(id, DownloadError.save);
    }
  }

  DownloadItem _newItem(DownloadPlan plan, String fileName, DownloadStatus status) => DownloadItem(
    id: ref.read(rulesProvider.notifier).newId(),
    fileName: fileName,
    status: status,
    plan: plan,
    createdAt: DateTime.now(),
    folderPath: plan.folder.path,
  );

  DownloadTask _taskFor(DownloadItem item) => DownloadTask(
    taskId: item.id,
    url: item.plan.url!,
    filename: DownloadTask.suggestedFilename,
    directory: 'nombra',
    baseDirectory: BaseDirectory.temporary,
    updates: Updates.statusAndProgress,
    retries: 2,
    metaData: item.id,
  );

  /// Starts downloading [plan]'s URL; [displayName] is the name shown while it downloads.
  Future<String> start(DownloadPlan plan, {required String displayName}) async {
    final engine = ref.read(downloadEngineProvider);
    final l10n = currentL10n();
    engine.configureNotifications(
      running: l10n.downloadNotificationRunning('{filename}'),
      complete: l10n.downloadNotificationComplete,
      error: l10n.downloadNotificationError,
    );
    final item = _newItem(plan, displayName, DownloadStatus.queued);
    _set([item, ...state]);
    await engine.requestNotificationPermission();
    if (!await engine.enqueue(_taskFor(item))) _fail(item.id, DownloadError.failed);
    return item.id;
  }

  /// Saves a file that is already on the device (a shared file) with the plan's name and folder.
  Future<String> saveLocalFile(DownloadPlan plan, {required String path, required String fileName}) async {
    final item = _newItem(plan, fileName, DownloadStatus.finalizing);
    _set([item, ...state]);
    await _finalize(item.id, () async => path, SourceFile(name: fileName));
    return item.id;
  }

  Future<void> retry(String id) async {
    final item = _find(id);
    if (item == null) return;
    if (item.plan.url == null) {
      dismiss(id);
      return;
    }
    _patch(id, (current) => current.copyWith(status: DownloadStatus.queued, progress: 0, clearError: true));
    final engine = ref.read(downloadEngineProvider);
    if (!await engine.enqueue(_taskFor(item))) _fail(id, DownloadError.failed);
  }

  void dismiss(String id) => _set(state.where((item) => item.id != id).toList());
}

final downloadsProvider = NotifierProvider<DownloadsNotifier, List<DownloadItem>>(DownloadsNotifier.new);
