import 'package:flutter/material.dart';

enum ViewportMode {
  iphone13,
  tablet,
  desktopFull,
}

class UiFrameProvider extends ChangeNotifier {
  ViewportMode _viewportMode = ViewportMode.iphone13;
  int _replayKey = 0;

  ViewportMode get viewportMode => _viewportMode;
  int get replayKey => _replayKey;

  void setViewportMode(ViewportMode mode) {
    if (_viewportMode == mode) return;
    _viewportMode = mode;
    notifyListeners();
  }

  void triggerReplay() {
    _replayKey++;
    notifyListeners();
  }
}
