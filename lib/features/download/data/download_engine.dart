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
  void configureNotifications({required String running, required String complete, required String error});

  Future<void> requestNotificationPermission();
}

class PluginDownloadEngine implements DownloadEngine {
  const PluginDownloadEngine();

  @override
  Stream<TaskUpdate> get updates => FileDownloader().updates;

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
  void configureNotifications({required String running, required String complete, required String error}) {
    FileDownloader().configureNotification(
      running: TaskNotification(running, '{progress}'),
      complete: TaskNotification(complete, '{filename}'),
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
