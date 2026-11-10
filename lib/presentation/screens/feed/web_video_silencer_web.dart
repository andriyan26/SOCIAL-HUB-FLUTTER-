// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void silenceBackgroundWebVideos() {
  try {
    final videos = html.document.querySelectorAll('video');
    for (final v in videos) {
      if (v is html.VideoElement) {
        try {
          v.volume = 0.0;
          v.pause();
        } catch (_) {}
      }
    }
  } catch (_) {}
}

