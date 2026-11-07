import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/presentation/providers/ui_frame_provider.dart';
import 'package:social_hub/presentation/screens/landing/animated_splash_screen.dart';
import 'package:social_hub/presentation/screens/auth/animated_login_screen.dart';
import 'package:social_hub/presentation/screens/main/main_screen.dart';

enum FlowStage {
  splash,
  login,
  beranda,
}

class SequentialFlowScreen extends StatefulWidget {
  const SequentialFlowScreen({super.key});

  @override
  State<SequentialFlowScreen> createState() => _SequentialFlowScreenState();
}

class _SequentialFlowScreenState extends State<SequentialFlowScreen> {
  FlowStage _currentStage = FlowStage.splash;
  int _lastReplayKey = 0;

  void _goToLogin() {
    setState(() {
      _currentStage = FlowStage.login;
    });
  }

  void _goToBeranda() {
    setState(() {
      _currentStage = FlowStage.beranda;
    });
  }

  void _restartSequence() {
    setState(() {
      _currentStage = FlowStage.splash;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for top bar "Ulangi Animasi" clicks
    final replayKey = context.watch<UiFrameProvider>().replayKey;
    if (_lastReplayKey != replayKey) {
      _lastReplayKey = replayKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restartSequence();
      });
    }

    return Container(
      color: const Color(0xFF07080C),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 650),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _buildCurrentStage(),
      ),
    );
  }

  Widget _buildCurrentStage() {
    switch (_currentStage) {
      case FlowStage.splash:
        return AnimatedSplashScreen(
          key: const ValueKey('splash_stage'),
          onCompleted: _goToLogin,
        );
      case FlowStage.login:
        return AnimatedLoginScreen(
          key: const ValueKey('login_stage'),
          onLoginSuccess: _goToBeranda,
        );
      case FlowStage.beranda:
        return const MainScreen(
          key: ValueKey('beranda_stage'),
        );
    }
  }
}
