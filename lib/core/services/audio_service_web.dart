// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

class PlatformAudioHelper {
  html.AudioContext? _audioContext;
  Timer? _musicTimer;
  int _noteIndex = 0;

  html.AudioContext _getContext() {
    _audioContext ??= html.AudioContext();
    if (_audioContext!.state == 'suspended') {
      _audioContext!.resume();
    }
    return _audioContext!;
  }

  void playTone(double frequency, double durationSeconds, {String type = 'sine', double gain = 0.15}) {
    try {
      final ctx = _getContext();
      final osc = ctx.createOscillator();
      final gainNode = ctx.createGain();

      osc.type = type;
      osc.frequency?.value = frequency;

      final now = ctx.currentTime ?? 0;
      gainNode.gain?.setValueAtTime(gain, now);
      gainNode.gain?.exponentialRampToValueAtTime(0.001, now + durationSeconds);

      osc.connect(gainNode);
      gainNode.connect(ctx.destination!);

      osc.start(now);
      osc.stop(now + durationSeconds);
    } catch (_) {
      // Audio autoplay policy fallback
    }
  }

  void playShutter() {
    try {
      final ctx = _getContext();
      final now = ctx.currentTime ?? 0;
      // Click 1 (Mirror flip)
      playTone(180, 0.05, type: 'triangle', gain: 0.3);
      // Click 2 (Shutter snap)
      Future.delayed(const Duration(milliseconds: 60), () {
        playTone(320, 0.08, type: 'square', gain: 0.25);
      });
    } catch (_) {}
  }

  void playPop() {
    try {
      final ctx = _getContext();
      final osc = ctx.createOscillator();
      final gainNode = ctx.createGain();

      final now = ctx.currentTime ?? 0;
      osc.type = 'sine';
      osc.frequency?.setValueAtTime(500, now);
      osc.frequency?.exponentialRampToValueAtTime(950, now + 0.12);

      gainNode.gain?.setValueAtTime(0.2, now);
      gainNode.gain?.exponentialRampToValueAtTime(0.001, now + 0.12);

      osc.connect(gainNode);
      gainNode.connect(ctx.destination!);

      osc.start(now);
      osc.stop(now + 0.12);
    } catch (_) {}
  }

  void playChime() {
    playTone(659.25, 0.15, type: 'sine', gain: 0.2); // E5
    Future.delayed(const Duration(milliseconds: 120), () {
      playTone(880.0, 0.25, type: 'sine', gain: 0.2); // A5
    });
  }

  void playBeep(int count) {
    if (count == 0) {
      playTone(880.0, 0.3, type: 'sine', gain: 0.3); // High beep on zero
    } else {
      playTone(440.0, 0.15, type: 'sine', gain: 0.2); // Low beep on countdown
    }
  }

  void startAmbientMusic() {
    stopAmbientMusic();
    // Looping soft lo-fi melody in pentatonic scale
    final notes = [261.63, 329.63, 392.00, 440.00, 523.25, 440.00, 392.00, 329.63];
    _noteIndex = 0;
    _musicTimer = Timer.periodic(const Duration(milliseconds: 320), (timer) {
      playTone(notes[_noteIndex % notes.length], 0.22, type: 'sine', gain: 0.08);
      _noteIndex++;
    });
  }

  void stopAmbientMusic() {
    _musicTimer?.cancel();
    _musicTimer = null;
  }
}
