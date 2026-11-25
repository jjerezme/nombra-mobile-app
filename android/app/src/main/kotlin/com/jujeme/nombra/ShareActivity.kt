package com.jujeme.nombra

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

/**
 * Receives "share" intents (a file, several files, or text with a link) and shows the Flutter
 * "Save with Nombra" sheet (Dart entrypoint `shareMain`) over a transparent window.
 *
 * Shared files are copied to the app's cache so Dart can read them by path.
 */
class ShareActivity : FlutterActivity() {
    /** The folder with this share's copies; removed when the activity ends, saved or not. */
    private var shareDir: File? = null

    override fun getDartEntrypointFunctionName(): String = "shareMain"

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        SaveNotifications.register(flutterEngine, this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "payload" -> readPayloadAsync(result)
                // Hides the sheet but keeps the activity (and its Dart code) alive, so the saves can finish.
                "minimize" -> {
                    moveTaskToBack(true)
                    result.success(null)
                }
                "close" -> {
                    finish()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun readPayloadAsync(result: MethodChannel.Result) {
        val shareIntent = intent
        Thread {
            val payload: Map<String, Any?> = try {
                readPayload(shareIntent)
            } catch (e: Exception) {
                mapOf("text" to null, "files" to emptyList<Map<String, Any?>>())
            }
            runOnUiThread { result.success(payload) }
        }.start()
    }

    private fun readPayload(shareIntent: Intent): Map<String, Any?> {
        val shareRoot = File(cacheDir, "share")
        deleteOldShares(shareRoot)
        val text = shareIntent.getStringExtra(Intent.EXTRA_TEXT)
        val uris = streamUris(shareIntent)
        val dir = File(shareRoot, UUID.randomUUID().toString()).apply { mkdirs() }
        shareDir = dir
        val files = uris.take(MAX_FILES).mapNotNull { copyToCache(it, dir) }
        return mapOf("text" to text, "files" to files)
    }

    private fun streamUris(shareIntent: Intent): List<Uri> = when (shareIntent.action) {
        Intent.ACTION_SEND -> listOfNotNull(streamUri(shareIntent))
        Intent.ACTION_SEND_MULTIPLE -> streamUriList(shareIntent)
        else -> emptyList()
    }

    @Suppress("DEPRECATION")
    private fun streamUri(shareIntent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= 33) {
            shareIntent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            shareIntent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        }

    @Suppress("DEPRECATION")
    private fun streamUriList(shareIntent: Intent): List<Uri> {
        val list: List<Uri>? = if (Build.VERSION.SDK_INT >= 33) {
            shareIntent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            shareIntent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
        }
        return list ?: emptyList()
    }

    private fun copyToCache(uri: Uri, dir: File): Map<String, Any?>? {
        var displayName: String? = null
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) displayName = cursor.getString(index)
            }
        }
        val mimeType = contentResolver.getType(uri)
        val cleanName = safeName(displayName ?: uri.lastPathSegment)
        val fileName = withExtensionFor(cleanName, mimeType)
        val target = File(dir, fileName)
        try {
            val input = contentResolver.openInputStream(uri) ?: return null
            val isComplete = input.use { source -> target.outputStream().use { sink -> copyWithLimit(source, sink) } }
            if (!isComplete) {
                target.delete()
                return null
            }
        } catch (e: Exception) {
            target.delete()
            return null
        }
        return mapOf(
            "path" to target.absolutePath,
            "name" to fileName,
            "mimeType" to mimeType,
            "size" to target.length(),
        )
    }

    /** A name that cannot point outside the folder: no separators or reserved characters, never empty or only dots. */
    private fun safeName(raw: String?): String {
        val clean = (raw ?: "").replace(Regex("[\\\\/:*?\"<>|\\u0000-\\u001F]"), "_").trim().take(MAX_NAME_LENGTH)
        return if (clean.isEmpty() || clean.all { it == '.' }) "file" else clean
    }

    /** Copies [source] to [sink]; returns false (and stops) when the file is larger than [MAX_FILE_BYTES]. */
    private fun copyWithLimit(source: InputStream, sink: OutputStream): Boolean {
        val buffer = ByteArray(BUFFER_SIZE)
        var total = 0L
        while (true) {
            val read = source.read(buffer)
            if (read < 0) return true
            total += read
            if (total > MAX_FILE_BYTES) return false
            sink.write(buffer, 0, read)
        }
    }

    /**
     * Some apps share files with a bare id as name (no extension). The extension is then taken from the MIME type,
     * so the file keeps its type (`image/jpeg` -> `.jpg`). A name that already has an extension is left alone.
     */
    private fun withExtensionFor(name: String, mimeType: String?): String {
        val hasExtension = name.substringAfterLast('.', "").let { it.isNotEmpty() && name.length > it.length + 1 }
        if (hasExtension || mimeType == null) return name
        val extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType) ?: return name
        return "$name.$extension"
    }

    /** Copies that were never saved (the user cancelled) are removed after a day. */
    private fun deleteOldShares(shareRoot: File) {
        val limit = System.currentTimeMillis() - ONE_DAY_MS
        shareRoot.listFiles()?.filter { it.lastModified() < limit }?.forEach { it.deleteRecursively() }
    }

    override fun onDestroy() {
        if (isFinishing) shareDir?.deleteRecursively()
        super.onDestroy()
    }

    private companion object {
        const val CHANNEL = "com.jujeme.nombra/share"
        const val ONE_DAY_MS = 24L * 60 * 60 * 1000
        const val MAX_FILES = 50
        const val MAX_FILE_BYTES = 2L * 1024 * 1024 * 1024
        const val MAX_NAME_LENGTH = 200
        const val BUFFER_SIZE = 64 * 1024
    }
}
