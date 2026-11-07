import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Neon "SH" (Social Hub) Emblem Painter
/// Fully optimized for Flutter Web (Zero MaskFilter.blur to completely eliminate gray box artifacts)
/// 1. Phase 1: Two plasma energy spark heads (Cyan on S, Magenta on H) trace the neon paths.
/// 2. Phase 2: Concentric flash bloom triggers transformation into heavyweight, bold, 3D chromatic glyphs.
/// 3. Phase 3: Triple-layer chromatic aberration (Electric Cyan #00F2FE on left, Hot Magenta #FE2C55 on right, Solid Bright White in center).
/// 4. Integrated forward-momentum chevron arrow connecting S and H.
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

    // Resolve stage values
    final effectiveTrace = traceProgress ?? (progress < 1.0 ? progress : 1.0);
    final effectiveFill = fillProgress ?? (progress >= 1.0 ? 1.0 : 0.0);

    // Normalize coordinates to 220x150 reference box
    final scaleX = w / 220.0;
    final scaleY = h / 150.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Apply slight futuristic italic slant (~8 degrees)
    canvas.save();
    canvas.translate(110, 75);
    canvas.transform(Matrix4.skewX(-0.12).storage);
    canvas.translate(-110, -75);

    final pathS = _buildPathS();
    final pathH = _buildPathH();
    final pathArrow = _buildPathArrow();

    // -------------------------------------------------------------
    // STAGE 1: STROKE TRACING WITH CONCENTRIC GLOW (NO MASKFILTER)
    // -------------------------------------------------------------
    if (effectiveTrace < 1.0) {
      _paintStrokeTracing(canvas, pathS, pathH, effectiveTrace);
    }

    // -------------------------------------------------------------
    // STAGE 2: SOLID BOLD CHROMATIC GLYPHS WITH CHROME-WHITE CORE
    // -------------------------------------------------------------
    if (effectiveFill > 0.0) {
      _paintSolidChromatic(canvas, pathS, pathH, pathArrow, effectiveFill);
    }

    // -------------------------------------------------------------
    // STAGE 3: CONCENTRIC WHITE FLASH BLOOM (ZERO MASKFILTER / NO GREY)
    // -------------------------------------------------------------
    if (flashIntensity > 0.0) {
      _paintFlashBloom(canvas, const Offset(110, 75), flashIntensity);
    }

    canvas.restore(); // Undo slant
    canvas.restore(); // Undo scale
  }

  Path _buildPathS() {
    // Stylized high-energy cyber "S"
    return Path()
      ..moveTo(98, 36)
      ..cubicTo(98, 24, 40, 24, 34, 38)
      ..cubicTo(28, 52, 28, 70, 56, 75)
      ..lineTo(76, 78)
      ..cubicTo(100, 82, 104, 104, 98, 118)
      ..cubicTo(92, 136, 44, 138, 32, 126)
      ..lineTo(56, 104);
  }

  Path _buildPathH() {
    // Stylized high-energy cyber "H"
    return Path()
      // Left vertical pillar (top to bottom)
      ..moveTo(132, 26)
      ..lineTo(132, 134)
      // Crossbar (left to right)
      ..moveTo(132, 80)
      ..lineTo(188, 80)
      // Right vertical pillar (bottom to top)
      ..moveTo(188, 134)
      ..lineTo(188, 26);
  }

  Path _buildPathArrow() {
    // Energetic diagonal arrow cutting up-right
    return Path()
      ..moveTo(48, 114)
      ..lineTo(106, 80)
      ..lineTo(96, 78)
      ..lineTo(116, 72)
      ..lineTo(112, 92)
      ..lineTo(104, 84)
      ..lineTo(52, 120)
      ..close();
  }

  void _paintStrokeTracing(Canvas canvas, Path pathS, Path pathH, double trace) {
    final metricsS = pathS.computeMetrics().toList();
    final metricsH = pathH.computeMetrics().toList();

    // 1. Trace Letter S (Electric Cyan)
    for (final metric in metricsS) {
      final len = metric.length * trace;
      if (len <= 0) continue;
      final extracted = metric.extractPath(0.0, len);

      _drawNeonStroke(
        canvas,
        extracted,
        const Color(0xFF00F2FE),
        3.5,
        glowIntensity,
      );

      // Leading Cyan Spark Head
      final tangent = metric.getTangentForOffset(len);
      if (tangent != null) {
        _drawSparkHead(canvas, tangent.position, const Color(0xFF00F2FE), glowIntensity);
      }
    }

    // 2. Trace Letter H (Hot Neon Magenta)
    for (final metric in metricsH) {
      final len = metric.length * trace;
      if (len <= 0) continue;
      final extracted = metric.extractPath(0.0, len);

      _drawNeonStroke(
        canvas,
        extracted,
        const Color(0xFFFE2C55),
        3.5,
        glowIntensity,
      );

      // Leading Magenta Spark Head
      final tangent = metric.getTangentForOffset(len);
      if (tangent != null) {
        _drawSparkHead(canvas, tangent.position, const Color(0xFFFE2C55), glowIntensity);
      }
    }
  }

  void _paintSolidChromatic(Canvas canvas, Path pathS, Path pathH, Path pathArrow, double fill) {
    // Dynamic heavy-weight stroke thickness: expands smoothly to bold block
    final strokeW = 4.0 + (17.0 * fill);

    // ---------------------------------------------------------
    // 1. Magenta 3D Shadow Layer (Shifted right & down + glitch)
    // ---------------------------------------------------------
    canvas.save();
    canvas.translate(4.0 + glitchOffset.dx, 3.5 + glitchOffset.dy);

    final magentaColor = const Color(0xFFFE2C55);
    // Outer diffuse pass
    canvas.drawPath(
      pathS,
      Paint()
        ..color = magentaColor.withOpacity(0.18 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 16 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      pathH,
      Paint()
        ..color = magentaColor.withOpacity(0.18 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 16 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Medium glow pass
    canvas.drawPath(
      pathS,
      Paint()
        ..color = magentaColor.withOpacity(0.40 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 8 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      pathH,
      Paint()
        ..color = magentaColor.withOpacity(0.40 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 8 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Solid core pass
    final magentaCore = Paint()
      ..color = const Color(0xFFFF2A6D).withOpacity(fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 2.5
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

    final cyanColor = const Color(0xFF00F2FE);
    // Outer diffuse pass
    canvas.drawPath(
      pathS,
      Paint()
        ..color = cyanColor.withOpacity(0.18 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 16 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      pathH,
      Paint()
        ..color = cyanColor.withOpacity(0.18 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 16 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Medium glow pass
    canvas.drawPath(
      pathS,
      Paint()
        ..color = cyanColor.withOpacity(0.40 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 8 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      pathH,
      Paint()
        ..color = cyanColor.withOpacity(0.40 * glowIntensity * fill)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 8 * glowIntensity
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Solid core pass
    final cyanCore = Paint()
      ..color = cyanColor.withOpacity(fill)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pathS, cyanCore);
    canvas.drawPath(pathH, cyanCore);
    canvas.drawPath(pathArrow, Paint()..color = cyanColor.withOpacity(fill));

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

  void _drawNeonStroke(Canvas canvas, Path path, Color color, double width, double glow) {
    // Multi-pass vector glow (100% web safe, zero grey artifacts)
    // Pass 1: Outer ambient aura
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.15 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 14 * glow
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Pass 2: Mid-range glow
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.35 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 8 * glow
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Pass 3: Vivid core
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Pass 4: Pure white center laser filament
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawSparkHead(Canvas canvas, Offset pos, Color color, double glow) {
    // Concentric spark orb without MaskFilter
    // Layer 1: Diffuse aura
    canvas.drawCircle(
      pos,
      16 * glow,
      Paint()..color = color.withOpacity(0.18 * glow),
    );
    // Layer 2: Mid aura
    canvas.drawCircle(
      pos,
      10 * glow,
      Paint()..color = color.withOpacity(0.40 * glow),
    );
    // Layer 3: Saturated core
    canvas.drawCircle(
      pos,
      5.5,
      Paint()..color = color.withOpacity(0.90),
    );
    // Layer 4: White hot point
    canvas.drawCircle(
      pos,
      2.8,
      Paint()..color = Colors.white,
    );
  }

  void _paintFlashBloom(Canvas canvas, Offset center, double intensity) {
    // Concentric pure white expansion (NO MaskFilter, zero grey box)
    canvas.drawCircle(
      center,
      110 * intensity,
      Paint()..color = Colors.white.withOpacity(0.06 * intensity),
    );
    canvas.drawCircle(
      center,
      70 * intensity,
      Paint()..color = Colors.white.withOpacity(0.16 * intensity),
    );
    canvas.drawCircle(
      center,
      36 * intensity,
      Paint()..color = Colors.white.withOpacity(0.38 * intensity),
    );
    canvas.drawCircle(
      center,
      15 * intensity,
      Paint()..color = Colors.white.withOpacity(0.85 * intensity),
    );
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
