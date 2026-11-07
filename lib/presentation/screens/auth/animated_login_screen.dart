import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/widgets/sh_logo_painter.dart';

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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  // Animation States: 'idle' -> 'logging_in' -> 'success'
  String _loginState = 'idle';

  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  Future<void> _handleLogin() async {
    if (_loginState != 'idle') return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan username dan password Anda'),
          backgroundColor: Color(0xFFFE2C55),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _loginState = 'logging_in';
    });

    final auth = context.read<AuthProvider>();

    // 1. Minimum animation delay to show the "Logging you in..." experience from the concept video
    await Future.delayed(const Duration(milliseconds: 1000));

    // 2. Authenticate with local SQLite database
    final success = await auth.login(username, password);

    if (!mounted) return;

    if (success) {
      setState(() {
        _loginState = 'success';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        widget.onLoginSuccess();
      }
    } else {
      setState(() {
        _loginState = 'idle';
      });
      final errorMsg = auth.errorMessage ?? 'Username atau password salah. Silakan coba lagi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFFE2C55),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_loginState != 'idle') return;

    setState(() {
      _loginState = 'logging_in';
    });

    final auth = context.read<AuthProvider>();
    await Future.delayed(const Duration(milliseconds: 900));

    // Authenticate with default active user in database
    final success = await auth.login('andrianpei', 'password123');

    if (!mounted) return;

    if (success) {
      setState(() {
        _loginState = 'success';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        widget.onLoginSuccess();
      }
    } else {
      setState(() {
        _loginState = 'idle';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal masuk via $provider.'),
          backgroundColor: const Color(0xFFFE2C55),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Main Login Form View (Clean OLED Pitch Black)
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  );
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Header: Mini SH Glowing Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 52,
                            height: 44,
                            padding: const EdgeInsets.all(4),
                            child: CustomPaint(
                              painter: SHLogoPainter(
                                progress: 1.0,
                                glowIntensity: 0.85,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161926),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, color: Color(0xFF10B981), size: 7),
                                SizedBox(width: 6),
                                Text(
                                  'SQLite Active',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),

                      // Welcome Back Greeting (from Concept Video)
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your feeds, friends, and creator community are waiting',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.60),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Field 1: Email / Username
                      const Text(
                        'Email or Username',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12141F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF262A3E)),
                        ),
                        child: TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.alternate_email_rounded, color: Color(0xFF00F2FE), size: 18),
                            hintText: 'Enter your email or username',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Field 2: Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12141F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF262A3E)),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFE2C55), size: 18),
                            hintText: 'Enter your password',
                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _rememberMe ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                  color: _rememberMe ? const Color(0xFFFE2C55) : Colors.white30,
                                  size: 17,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: const Color(0xFF00F2FE).withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Primary Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFE2C55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 8,
                            shadowColor: const Color(0xFFFE2C55).withOpacity(0.5),
                          ),
                          onPressed: _handleLogin,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider "Or continue with" (from Concept Video)
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 11.5),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Social Logins (Google & Apple pills)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _handleSocialLogin('Google'),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131522),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF262A3E)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 28),
                                    SizedBox(width: 4),
                                    Text(
                                      'Google',
                                      style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _handleSocialLogin('Apple'),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131522),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF262A3E)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.apple, color: Colors.white, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      'Apple',
                                      style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Footer: Don't have an account? Create an account
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 12),
                            ),
                            Text(
                              'Create an account',
                              style: TextStyle(
                                color: const Color(0xFF00F2FE),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. WOW Loading Animation Overlay ("Logging you in...") (Exact Sec 12s from Concept Video)
          if (_loginState != 'idle')
            Container(
              color: Colors.black.withOpacity(0.88),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Animated Pulse Spinner
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_loginState == 'logging_in') ...[
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFE2C55)),
                                backgroundColor: const Color(0xFF00F2FE).withOpacity(0.2),
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.all(4),
                              child: CustomPaint(
                                painter: SHLogoPainter(
                                  progress: 1.0,
                                  glowIntensity: 0.9,
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF10B981),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // "Logging you in..." text from concept video
                    Text(
                      _loginState == 'logging_in' ? 'Logging you in...' : 'Welcome to Social Hub!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // "Getting your feed ready..."
                    Text(
                      _loginState == 'logging_in'
                          ? 'Getting your creator feeds & reels ready...'
                          : 'Opening your dashboard...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
