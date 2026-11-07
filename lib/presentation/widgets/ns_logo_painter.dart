import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Painter that precisely recreates the 3D Neon "NS" (NoShot) emblem
/// from the concept video with dual-color electric cyan & hot magenta glows.
class NSLogoPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  NSLogoPainter({
    required this.progress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Center offset
    final cx = w * 0.5;
    final cy = h * 0.5;

    // Outer Glow / Blur Paint (Magenta)
    final magentaGlow = Paint()
      ..color = const Color(0xFFFE2C55).withOpacity(0.55 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * glowIntensity
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowIntensity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer Glow / Blur Paint (Cyan)
    final cyanGlow = Paint()
      ..color = const Color(0xFF00F2FE).withOpacity(0.55 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * glowIntensity
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowIntensity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Core Solid Strokes
    final magentaCore = Paint()
      ..color = const Color(0xFFFF2A6D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cyanCore = Paint()
      ..color = const Color(0xFF05D9E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final whiteCore = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw Letter "N"
    // Coordinates relative to center
    final nLeft = cx - w * 0.38;
    final nRight = cx - w * 0.04;
    final nTop = cy - h * 0.35;
    final nBottom = cy + h * 0.35;

    final pathN = Path()
      ..moveTo(nLeft, nBottom)
      ..lineTo(nLeft, nTop)
      ..lineTo(nRight, nBottom)
      ..lineTo(nRight, nTop);

    // Draw Letter "S" with upward arrow tail
    final sLeft = cx + w * 0.02;
    final sRight = cx + w * 0.38;
    final sTop = cy - h * 0.35;
    final sMidY = cy;
    final sBottom = cy + h * 0.35;

    final pathS = Path()
      // Top curve of S
      ..moveTo(sRight, sTop + h * 0.12)
      ..cubicTo(sRight, sTop, sLeft + w * 0.08, sTop, sLeft + w * 0.08, sTop + h * 0.16)
      ..cubicTo(sLeft + w * 0.08, sMidY, sRight, sMidY - h * 0.06, sRight, sMidY + h * 0.14)
      ..cubicTo(sRight, sBottom, sLeft, sBottom, sLeft, sBottom - h * 0.14)
      // Arrow styling at the end of S pointing up-right
      ..lineTo(sLeft + w * 0.10, sBottom - h * 0.22);

    // Shadow shift for 3D effect: Magenta shifted slightly right/down, Cyan shifted left/up
    canvas.save();
    canvas.translate(3.0, 3.0);
    canvas.drawPath(pathN, magentaGlow);
    canvas.drawPath(pathS, magentaGlow);
    canvas.drawPath(pathN, magentaCore);
    canvas.drawPath(pathS, magentaCore);
    canvas.restore();

    canvas.save();
    canvas.translate(-2.0, -2.0);
    canvas.drawPath(pathN, cyanGlow);
    canvas.drawPath(pathS, cyanGlow);
    canvas.drawPath(pathN, cyanCore);
    canvas.drawPath(pathS, cyanCore);
    canvas.restore();

    // White electric highlight in the core
    canvas.drawPath(pathN, whiteCore);
    canvas.drawPath(pathS, whiteCore);

    // Arrowhead on the S tail
    final arrowTip = Offset(sLeft + w * 0.10, sBottom - h * 0.22);
    final arrowPaint = Paint()
      ..color = const Color(0xFF00F2FE)
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTip.dx - 10, arrowTip.dy + 3)
      ..lineTo(arrowTip.dx - 3, arrowTip.dy + 10)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant NSLogoPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glowIntensity != glowIntensity;
  }
}

