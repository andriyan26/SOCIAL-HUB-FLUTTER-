import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_colors.dart';

class SocialHubBrandLogo extends StatelessWidget {
  final double size;

  const SocialHubBrandLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(-1, 0),
          ),
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFE2C55), Color(0xFF25F4EE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(
            Icons.music_note_rounded,
            size: size * 0.65,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
