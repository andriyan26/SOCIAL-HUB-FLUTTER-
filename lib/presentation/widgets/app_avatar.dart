import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String avatarUrl;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final String fallbackInitial;
  final Widget? fallbackChild;

  const AppAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 48,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.fallbackInitial = 'a',
    this.fallbackChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.avatarPurple,
        shape: BoxShape.circle,
        border: borderWidth > 0 ? Border.all(color: borderColor, width: borderWidth) : null,
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (avatarUrl.isEmpty || avatarUrl == 'purple_a') {
      return _buildFallback();
    }

    // 1. Base64 Data URL (Uploaded from local computer/gallery via FileReader)
    if (avatarUrl.startsWith('data:image')) {
      try {
        final base64String = avatarUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } catch (e) {
        return _buildFallback();
      }
    }

    // 2. Blob URL or Network URL (Uploaded from Web or external link)
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://') || avatarUrl.startsWith('blob:')) {
      return Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    // 3. Local bundled asset image
    if (avatarUrl.startsWith('assets/')) {
      return Image.asset(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    if (fallbackChild != null) {
      return Container(
        color: AppColors.avatarPurple,
        child: Center(child: fallbackChild),
      );
    }
    return Container(
      color: AppColors.avatarPurple,
      child: Center(
        child: Text(
          fallbackInitial,
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
