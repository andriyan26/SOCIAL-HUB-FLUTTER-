// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<String?> uploadMediaToHostingerServer(dynamic fileOrBlob, {required bool isVideo, String? customName}) async {
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
      
      request.onLoad.listen((_) {
        if (request.status == 200 || request.status == 201) {
          try {
            final json = jsonDecode(request.responseText ?? '{}');
            if (json['success'] == true && json['url'] != null) {
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
      return await completer.future.timeout(const Duration(seconds: 45), onTimeout: () => null);
    } else if (fileOrBlob is String && fileOrBlob.startsWith('data:')) {
      final completer = Completer<String?>();
      final request = html.HttpRequest();
      request.open('POST', uploadUrl);
      request.setRequestHeader('Content-Type', 'application/json');

      request.onLoad.listen((_) {
        if (request.status == 200 || request.status == 201) {
          try {
            final json = jsonDecode(request.responseText ?? '{}');
            if (json['success'] == true && json['url'] != null) {
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

      return await completer.future.timeout(const Duration(seconds: 30), onTimeout: () => null);
    }
  } catch (e) {
    debugPrint('Hostinger upload error: $e');
  }
  return null;
}
