import 'package:flutter/services.dart';

class AppAudioService {
  static final AppAudioService instance = AppAudioService._internal();
  AppAudioService._internal();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (!_isMuted) {
      playChimeSound();
    }
  }

  void playShutterSound() {
    if (_isMuted) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playPopSound() {
    if (_isMuted) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playChimeSound() {
    if (_isMuted) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playTimerBeep(int second) {
    if (_isMuted) return;
    SystemSound.play(SystemSoundType.click);
  }

  void startMusic() {
    // Sound active
  }

  void stopMusic() {
    // Sound stopped
  }
}
