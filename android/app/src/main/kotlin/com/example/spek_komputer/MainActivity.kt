package com.example.spek_komputer

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channel = "spek_komputer/saver"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "savePdfToDownloads" -> {
                        val name = call.argument<String>("name") ?: "document.pdf"
                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null) {
                            result.error("no_data", "Data bytes tidak tersedia", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val path = saveFile(name, bytes, "application/pdf")
                            result.success(path)
                        } catch (e: Exception) {
                            result.error("save_failed", e.message, null)
                        }
                    }
                    "saveFileToDownloads" -> {
                        val name = call.argument<String>("name") ?: "document"
                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null) {
                            result.error("no_data", "Data bytes tidak tersedia", null)
                            return@setMethodCallHandler
                        }
                        val mime = call.argument<String>("mimeType")
                            ?: "application/octet-stream"
                        try {
                            val path = saveFile(name, bytes, mime)
                            result.success(path)
                        } catch (e: Exception) {
                            result.error("save_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Simpan file ke folder Download publik menggunakan MediaStore. */
    private fun saveFile(name: String, bytes: ByteArray, mimeType: String): String {
        val safeName = name
            .replace(Regex("[^A-Za-z0-9._-]"), "_")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, safeName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS
                )
            }
            val uri = contentResolver.insert(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                values
            ) ?: throw Exception("Gagal membuat file di folder Download")
            contentResolver.openOutputStream(uri)?.use { stream ->
                stream.write(bytes)
            } ?: throw Exception("Gagal menulis file")
            return "Download/${safeName}"
        } else {
            val dir = File(
                Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                ),
                ""
            )
            if (!dir.exists()) dir.mkdirs()
            val file = File(dir, safeName)
            FileOutputStream(file).use { it.write(bytes) }
            return file.absolutePath
        }
    }
}