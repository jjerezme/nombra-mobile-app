import 'package:background_downloader/background_downloader.dart';

/// The background downloader, isolated so the UI and tests do not depend on the platform plugin.
abstract interface class DownloadEngine {
  Stream<TaskUpdate> get updates;

  Future<bool> enqueue(DownloadTask task);

  /// Reconnects to tasks that kept running (or finished) while the app was closed.
  Future<void> restore();

  Future<bool> isTracked(String taskId);

  Future<void> cancel(String taskId);

  /// Notification texts; `{filename}` and `{progress}` are filled in by the plugin.
  void configureNotifications({required String running, required String? complete, required String error});

  Future<void> requestNotificationPermission();
}

/// Turns a single-subscription [source] into a stream that can be listened to again after every listener left.
///
/// The plugin's `updates` can only be listened to once, but the downloads provider is rebuilt (for example when the app
/// comes back to the foreground) and listens again: without this it fails with "Stream has already been listened to".
/// The subscription to [source] is kept open, so events that arrive while nobody listens are dropped, not replayed.
Stream<T> reusableStream<T>(Stream<T> source) => source.asBroadcastStream(onCancel: (_) {});

class PluginDownloadEngine implements DownloadEngine {
  const PluginDownloadEngine();

  static final Stream<TaskUpdate> _updates = reusableStream(FileDownloader().updates);

  @override
  Stream<TaskUpdate> get updates => _updates;

  @override
  Future<bool> enqueue(DownloadTask task) => FileDownloader().enqueue(task);

  @override
  Future<void> restore() async {
    await FileDownloader().trackTasks();
    await FileDownloader().resumeFromBackground();
  }

  @override
  Future<bool> isTracked(String taskId) async => await FileDownloader().taskForId(taskId) != null;

  @override
  Future<void> cancel(String taskId) => FileDownloader().cancelTaskWithId(taskId);

  @override
  void configureNotifications({required String running, required String? complete, required String error}) {
    FileDownloader().configureNotification(
      running: TaskNotification(running, '{progress}'),
      complete: complete == null ? null : TaskNotification(complete, '{filename}'),
      error: TaskNotification(error, '{filename}'),
      progressBar: true,
    );
  }

  @override
  Future<void> requestNotificationPermission() async {
    final permissions = FileDownloader().permissions;
    if (await permissions.status(PermissionType.notifications) != PermissionStatus.granted) {
      await permissions.request(PermissionType.notifications);
    }
  }
}
