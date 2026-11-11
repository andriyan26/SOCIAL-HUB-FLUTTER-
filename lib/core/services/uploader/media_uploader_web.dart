// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<String?> uploadMediaToHostingerServer(
  dynamic fileOrBlob, {
  required bool isVideo,
  String? customName,
  void Function(double progress)? onProgress,
}) async {
  try {
    final origin = html.window.location.origin;
    if (origin.contains('github.io') || !origin.startsWith('http')) {
      return null;
    }

    final uploadUrl = '$origin/api/upload.php';

    if (fileOrBlob is html.Blob) {
      final formData = html.FormData();
      final filename = customName ?? (isVideo ? 'video_${DateTime.now().millisecondsSinceEpoch}.mp4' : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      formData.appendBlob('file', fileOrBlob, filename);

      final completer = Completer<String?>();
      final request = html.HttpRequest();
      request.open('POST', uploadUrl);

      // Real-time upload progress event
      request.upload.onProgress.listen((e) {
        final total = e.total;
        final loaded = e.loaded;
        if (e.lengthComputable == true && total != null && total > 0 && loaded != null) {
          final p = loaded / total;
          if (onProgress != null) {
            onProgress(p.clamp(0.0, 1.0));
          }
        }
      });
      
      request.onLoad.listen((_) {
        if (request.status == 200 || request.status == 201) {
          try {
            final json = jsonDecode(request.responseText ?? '{}');
            if (json['success'] == true && json['url'] != null) {
              if (onProgress != null) onProgress(1.0);
              completer.complete(json['url'].toString());
              return;
            }
          } catch (_) {}
        }
        completer.complete(null);
      });

      request.onError.listen((_) {
        completer.complete(null);
      });

      request.send(formData);
      return await completer.future.timeout(const Duration(seconds: 180), onTimeout: () => null);
    } else if (fileOrBlob is String && fileOrBlob.startsWith('data:')) {
      final completer = Completer<String?>();
      final request = html.HttpRequest();
      request.open('POST', uploadUrl);
      request.setRequestHeader('Content-Type', 'application/json');

      request.upload.onProgress.listen((e) {
        final total = e.total;
        final loaded = e.loaded;
        if (e.lengthComputable == true && total != null && total > 0 && loaded != null) {
          final p = loaded / total;
          if (onProgress != null) {
            onProgress(p.clamp(0.0, 1.0));
          }
        }
      });

      request.onLoad.listen((_) {
        if (request.status == 200 || request.status == 201) {
          try {
            final json = jsonDecode(request.responseText ?? '{}');
            if (json['success'] == true && json['url'] != null) {
              if (onProgress != null) onProgress(1.0);
              completer.complete(json['url'].toString());
              return;
            }
          } catch (_) {}
        }
        completer.complete(null);
      });

      request.onError.listen((_) => completer.complete(null));
      request.send(jsonEncode({
        'data': fileOrBlob,
        'is_video': isVideo,
      }));

      return await completer.future.timeout(const Duration(seconds: 60), onTimeout: () => null);
    }
  } catch (e) {
    debugPrint('Hostinger upload error: $e');
  }
  return null;
}
