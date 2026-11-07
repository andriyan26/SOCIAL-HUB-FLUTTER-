// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pickMediaFileNative({
  required Function(String fileName, String? objectUrl, bool isVideo) onSelected,
}) {
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'video/*,image/*'
    ..multiple = false;

  uploadInput.click();

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
      onSelected(file.name, objectUrl, isVideo);
    }
  });
}

void pickImageFileNative({
  required Function(String fileName, String? pathOrUrl) onSelected,
}) {
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;

  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((_) {
        final result = reader.result as String?;
        final url = (result != null && result.isNotEmpty)
            ? result
            : html.Url.createObjectUrl(file);
        onSelected(file.name, url);
      });
    }
  });
}
