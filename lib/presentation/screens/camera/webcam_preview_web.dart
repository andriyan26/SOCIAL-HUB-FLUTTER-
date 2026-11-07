// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebcamPreviewWidget extends StatefulWidget {
  final bool isFrontCamera;
  final bool isMirrored;

  const WebcamPreviewWidget({
    super.key,
    this.isFrontCamera = true,
    this.isMirrored = true,
  });

  @override
  State<WebcamPreviewWidget> createState() => _WebcamPreviewWidgetState();
}

class _WebcamPreviewWidgetState extends State<WebcamPreviewWidget> {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  late String _viewType;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
    _initWebcam();
  }

  Future<void> _initWebcam() async {
    try {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = widget.isMirrored ? 'scaleX(-1)' : 'none';

      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices != null) {
        final stream = await mediaDevices.getUserMedia({
          'video': {
            'facingMode': widget.isFrontCamera ? 'user' : 'environment',
          },
          'audio': false,
        });

        _mediaStream = stream;
        _videoElement!.srcObject = stream;
        _videoElement!.play();
        if (mounted) {
          setState(() {
            _hasPermission = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Webcam initialization notice (running fallback viewfinder): $e');
      if (mounted) {
        setState(() {
          _hasPermission = false;
        });
      }
    }

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _videoElement ?? html.DivElement(),
    );
  }

  @override
  void didUpdateWidget(WebcamPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isMirrored != widget.isMirrored) {
      _videoElement?.style.transform = widget.isMirrored ? 'scaleX(-1)' : 'none';
    }
    if (oldWidget.isFrontCamera != widget.isFrontCamera) {
      _mediaStream?.getTracks().forEach((track) => track.stop());
      _initWebcam();
    }
  }

  @override
  void dispose() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _videoElement?.pause();
    _videoElement?.srcObject = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission) {
      return HtmlElementView(viewType: _viewType);
    }
    return const SizedBox.shrink();
  }
}

