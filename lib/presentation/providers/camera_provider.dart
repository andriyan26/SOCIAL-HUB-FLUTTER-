import 'dart:async';
import 'package:flutter/material.dart';

enum CameraBottomTab { kamera, buat, live }
enum CameraDurationMode { tenMin, sixtySec, fifteenSec, foto, teks }

class CameraProvider extends ChangeNotifier {
  CameraBottomTab _bottomTab = CameraBottomTab.kamera;
  CameraDurationMode _durationMode = CameraDurationMode.fifteenSec;
  bool _isRecording = false;
  int _recordedSeconds = 0;
  Timer? _recordingTimer;

  bool _isFrontCamera = true;
  bool _isFlashOn = false;
  bool _isGridOn = false;
  int _activeFilterIndex = 0;
  String _selectedSound = 'Tambah suara';

  CameraBottomTab get bottomTab => _bottomTab;
  CameraDurationMode get durationMode => _durationMode;
  bool get isRecording => _isRecording;
  int get recordedSeconds => _recordedSeconds;
  bool get isFrontCamera => _isFrontCamera;
  bool get isFlashOn => _isFlashOn;
  bool get isGridOn => _isGridOn;
  int get activeFilterIndex => _activeFilterIndex;
  String get selectedSound => _selectedSound;

  void setBottomTab(CameraBottomTab tab) {
    _bottomTab = tab;
    notifyListeners();
  }

  void setDurationMode(CameraDurationMode mode) {
    _durationMode = mode;
    notifyListeners();
  }

  void toggleCameraFacing() {
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  void toggleFlash() {
    _isFlashOn = !_isFlashOn;
    notifyListeners();
  }

  void toggleGrid() {
    _isGridOn = !_isGridOn;
    notifyListeners();
  }

  void setFilterIndex(int index) {
    _activeFilterIndex = index;
    notifyListeners();
  }

  void setSound(String sound) {
    _selectedSound = sound;
    notifyListeners();
  }

  void toggleRecording() {
    if (_isRecording) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void startRecording({VoidCallback? onComplete}) {
    _isRecording = true;
    _recordedSeconds = 0;
    notifyListeners();

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordedSeconds++;
      int maxLimit = _durationMode == CameraDurationMode.fifteenSec
          ? 15
          : (_durationMode == CameraDurationMode.sixtySec ? 60 : 600);
      if (_recordedSeconds >= maxLimit) {
        stopRecording();
        if (onComplete != null) {
          onComplete();
        }
      } else {
        notifyListeners();
      }
    });
  }

  void stopRecording() {
    _isRecording = false;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }
}

