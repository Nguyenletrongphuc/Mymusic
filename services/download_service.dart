import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  /// Downloads audio from the backend and saves it to the device's MediaStore.
  ///
  /// - `url` is the source URL passed to your backend download endpoint.
  /// - `onProgress` is an optional callback with values in range [0.0, 1.0].
  ///
  /// Throws an [Exception] when permission is denied or the download fails.
  static Future<void> downloadAudio(
    String url, {
    String? fileName,
    void Function(double progress)? onProgress,
  }) async {
    // Request storage/media permission on Android
    if (Platform.isAndroid) {
      // Android 13+ may require READ_MEDIA_AUDIO, older devices use storage/manageExternalStorage
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        // try manageExternalStorage (for Android 11+)
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          // try READ_MEDIA_AUDIO for Android 13+
          final audioStatus = await Permission.audio.request();
          if (!audioStatus.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }
    }

    final uri = Uri.parse("http://192.168.1.2:8000/api/download/audio");

    final request = http.Request("POST", uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = '{"url": "$url"}';

    final response = await request.send();

    // Prepare a temporary file to stream into (avoids holding the whole file in memory)
    final tempDir = await getTemporaryDirectory();
    final safeFileName = (fileName?.trim().isNotEmpty == true)
        ? fileName!.trim()
        : 'download_${DateTime.now().millisecondsSinceEpoch}.mp3';
    // Ensure the temp file has .mp3 extension so MIME type resolves to audio/mpeg
    final tempPath = '${tempDir.path}/${safeFileName.endsWith('.mp3') ? safeFileName : '$safeFileName.mp3'}';
    final tempFile = File(tempPath);
    final sink = tempFile.openWrite();

    try {
      if (response.statusCode != 200) {
        // consume response body to include in error message if available
        final errorBytes = await response.stream.toBytes();
        final errorBody = utf8.decode(errorBytes, allowMalformed: true);
        throw Exception('Download failed: ${response.statusCode} - $errorBody');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          try {
            onProgress(receivedBytes / totalBytes);
          } catch (e, s) {
            // ensure progress callbacks don't crash the download
            debugPrint('Progress callback error: $e');
            debugPrint(s.toString());
          }
        }
      }

      await sink.close();

      // Save the temp file via MediaStore (pass the temp file path; required params: tempFilePath & dirName)
      final mediaStore = MediaStore();

      await mediaStore.saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.audio,
        dirName: DirName.music,
        relativePath: "Music",
      );

      // final progress = 1.0
      if (onProgress != null) {
        try {
          onProgress(1.0);
        } catch (_) {}
      }
    } catch (e, stack) {
      debugPrint('DOWNLOAD ERROR: $e');
      debugPrint(stack.toString());
      rethrow;
    } finally {
      // cleanup temp file
      try {
        await sink.close();
      } catch (_) {}
      try {
        if (await tempFile.exists()) await tempFile.delete();
      } catch (_) {}
    }
  }

  /// Backwards-compatible wrapper without progress callback
  static Future<void> downloadAudioSimple(String url) => downloadAudio(url);
}

