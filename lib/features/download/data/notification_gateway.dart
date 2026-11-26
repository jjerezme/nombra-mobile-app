import 'package:flutter/services.dart';

/// Shows the result of a save ("Saved as ..." / "Could not save"), isolated so it can be faked in tests.
abstract interface class NotificationGateway {
  Future<void> show({required int id, required String title, required String text, required String channelName});
}

/// Talks to `SaveNotifications` (Kotlin), registered by MainActivity and ShareActivity.
class PluginNotificationGateway implements NotificationGateway {
  const PluginNotificationGateway();

  static const MethodChannel _channel = MethodChannel('com.jujeme.nombra/notifications');

  @override
  Future<void> show({required int id, required String title, required String text, required String channelName}) async {
    try {
      await _channel.invokeMethod<void>('show', {'id': id, 'title': title, 'text': text, 'channelName': channelName});
    } on Object {
      // A missing notification must never break the save itself.
    }
  }
}
