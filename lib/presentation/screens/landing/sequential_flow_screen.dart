import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/screens/main/main_screen.dart';

enum FlowStage { intro, login, beranda }

class SequentialFlowScreen extends StatefulWidget {
  const SequentialFlowScreen({super.key});

  @override
  State<SequentialFlowScreen> createState() => _SequentialFlowScreenState();
}

class _SequentialFlowScreenState extends State<SequentialFlowScreen> with TickerProviderStateMixin {
  FlowStage _currentStage = FlowStage.intro;

  // Video Controllers
  VideoPlayerController? _introController;
  VideoPlayerController? _loginController;
  bool _isIntroReady = false;
  bool _isLoginReady = false;

  // Progress Tracking
  double _introProgress = 0.0;
  double _loginProgress = 0.0;
  Timer? _ticker;
  Timer? _safetyFallbackTimer;

  @override
  void initState() {
    super.initState();
    _initAllVideos();
  }

  Future<void> _initAllVideos() async {
    // 1. Initialize Stage 1 Video: KONSEP SEBELUM LOGIN.mp4
    try {
      _introController = VideoPlayerController.asset(AppAssets.videoLanding);
      await _introController!.initialize();
      _introController!.setVolume(0); // Muted allows immediate browser autoplay
      await _introController!.play();
      if (mounted) {
        setState(() {
          _isIntroReady = true;
        });
      }
    } catch (e) {
      debugPrint('Intro video init error: $e');
    }

    // 2. Pre-load Stage 2 Video: KONSEP LOGIN.mp4
    try {
      _loginController = VideoPlayerController.asset(AppAssets.videoLogin);
      await _loginController!.initialize();
      _loginController!.setVolume(0);
      if (mounted) {
        setState(() {
          _isLoginReady = true;
        });
      }
    } catch (e) {
      debugPrint('Login video init error: $e');
    }

    // 3. Fallback safety timer: if video doesn't trigger progress, allow auto progression
    _safetyFallbackTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _currentStage == FlowStage.intro) {
        _transitionToLoginStage();
      }
    });

    // 4. Progress monitor ticker
    _ticker = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentStage == FlowStage.intro && _introController != null && _isIntroReady) {
        final pos = _introController!.value.position.inMilliseconds;
        final dur = _introController!.value.duration.inMilliseconds;
        if (dur > 0) {
          final p = (pos / dur).clamp(0.0, 1.0);
          setState(() {
            _introProgress = p;
          });
          if (p >= 0.98) {
            _transitionToLoginStage();
          }
        }
      } else if (_currentStage == FlowStage.login && _loginController != null && _isLoginReady) {
        final pos = _loginController!.value.position.inMilliseconds;
        final dur = _loginController!.value.duration.inMilliseconds;
        if (dur > 0) {
          final p = (pos / dur).clamp(0.0, 1.0);
          setState(() {
            _loginProgress = p;
          });
          if (p >= 0.98) {
            _transitionToBeranda();
          }
        }
      }
    });
  }

  void _transitionToLoginStage() {
    if (_currentStage != FlowStage.intro) return;
    _introController?.pause();
    _loginController?.seekTo(Duration.zero);
    _loginController?.play();

    _safetyFallbackTimer?.cancel();
    _safetyFallbackTimer = Timer(const Duration(seconds: 14), () {
      if (mounted && _currentStage == FlowStage.login) {
        _transitionToBeranda();
      }
    });

    setState(() {
      _currentStage = FlowStage.login;
    });
  }

  Future<void> _transitionToBeranda() async {
    if (_currentStage == FlowStage.beranda) return;
    _safetyFallbackTimer?.cancel();
    _ticker?.cancel();
    _loginController?.pause();

    // Persist login session in local database
    try {
      await context.read<AuthProvider>().login('andrianpei', 'password123');
    } catch (_) {}

    if (mounted) {
      setState(() {
        _currentStage = FlowStage.beranda;
      });
    }
  }

  @override
  void dispose() {
    _safetyFallbackTimer?.cancel();
    _ticker?.cancel();
    _introController?.dispose();
    _loginController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stage 3: Halaman Beranda Muncul!
    if (_currentStage == FlowStage.beranda) {
      return const MainScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Tap anywhere on the screen for instant progression
          if (_currentStage == FlowStage.intro) {
            _transitionToLoginStage();
          } else if (_currentStage == FlowStage.login) {
            _transitionToBeranda();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Smooth Crossfade AnimatedSwitcher between Stage 1 and Stage 2
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              child: _currentStage == FlowStage.intro
                  ? _buildVideoPlayer(_introController, _isIntroReady, key: const ValueKey('video_intro'))
                  : _buildVideoPlayer(_loginController, _isLoginReady, key: const ValueKey('video_login')),
            ),

            // Subtle dark vignette gradient overlays
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Top Status & Step Indicators
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Multi-bar Progress Indicator (Instagram/TikTok Story Style)
                  Row(
                    children: [
                      // Stage 1 Indicator: Konsep Sebelum Login
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _currentStage == FlowStage.intro ? _introProgress : 1.0,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 3.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Stage 2 Indicator: Konsep Login
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _currentStage == FlowStage.login ? _loginProgress : 0.0,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                            minHeight: 3.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Header Badges & Skip Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _currentStage == FlowStage.intro ? AppColors.primary : AppColors.cyan,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (_currentStage == FlowStage.intro ? AppColors.primary : AppColors.cyan).withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          _currentStage == FlowStage.intro
                              ? '1. KONSEP SEBELUM LOGIN'
                              : '2. KONSEP LOGIN',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: _currentStage == FlowStage.intro ? Colors.white : Colors.black,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_currentStage == FlowStage.intro) {
                            _transitionToLoginStage();
                          } else {
                            _transitionToBeranda();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white30, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentStage == FlowStage.intro ? 'Lanjut ➔' : 'Ke Beranda ➔',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Navigation & Info Banner
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentStage == FlowStage.intro
                        ? 'Konsep Sebelum Login (Looping & Smooth)'
                        : 'Konsep Login (Transisi Verifikasi Akun)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentStage == FlowStage.intro
                        ? 'Menampilkan animasi logo sebelum masuk sistem'
                        : 'Selesai login langsung membuka Halaman Beranda',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Big Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentStage == FlowStage.intro ? AppColors.primary : const Color(0xFFFE2C55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 8,
                      ),
                      onPressed: () {
                        if (_currentStage == FlowStage.intro) {
                          _transitionToLoginStage();
                        } else {
                          _transitionToBeranda();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStage == FlowStage.intro
                                ? 'Lanjut ke Animasi Login ➔'
                                : 'Masuk ke Halaman Beranda 🔥',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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

  Widget _buildVideoPlayer(VideoPlayerController? controller, bool isReady, {required Key key}) {
    if (isReady && controller != null) {
      return SizedBox.expand(
        key: key,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    // Elegant fallback loader
    return Container(
      key: key,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C20), Color(0xFF141620), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SOCIAL HUB',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
