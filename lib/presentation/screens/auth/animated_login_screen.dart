import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/widgets/ns_logo_painter.dart';

class AnimatedLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AnimatedLoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<AnimatedLoginScreen> createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen> with TickerProviderStateMixin {
  final _usernameController = TextEditingController(text: 'andrianpei');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  // Animation States: idle -> loading -> success
  String _btnState = 'idle'; // 'idle', 'loading', 'success'

  late AnimationController _fadeController;
  late AnimationController _waveController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
  }

  Future<void> _handleLogin() async {
    if (_btnState != 'idle') return;

    setState(() {
      _btnState = 'loading';
    });

    final authProvider = context.read<AuthProvider>();

    // Authenticate with local SQLite database
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _btnState = 'success';
      });

      await Future.delayed(const Duration(milliseconds: 650));
      if (mounted) {
        widget.onLoginSuccess();
      }
    } else {
      setState(() {
        _btnState = 'idle';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal. Periksa username dan password.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C14),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fluid Gradient Wave Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LoginWavePainter(animationValue: _waveController.value),
                );
              },
            ),
          ),

          // 2. Top Stage Tag & Quick Skip
          Positioned(
            top: 50,
            left: 18,
            right: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFE2C55).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFE2C55), width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_open_rounded, color: Color(0xFFFE2C55), size: 12),
                      SizedBox(width: 5),
                      Text(
                        '2. ANIMASI LOGIN (NATIVE)',
                        style: TextStyle(
                          color: Color(0xFFFE2C55),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _handleLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ke Beranda ➔',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Main Form Content (Smooth Entrance)
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 110),

                  // Mini Floating NS Logo with Glow
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131622),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFE2C55).withOpacity(0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFE2C55).withOpacity(0.35),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: NSLogoPainter(
                        progress: 1.0,
                        glowIntensity: 0.9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Selamat Datang di Social Hub',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sesi Akun Terkoneksi dengan Database SQLite',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Glassmorphism Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Username Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D2132),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E344E)),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.person_outline_rounded, color: Color(0xFF00F2FE), size: 19),
                              hintText: 'Masukkan username',
                              hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'Kata Sandi',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Password Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D2132),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E344E)),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFE2C55), size: 19),
                              hintText: 'Masukkan kata sandi',
                              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'Ingat Akun Saya',
                                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                                ),
                              ],
                            ),
                            Text(
                              'Lupa Sandi?',
                              style: TextStyle(
                                color: const Color(0xFF00F2FE).withOpacity(0.85),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Animated Morphing Login Button
                        GestureDetector(
                          onTap: _handleLogin,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _btnState == 'success'
                                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                    : [const Color(0xFFFE2C55), const Color(0xFF00F2FE)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: (_btnState == 'success'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFFE2C55))
                                      .withOpacity(0.45),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _buildButtonContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Demo Hint
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121520),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.key_rounded, color: Color(0xFF00F2FE), size: 13),
                        SizedBox(width: 6),
                        Text(
                          'Demo User: andrianpei · Sandi: password123',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_btnState == 'loading') {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_btnState == 'success') {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Berhasil Masuk!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
          ),
        ],
      );
    }

    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Masuk ke Halaman Beranda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
      ],
    );
  }
}

class _LoginWavePainter extends CustomPainter {
  final double animationValue;

  _LoginWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradient Background
    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFE2C55).withOpacity(0.35),
          const Color(0xFF00F2FE).withOpacity(0.18),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h * 0.75 + math.sin(animationValue * math.pi) * 15)
      ..cubicTo(
        w * 0.35,
        h * 0.95 + math.cos(animationValue * math.pi) * 12,
        w * 0.65,
        h * 0.60 + math.sin(animationValue * math.pi) * 16,
        w,
        h * 0.80,
      )
      ..lineTo(w, 0)
      ..close();

    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant _LoginWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
