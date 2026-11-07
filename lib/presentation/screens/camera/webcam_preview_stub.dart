import 'package:flutter/material.dart';

class WebcamPreviewWidget extends StatelessWidget {
  final bool isFrontCamera;
  final bool isMirrored;

  const WebcamPreviewWidget({
    super.key,
    this.isFrontCamera = true,
    this.isMirrored = true,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

