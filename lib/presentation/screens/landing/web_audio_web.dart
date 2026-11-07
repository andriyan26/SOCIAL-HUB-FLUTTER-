// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

html.AudioElement? _splashAudio;

void playSplashAudioNative() {
  try {
    _splashAudio?.pause();
    _splashAudio = html.AudioElement('assets/audio/splash_sound.mp3')
      ..volume = 0.85;

    _splashAudio?.play().catchError((_) {
      // Autoplay fallback in case browser prefers nested asset path
      try {
        _splashAudio = html.AudioElement('assets/assets/audio/splash_sound.mp3')
          ..volume = 0.85;
        _splashAudio?.play().catchError((_) {});
      } catch (_) {}
    });
  } catch (_) {}
}

void stopSplashAudioNative() {
  try {
    _splashAudio?.pause();
    _splashAudio = null;
  } catch (_) {}
}

