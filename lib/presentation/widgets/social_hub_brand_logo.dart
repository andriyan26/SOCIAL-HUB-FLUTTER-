import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/presentation/widgets/sh_logo_painter.dart';

class SocialHubBrandLogo extends StatelessWidget {
  final double size;

  const SocialHubBrandLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(-1, 0),
          ),
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: CustomPaint(
        painter: SHLogoPainter(
          progress: 1.0,
          glowIntensity: 0.8,
        ),
      ),
    );
  }
}
