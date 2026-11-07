import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Neon "SH" (Social Hub) Emblem Painter
/// Precisely matching the aesthetic of the concept video with dual-color
/// Electric Cyan (#00F2FE) & Hot Neon Magenta (#FE2C55) glows.
class SHLogoPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  SHLogoPainter({
    required this.progress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cx = w * 0.5;
    final cy = h * 0.5;

    // Glowing Neon Paints
    final magentaGlow = Paint()
      ..color = const Color(0xFFFE2C55).withOpacity(0.60 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * glowIntensity
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowIntensity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cyanGlow = Paint()
      ..color = const Color(0xFF00F2FE).withOpacity(0.60 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * glowIntensity
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowIntensity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final magentaCore = Paint()
      ..color = const Color(0xFFFF2A6D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cyanCore = Paint()
      ..color = const Color(0xFF00F2FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final whiteCore = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // --- Letter "S" (Left) ---
    final sLeft = cx - w * 0.42;
    final sRight = cx - w * 0.06;
    final sTop = cy - h * 0.35;
    final sMidY = cy;
    final sBottom = cy + h * 0.35;

    final pathS = Path()
      ..moveTo(sRight, sTop + h * 0.12)
      ..cubicTo(sRight, sTop, sLeft + w * 0.08, sTop, sLeft + w * 0.08, sTop + h * 0.16)
      ..cubicTo(sLeft + w * 0.08, sMidY, sRight, sMidY - h * 0.06, sRight, sMidY + h * 0.14)
      ..cubicTo(sRight, sBottom, sLeft, sBottom, sLeft, sBottom - h * 0.14)
      ..lineTo(sLeft + w * 0.12, sBottom - h * 0.22); // arrow tail

    // --- Letter "H" (Right) ---
    final hLeft = cx + w * 0.06;
    final hRight = cx + w * 0.42;
    final hTop = cy - h * 0.35;
    final hBottom = cy + h * 0.35;

    final pathH = Path()
      // Left vertical pillar
      ..moveTo(hLeft, hBottom)
      ..lineTo(hLeft, hTop)
      // Crossbar
      ..moveTo(hLeft, cy)
      ..lineTo(hRight, cy)
      // Right vertical pillar
      ..moveTo(hRight, hBottom)
      ..lineTo(hRight, hTop);

    // 1. Magenta 3D Shadow Layer (Shifted right & down by +3px)
    canvas.save();
    canvas.translate(3.5, 3.5);
    canvas.drawPath(pathS, magentaGlow);
    canvas.drawPath(pathH, magentaGlow);
    canvas.drawPath(pathS, magentaCore);
    canvas.drawPath(pathH, magentaCore);
    canvas.restore();

    // 2. Cyan Primary Glow & Core (Shifted left & up by -2px)
    canvas.save();
    canvas.translate(-2.0, -2.0);
    canvas.drawPath(pathS, cyanGlow);
    canvas.drawPath(pathH, cyanGlow);
    canvas.drawPath(pathS, cyanCore);
    canvas.drawPath(pathH, cyanCore);
    canvas.restore();

    // 3. Crisp White Electric Center Wire
    canvas.drawPath(pathS, whiteCore);
    canvas.drawPath(pathH, whiteCore);

    // 4. Cyan Arrowhead on the tail of "S"
    final arrowTip = Offset(sLeft + w * 0.12, sBottom - h * 0.22);
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
  bool shouldRepaint(covariant SHLogoPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glowIntensity != glowIntensity;
  }
}
