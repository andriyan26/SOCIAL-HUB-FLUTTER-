import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:social_hub/presentation/widgets/sh_logo_painter.dart';

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

  double _progress = 0.0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();

    // Breathing glow animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Entrance zoom & fade animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();

    // Auto progress over 3.2 seconds
    _ticker = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress = (_progress + 0.013).clamp(0.0, 1.0);
      });
      if (_progress >= 1.0) {
        timer.cancel();
        widget.onCompleted();
      }
    });
  }

  void _skip() {
    _ticker?.cancel();
    widget.onCompleted();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080C),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skip,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Immersive Ambient Radial Glow in the background
            Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFE2C55).withOpacity(0.14),
                      const Color(0xFF00F2FE).withOpacity(0.09),
                      Colors.transparent,
                    ],
                    radius: 0.72,
                  ),
                ),
              ),
            ),

            // 2. Floating Cyberpunk Neon Dust Particles
            ...List.generate(8, (i) {
              final angle = i * (math.pi / 4);
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final dist = 110.0 + 25.0 * math.sin(_pulseController.value * math.pi * 2 + i * 0.8);
                  final dx = dist * math.cos(angle);
                  final dy = dist * math.sin(angle);
                  final isCyan = i % 2 == 0;
                  return Center(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Container(
                        width: isCyan ? 4.5 : 3.5,
                        height: isCyan ? 4.5 : 3.5,
                        decoration: BoxDecoration(
                          color: isCyan ? const Color(0xFF00F2FE) : const Color(0xFFFE2C55),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isCyan ? const Color(0xFF00F2FE) : const Color(0xFFFE2C55),
                              blurRadius: 10,
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

            // 3. Center Animated "SH" (Social Hub) Logo & Branding
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 3D Neon "SH" Monogram
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return SizedBox(
                            width: 180,
                            height: 140,
                            child: CustomPaint(
                              painter: SHLogoPainter(
                                progress: 1.0,
                                glowIntensity: _glowAnimation.value,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // "SOCIAL HUB" Typography with Shimmering Gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF00F2FE),
                            Color(0xFFFFFFFF),
                            Color(0xFFFE2C55),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'S O C I A L   H U B',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 6.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Slogan
                      Text(
                        'Jelajahi Kreativitas Tanpa Batas',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.60),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Elegant Minimal Bottom Progress Line
            Positioned(
              left: 36,
              right: 36,
              bottom: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F2FE)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ketuk untuk langsung masuk',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.35),
                      letterSpacing: 0.5,
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
