import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/presentation/widgets/ns_logo_painter.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const AnimatedSplashScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _autoAdvanceTimer;
  double _loadProgress = 0.0;
  Timer? _progressTicker;

  @override
  void initState() {
    super.initState();

    // Breathing glow animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Entrance fade & zoom animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();

    // Progress bar simulation (3.5 seconds total)
    _progressTicker = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _loadProgress = (_loadProgress + 0.015).clamp(0.0, 1.0);
      });
      if (_loadProgress >= 1.0) {
        timer.cancel();
        _proceed();
      }
    });
  }

  void _proceed() {
    _autoAdvanceTimer?.cancel();
    _progressTicker?.cancel();
    widget.onCompleted();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _progressTicker?.cancel();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070B),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceed,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Ambient Background Glows
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFE2C55).withOpacity(0.12),
                      const Color(0xFF00F2FE).withOpacity(0.08),
                      Colors.transparent,
                    ],
                    radius: 0.7,
                  ),
                ),
              ),
            ),

            // 2. Animated Floating Neon Sparkles
            ...List.generate(6, (i) {
              final angle = i * (math.pi / 3);
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final offsetDist = 120 + 20 * math.sin(_pulseController.value * math.pi * 2 + i);
                  final dx = offsetDist * math.cos(angle);
                  final dy = offsetDist * math.sin(angle);
                  return Center(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Container(
                        width: (i % 2 == 0) ? 5 : 4,
                        height: (i % 2 == 0) ? 5 : 4,
                        decoration: BoxDecoration(
                          color: (i % 2 == 0) ? const Color(0xFF00F2FE) : const Color(0xFFFE2C55),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (i % 2 == 0) ? const Color(0xFF00F2FE) : const Color(0xFFFE2C55),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // 3. Center NS Logo + Typography
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing NS Logo
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return SizedBox(
                            width: 190,
                            height: 140,
                            child: CustomPaint(
                              painter: NSLogoPainter(
                                progress: 1.0,
                                glowIntensity: _glowAnimation.value,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Brand Name "NoShot" with Cyberpunk Gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00F2FE), Color(0xFFFFFFFF), Color(0xFFFE2C55)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'N O S H O T',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                        'Jelajahi Kreativitas Tanpa Batas',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.65),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Top Tag: "KONSEP 1: ANIMASI SEBELUM LOGIN"
            Positioned(
              top: 52,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F2FE).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00F2FE), width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF00F2FE), size: 12),
                        SizedBox(width: 5),
                        Text(
                          '1. ANIMASI INTRO (NATIVE)',
                          style: TextStyle(
                            color: Color(0xFF00F2FE),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _proceed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lewati ➔',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 5. Bottom Loading Indicator & Action Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _loadProgress,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F2FE)),
                      minHeight: 3.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Button to advance to login animation
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE2C55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        elevation: 6,
                      ),
                      onPressed: _proceed,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lanjut ke Animasi Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
