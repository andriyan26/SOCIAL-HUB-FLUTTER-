import 'package:flutter/foundation.dart';
import 'audio_service_stub.dart'
    if (dart.library.html) 'audio_service_web.dart';

class AppAudioService {
  static final AppAudioService instance = AppAudioService._internal();
  AppAudioService._internal();

  final _platformAudio = PlatformAudioHelper();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stopMusic();
    } else {
      startMusic();
    }
  }

  void playShutterSound() {
    if (_isMuted) return;
    _platformAudio.playShutter();
  }

  void playPopSound() {
    if (_isMuted) return;
    _platformAudio.playPop();
  }

  void playChimeSound() {
    if (_isMuted) return;
    _platformAudio.playChime();
  }

  void playTimerBeep(int second) {
    if (_isMuted) return;
    _platformAudio.playBeep(second);
  }

  void startMusic() {
    if (_isMuted) return;
    _platformAudio.startAmbientMusic();
  }

  void stopMusic() {
    _platformAudio.stopAmbientMusic();
  }
}
