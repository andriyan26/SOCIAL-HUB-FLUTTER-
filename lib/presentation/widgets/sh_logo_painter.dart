import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// 3D Neon "SH" (Social Hub) Emblem Painter
/// Accurately matches the video concept animation:
/// 1. Energy sparks trace the neon contour paths of "S" (Cyan) and "H" (Magenta).
/// 2. Flash explosion transitions into bold, heavyweight solid white glyphs with
///    vibrant Cyan (#00F2FE) and Hot Magenta (#FE2C55) 3D chromatic aberration shadows.
/// 3. Dynamic upward arrow / chevron accent with chromatic pulse and glitch offsets.
class SHLogoPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;
  final double? traceProgress;
  final double? fillProgress;
  final double flashIntensity;
  final Offset glitchOffset;

  SHLogoPainter({
    required this.progress,
    required this.glowIntensity,
    this.traceProgress,
    this.fillProgress,
    this.flashIntensity = 0.0,
    this.glitchOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Resolve active stage values
    final effectiveTrace = traceProgress ?? (progress < 1.0 ? progress : 1.0);
    final effectiveFill = fillProgress ?? (progress >= 1.0 ? 1.0 : 0.0);

    // Normalize coordinates so the logo scales cleanly to any container size (e.g. 52x44 or 220x150)
    final scaleX = w / 220.0;
    final scaleY = h / 150.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Bounding reference: (220, 150)
    final pathS = _buildPathS();
    final pathH = _buildPathH();
    final pathArrow = _buildPathArrow();

    // -------------------------------------------------------------
    // STAGE 1: STROKE TRACING WITH GLOWING ENERGY SPARK HEADS
    // -------------------------------------------------------------
    if (effectiveTrace < 1.0) {
      _paintStrokeTracing(canvas, pathS, pathH, effectiveTrace);
    }

    // -------------------------------------------------------------
    // STAGE 2: SOLID BOLD CHROMATIC GLYPHS WITH IMPACT FLASH
    // -------------------------------------------------------------
    if (effectiveFill > 0.0) {
      _paintSolidChromatic(canvas, pathS, pathH, pathArrow, effectiveFill);
    }

    // -------------------------------------------------------------
    // STAGE 3: BLINDING WHITE IMPACT FLASH BLOOM
    // -------------------------------------------------------------
    if (flashIntensity > 0.0) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(0.65 * flashIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawCircle(const Offset(110, 80), 90 * flashIntensity, flashPaint);

      final flashCore = Paint()
        ..color = Colors.white.withOpacity(0.90 * flashIntensity);
      canvas.drawCircle(const Offset(110, 80), 30 * flashIntensity, flashCore);
    }

    canvas.restore();
  }

  Path _buildPathS() {
    // Elegant, stylized geometric cyber "S"
    return Path()
      ..moveTo(96, 36)
      ..cubicTo(96, 26, 42, 26, 36, 40)
      ..cubicTo(30, 54, 30, 72, 58, 76)
      ..lineTo(76, 79)
      ..cubicTo(98, 83, 102, 102, 98, 116)
      ..cubicTo(92, 134, 46, 136, 34, 126)
      ..lineTo(56, 106);
  }

  Path _buildPathH() {
    // Stylized geometric cyber "H"
    return Path()
      // Left vertical pillar
      ..moveTo(130, 26)
      ..lineTo(130, 134)
      // Crossbar
      ..moveTo(130, 80)
      ..lineTo(186, 80)
      // Right vertical pillar
      ..moveTo(186, 134)
      ..lineTo(186, 26);
  }

  Path _buildPathArrow() {
    // Energetic diagonal arrow cutting up-right
    return Path()
      ..moveTo(48, 116)
      ..lineTo(104, 82)
      ..lineTo(94, 80)
      ..lineTo(112, 74)
      ..lineTo(108, 92)
      ..lineTo(102, 85)
      ..lineTo(52, 122)
      ..close();
  }

  void _paintStrokeTracing(Canvas canvas, Path pathS, Path pathH, double trace) {
    final metricsS = pathS.computeMetrics().toList();
    final metricsH = pathH.computeMetrics().toList();

    // 1. Trace Path S (Electric Cyan)
    for (final metric in metricsS) {
      final len = metric.length * trace;
      if (len <= 0) continue;
      final extracted = metric.extractPath(0.0, len);

      // Cyan Neon Outer Glow
      canvas.drawPath(
        extracted,
        Paint()
          ..color = const Color(0xFF00F2FE).withOpacity(0.85 * glowIntensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10 * glowIntensity
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Cyan Bright Core
      canvas.drawPath(
        extracted,
        Paint()
          ..color = const Color(0xFF00F2FE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // White Center Fiber
      canvas.drawPath(
        extracted,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Leading Cyan Spark Head
      final tangent = metric.getTangentForOffset(len);
      if (tangent != null) {
        final pos = tangent.position;
        // Big glowing halo
        canvas.drawCircle(
          pos,
          14 * glowIntensity,
          Paint()
            ..color = const Color(0xFF00F2FE).withOpacity(0.70)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        // White Hot Center
        canvas.drawCircle(pos, 4.5, Paint()..color = Colors.white);
      }
    }

    // 2. Trace Path H (Hot Neon Magenta)
    for (final metric in metricsH) {
      final len = metric.length * trace;
      if (len <= 0) continue;
      final extracted = metric.extractPath(0.0, len);

      // Magenta Neon Outer Glow
      canvas.drawPath(
        extracted,
        Paint()
          ..color = const Color(0xFFFE2C55).withOpacity(0.85 * glowIntensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10 * glowIntensity
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Magenta Bright Core
      canvas.drawPath(
        extracted,
        Paint()
          ..color = const Color(0xFFFF2A6D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // White Center Fiber
      canvas.drawPath(
        extracted,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Leading Magenta Spark Head
      final tangent = metric.getTangentForOffset(len);
      if (tangent != null) {
        final pos = tangent.position;
        // Big glowing halo
        canvas.drawCircle(
          pos,
          14 * glowIntensity,
          Paint()
            ..color = const Color(0xFFFE2C55).withOpacity(0.70)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        // White Hot Center
        canvas.drawCircle(pos, 4.5, Paint()..color = Colors.white);
      }
    }
  }

  void _paintSolidChromatic(Canvas canvas, Path pathS, Path pathH, Path pathArrow, double fill) {
    // Dynamic thickness: expands smoothly from thin line to bold heavyweight glyph
    final strokeW = 4.0 + (16.5 * fill);

    // ---------------------------------------------------------
    // 1. Magenta 3D Shadow Layer (Shifted right & down + glitch)
    // ---------------------------------------------------------
    canvas.save();
    canvas.translate(4.0 + glitchOffset.dx, 3.5 + glitchOffset.dy);

    // Glow Spread
    final magentaGlow = Paint()
      ..color = const Color(0xFFFE2C55).withOpacity(0.75 * glowIntensity * fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (strokeW + 12) * glowIntensity
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowIntensity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathS, magentaGlow);
    canvas.drawPath(pathH, magentaGlow);

    // Magenta Core
    final magentaCore = Paint()
      ..color = const Color(0xFFFF2A6D).withOpacity(fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathS, magentaCore);
    canvas.drawPath(pathH, magentaCore);
    canvas.drawPath(pathArrow, Paint()..color = const Color(0xFFFF2A6D).withOpacity(fill));

    canvas.restore();

    // ---------------------------------------------------------
    // 2. Cyan 3D Shadow Layer (Shifted left & up + glitch)
    // ---------------------------------------------------------
    canvas.save();
    canvas.translate(-3.5 + glitchOffset.dx * 0.6, -2.5 + glitchOffset.dy * 0.6);

    // Glow Spread
    final cyanGlow = Paint()
      ..color = const Color(0xFF00F2FE).withOpacity(0.75 * glowIntensity * fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (strokeW + 12) * glowIntensity
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowIntensity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathS, cyanGlow);
    canvas.drawPath(pathH, cyanGlow);

    // Cyan Core
    final cyanCore = Paint()
      ..color = const Color(0xFF00F2FE).withOpacity(fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathS, cyanCore);
    canvas.drawPath(pathH, cyanCore);
    canvas.drawPath(pathArrow, Paint()..color = const Color(0xFF00F2FE).withOpacity(fill));

    canvas.restore();

    // ---------------------------------------------------------
    // 3. Crisp Bright Solid White Center Core
    // ---------------------------------------------------------
    final whitePaint = Paint()
      ..color = Colors.white.withOpacity(fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathS, whitePaint);
    canvas.drawPath(pathH, whitePaint);

    // White Arrow Body
    canvas.drawPath(pathArrow, Paint()..color = Colors.white.withOpacity(fill));

    // Outer Crisp Edge Contour
    final edgePaint = Paint()
      ..color = Colors.white.withOpacity(0.95 * fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathS, edgePaint);
    canvas.drawPath(pathH, edgePaint);
  }

  @override
  bool shouldRepaint(covariant SHLogoPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.traceProgress != traceProgress ||
        oldDelegate.fillProgress != fillProgress ||
        oldDelegate.flashIntensity != flashIntensity ||
        oldDelegate.glitchOffset != glitchOffset;
  }
}
