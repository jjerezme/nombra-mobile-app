import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/share_payload.dart';

/// Talks to ShareActivity (Kotlin), which owns the Android intent that started the sheet.
class ShareChannel {
  const ShareChannel();

  static const MethodChannel _channel = MethodChannel('com.jujeme.nombra/share');

  Future<SharePayload> payload() async {
    final map = await _channel.invokeMapMethod<Object?, Object?>('payload');
    return map == null ? const SharePayload() : SharePayload.fromMap(map);
  }

  /// Finishes the activity, which closes the sheet.
  Future<void> close() => _channel.invokeMethod<void>('close');
}

final shareChannelProvider = Provider<ShareChannel>((ref) => const ShareChannel());

final sharePayloadProvider = FutureProvider<SharePayload>((ref) => ref.watch(shareChannelProvider).payload());
