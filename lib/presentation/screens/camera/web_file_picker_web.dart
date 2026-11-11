// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/media_store/web_media_store.dart';

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
        WebMediaStore.cacheSelectedVideoBlob(file);
        WebMediaStore.registerActiveBlobUrl(file.name, objectUrl);
        const defaultThumb = AppAssets.imgAndrianPoster;

        final video = html.VideoElement()
          ..src = objectUrl
          ..crossOrigin = 'anonymous'
          ..muted = true
          ..autoplay = true
          ..preload = 'auto';

        video.setAttribute('playsinline', 'true');
        video.setAttribute('webkit-playsinline', 'true');

        bool extracted = false;
        void takeSnapshot() {
          if (extracted) return;
          extracted = true;
          try {
            if (video.videoWidth > 0 && video.videoHeight > 0) {
              final w = video.videoWidth;
              final h = video.videoHeight;
              final canvas = html.CanvasElement(width: w, height: h);
              canvas.context2D.drawImage(video, 0, 0);
              final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
              final b64 = dataUrl.split(',').last;
              if (b64.length >= 7500) {
                onSelected(file.name, objectUrl, true, dataUrl);
                return;
              }
            }
            onSelected(file.name, objectUrl, true, defaultThumb);
          } catch (_) {
            onSelected(file.name, objectUrl, true, defaultThumb);
          }
        }

        video.onLoadedMetadata.listen((_) {
          try {
            video.currentTime = 0.5;
          } catch (_) {}
        });
        video.onCanPlay.listen((_) => takeSnapshot());
        video.onSeeked.listen((_) => takeSnapshot());
        // Fallback after 1500ms
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!extracted) {
            takeSnapshot();
          }
        });
      } else {
        // For images selected in media picker: convert to persistent Data URL as well
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((_) {
          final dataUrl = reader.result as String?;
          onSelected(file.name, dataUrl ?? objectUrl, false, dataUrl ?? objectUrl);
        });
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
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((_) {
        final rawDataUrl = reader.result as String?;
        if (rawDataUrl == null || rawDataUrl.isEmpty) {
          uploadInput.remove();
          return;
        }

        // Optimize and compress image using HTML5 Image + Canvas
        // Produces a crisp 512x512 JPEG Data URL that is completely persistent across page refreshes
        try {
          final img = html.ImageElement()..src = rawDataUrl;
          img.onLoad.listen((_) {
            const int maxDimension = 512;
            int width = img.naturalWidth;
            int height = img.naturalHeight;

            if (width <= 0 || height <= 0) {
              onSelected(file.name, rawDataUrl);
              return;
            }

            if (width > maxDimension || height > maxDimension) {
              if (width > height) {
                height = (height * maxDimension / width).round();
                width = maxDimension;
              } else {
                width = (width * maxDimension / height).round();
                height = maxDimension;
              }
            }

            final canvas = html.CanvasElement(width: width, height: height);
            final ctx = canvas.context2D;
            ctx.drawImageScaled(img, 0, 0, width, height);
            final optimizedDataUrl = canvas.toDataUrl('image/jpeg', 0.88);
            onSelected(file.name, optimizedDataUrl);
          });
          img.onError.listen((_) {
            onSelected(file.name, rawDataUrl);
          });
        } catch (_) {
          onSelected(file.name, rawDataUrl);
        }
        uploadInput.remove();
      });
    } else {
      uploadInput.remove();
    }
  });

  uploadInput.click();
}
