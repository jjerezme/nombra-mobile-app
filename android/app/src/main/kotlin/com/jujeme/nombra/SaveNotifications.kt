package com.jujeme.nombra

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Channel `com.jujeme.nombra/notifications`: shows the "saved" / "could not save" notification once a file has been
 * named and moved to its folder. The progress notification of a download belongs to the downloader plugin.
 *
 * Registered by both activities, so it works whether the save started from the app or from the share sheet.
 */
object SaveNotifications {
    private const val CHANNEL = "com.jujeme.nombra/notifications"
    private const val CHANNEL_ID = "nombra_saved"

    fun register(engine: FlutterEngine, context: Context) {
        val appContext = context.applicationContext
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "show" -> {
                    show(
                        appContext,
                        id = call.argument<Int>("id") ?: 0,
                        title = call.argument<String>("title") ?: "",
                        text = call.argument<String>("text") ?: "",
                        channelName = call.argument<String>("channelName") ?: "Nombra",
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun show(context: Context, id: Int, title: String, text: String, channelName: String) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_DEFAULT),
        )
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val tap = open?.let {
            PendingIntent.getActivity(
                context,
                id,
                it.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP) },
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
        }
        val notification = Notification.Builder(context, CHANNEL_ID)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(text)
            .setStyle(Notification.BigTextStyle().bigText(text))
            .setAutoCancel(true)
            .setContentIntent(tap)
            .build()
        // Silently ignored by Android when the notification permission is not granted.
        manager.notify(id, notification)
    }
}
