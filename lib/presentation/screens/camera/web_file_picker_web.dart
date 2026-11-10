// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pickMediaFileNative({
  required Function(String fileName, String? objectUrl, bool isVideo, String? thumbnailUrl) onSelected,
}) {
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'video/*,image/*'
    ..multiple = false
    ..style.display = 'none';

  html.document.body?.children.add(uploadInput);

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final lowerName = file.name.toLowerCase();
      final isVideo = file.type.startsWith('video/') ||
          lowerName.endsWith('.mp4') ||
          lowerName.endsWith('.mov') ||
          lowerName.endsWith('.webm') ||
          lowerName.endsWith('.avi');

      final objectUrl = html.Url.createObjectUrl(file);

      if (isVideo) {
        final video = html.VideoElement()
          ..src = objectUrl
          ..crossOrigin = 'anonymous'
          ..muted = true
          ..preload = 'auto';

        bool extracted = false;
        void takeSnapshot() {
          if (extracted) return;
          extracted = true;
          try {
            final w = video.videoWidth > 0 ? video.videoWidth : 480;
            final h = video.videoHeight > 0 ? video.videoHeight : 854;
            final canvas = html.CanvasElement(width: w, height: h);
            canvas.context2D.drawImage(video, 0, 0);
            final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
            onSelected(file.name, objectUrl, true, dataUrl);
          } catch (_) {
            onSelected(file.name, objectUrl, true, null);
          }
        }

        video.onLoadedMetadata.listen((_) {
          video.currentTime = 0.5;
        });
        video.onSeeked.listen((_) => takeSnapshot());
        // Fallback after 600ms if seeking or metadata takes longer
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!extracted) {
            takeSnapshot();
          }
        });
      } else {
        onSelected(file.name, objectUrl, false, objectUrl);
      }
      uploadInput.remove();
    } else {
      uploadInput.remove();
    }
  });

  uploadInput.click();
}

void pickImageFileNative({
  required Function(String fileName, String? pathOrUrl) onSelected,
}) {
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false
    ..style.display = 'none';

  html.document.body?.children.add(uploadInput);

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final objectUrl = html.Url.createObjectUrl(file);
      onSelected(file.name, objectUrl);
      uploadInput.remove();
    } else {
      uploadInput.remove();
    }
  });

  uploadInput.click();
}
