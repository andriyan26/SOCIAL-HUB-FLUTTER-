import 'dart:math' as math;
import 'package:flutter/material.dart';

class RotatingMusicDisc extends StatefulWidget {
  final String imagePath;

  const RotatingMusicDisc({super.key, required this.imagePath});

  @override
  State<RotatingMusicDisc> createState() => _RotatingMusicDiscState();
}

class _RotatingMusicDiscState extends State<RotatingMusicDisc> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animController.value * 2 * math.pi,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1E24),
              border: Border.all(color: Colors.black, width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.purple.shade700,
                  child: const Center(
                    child: Icon(Icons.music_note, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

