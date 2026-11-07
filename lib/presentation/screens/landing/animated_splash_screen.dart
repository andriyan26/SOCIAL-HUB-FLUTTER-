import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:social_hub/presentation/widgets/sh_logo_painter.dart';
import 'web_audio_helper.dart';

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
  // Master Choreographed Controllers (All VSYNC synchronized for 60 FPS butter-smooth motion)
  late AnimationController _traceController;       // Phase 1: Stroke tracing
  late AnimationController _impactController;      // Phase 2: Impact flash & solid expansion
  late AnimationController _brandController;       // Phase 3: Brand reveal & expanding neon line
  late AnimationController _ambientPulseController; // Subtle breathing glow
  late AnimationController _progressController;    // Bottom progress bar (60 FPS)

  // Animated Values
  late Animation<double> _traceAnimation;
  late Animation<double> _fillAnimation;
  late Animation<double> _flashAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _brandFade;
  late Animation<double> _brandSlide;
  late Animation<double> _lineWidth;

  // Micro glitch jitter
  Offset _glitchOffset = Offset.zero;
  Timer? _glitchTimer;

  // Erupting Burst Particles
  late List<_BurstParticle> _particles;

  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    // 1. Play native sound design matching the concept video
    playSplashAudioNative();

    // 2. Initialize 30 radial spark particles
    final rand = math.Random(123);
    final colors = [
      const Color(0xFF00F2FE),
      const Color(0xFFFE2C55),
      Colors.white,
      const Color(0xFF00F2FE),
      const Color(0xFFFF2A6D),
    ];
    _particles = List.generate(30, (i) {
      return _BurstParticle(
        angle: rand.nextDouble() * 2 * math.pi,
        distance: 45.0 + rand.nextDouble() * 115.0,
        size: 2.2 + rand.nextDouble() * 3.2,
        color: colors[i % colors.length],
      );
    });

    // 3. Phase 1: Stroke Tracing (1500ms)
    _traceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _traceAnimation = CurvedAnimation(
      parent: _traceController,
      curve: Curves.easeInOutCubic,
    );

    // 4. Phase 2: Impact Flash & Solid Fill Expansion (750ms)
    _impactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fillAnimation = CurvedAnimation(
      parent: _impactController,
      curve: Curves.easeOutBack,
    );
    _flashAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _impactController, curve: Curves.easeOut));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.07), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.07, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _impactController, curve: Curves.easeOutBack));

    // 5. Phase 3: Brand Reveal & Glowing Underline (800ms)
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _brandFade = CurvedAnimation(parent: _brandController, curve: Curves.easeIn);
    _brandSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeOutCubic),
    );
    _lineWidth = Tween<double>(begin: 0.0, end: 175.0).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeOutCubic),
    );

    // 6. Ambient Breathing Glow
    _ambientPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 7. Butter-smooth 60 FPS Bottom Progress Bar (Total 4000ms)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _skip();
      }
    });

    // Sequence Choreography: Tracing -> Impact -> Brand
    _traceController.forward().then((_) {
      if (!mounted) return;
      _impactController.forward().then((_) {
        if (!mounted) return;
        _brandController.forward();
      });
    });

    // Subtle micro glitch jitter every 850ms after impact
    _glitchTimer = Timer.periodic(const Duration(milliseconds: 850), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_impactController.value > 0.5) {
        final r = math.Random();
        setState(() {
          _glitchOffset = Offset((r.nextDouble() - 0.5) * 3.5, (r.nextDouble() - 0.5) * 2.0);
        });
        Future.delayed(const Duration(milliseconds: 70), () {
          if (mounted) {
            setState(() {
              _glitchOffset = Offset.zero;
            });
          }
        });
      }
    });
  }

  void _skip() {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _glitchTimer?.cancel();
    stopSplashAudioNative();
    widget.onCompleted();
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    stopSplashAudioNative();
    _traceController.dispose();
    _impactController.dispose();
    _brandController.dispose();
    _ambientPulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080C), // Deep pitch black OLED background
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skip,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // -----------------------------------------------------------
            // 1. Soft Ambient Background Bloom (CSS BoxShadow, Zero Grey Box)
            // -----------------------------------------------------------
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F2FE).withOpacity(0.08),
                      blurRadius: 90,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFE2C55).withOpacity(0.08),
                      blurRadius: 90,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),

            // -----------------------------------------------------------
            // 2. Floating Cyberpunk Micro Embers
            // -----------------------------------------------------------
            ...List.generate(10, (i) {
              final angle = i * (math.pi / 5);
              return AnimatedBuilder(
                animation: _ambientPulseController,
                builder: (context, _) {
                  final t = _ambientPulseController.value;
                  final dist = 115.0 + 30.0 * math.sin(t * math.pi * 2 + i * 0.8);
                  final dx = dist * math.cos(angle + t * 0.3);
                  final dy = dist * math.sin(angle + t * 0.3) - (t * 18);
                  final isCyan = i % 2 == 0;
                  return Center(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Container(
                        width: isCyan ? 3.0 : 2.2,
                        height: isCyan ? 3.0 : 2.2,
                        decoration: BoxDecoration(
                          color: isCyan ? const Color(0xFF00F2FE) : const Color(0xFFFE2C55),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // -----------------------------------------------------------
            // 3. Radial Particle Eruption Blast on Impact
            // -----------------------------------------------------------
            AnimatedBuilder(
              animation: _impactController,
              builder: (context, _) {
                final impactVal = _impactController.value;
                if (impactVal <= 0.0 || impactVal >= 1.0) {
                  return const SizedBox.shrink();
                }
                return Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: _particles.map((p) {
                      final dist = p.distance * Curves.easeOutCubic.transform(impactVal);
                      final dx = math.cos(p.angle) * dist;
                      final dy = math.sin(p.angle) * dist;
                      final opacity = (1.0 - impactVal).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: p.size,
                            height: p.size,
                            decoration: BoxDecoration(
                              color: p.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            // -----------------------------------------------------------
            // 4. Center Emblem & Brand Typography
            // -----------------------------------------------------------
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _traceController,
                  _impactController,
                  _brandController,
                  _ambientPulseController,
                ]),
                builder: (context, _) {
                  final glow = 0.90 + 0.25 * _ambientPulseController.value;
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dynamic 3D Chromatic SH Emblem
                        SizedBox(
                          width: 220,
                          height: 150,
                          child: CustomPaint(
                            painter: SHLogoPainter(
                              progress: _traceAnimation.value,
                              glowIntensity: glow,
                              traceProgress: _traceAnimation.value,
                              fillProgress: _fillAnimation.value,
                              flashIntensity: _flashAnimation.value,
                              glitchOffset: _glitchOffset,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),

                        // Brand Title & Slogan
                        Opacity(
                          opacity: _brandFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _brandSlide.value),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'S O C I A L   H U B',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 6.0,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(-2.5 + _glitchOffset.dx * 0.6, -1.2),
                                        color: const Color(0xFF00F2FE).withOpacity(0.85),
                                        blurRadius: 8,
                                      ),
                                      Shadow(
                                        offset: Offset(2.8 + _glitchOffset.dx * 0.6, 1.6),
                                        color: const Color(0xFFFE2C55).withOpacity(0.85),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Glowing Horizontal Neon Line Expanding from Center
                                Container(
                                  width: _lineWidth.value,
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFF00F2FE),
                                        Colors.white,
                                        Color(0xFFFE2C55),
                                        Colors.transparent,
                                      ],
                                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00F2FE).withOpacity(0.6),
                                        blurRadius: 6,
                                        spreadRadius: 0.5,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFFE2C55).withOpacity(0.6),
                                        blurRadius: 6,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Slogan
                                Text(
                                  'Jelajahi Kreativitas Tanpa Batas',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.70),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // -----------------------------------------------------------
            // 5. Minimalist 60 FPS Bottom Progress Line & Tap Prompt
            // -----------------------------------------------------------
            Positioned(
              left: 44,
              right: 44,
              bottom: 48,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 2.5,
                          child: LinearProgressIndicator(
                            value: _progressController.value,
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
                          color: Colors.white.withOpacity(0.38),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurstParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _BurstParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}
