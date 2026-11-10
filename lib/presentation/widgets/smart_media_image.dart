import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_assets.dart';

class SmartMediaImage extends StatelessWidget {
  final String pathOrUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  const SmartMediaImage({
    super.key,
    required this.pathOrUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (pathOrUrl.isEmpty) {
      return Image.asset(AppAssets.imgAndrianPoster, fit: fit, width: width, height: height, alignment: alignment);
    }

    if (pathOrUrl.startsWith('data:')) {
      try {
        final b64 = pathOrUrl.split(',').last;
        // If base64 is less than 7500 chars, it's a blank/black canvas from mobile browser
        if (b64.length < 7500) {
          return Image.asset(AppAssets.imgFeed, fit: fit, width: width, height: height, alignment: alignment);
        }
        final bytes = base64Decode(b64);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          alignment: alignment,
          errorBuilder: (_, __, ___) => Image.asset(AppAssets.imgFeed, fit: fit, width: width, height: height, alignment: alignment),
        );
      } catch (_) {
        return Image.asset(AppAssets.imgFeed, fit: fit, width: width, height: height, alignment: alignment);
      }
    }

    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://') || pathOrUrl.startsWith('blob:')) {
      return Image.network(
        pathOrUrl,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: (_, __, ___) => Image.asset(AppAssets.imgAndrianPoster, fit: fit, width: width, height: height, alignment: alignment),
      );
    }

    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: (_, __, ___) => Image.asset(AppAssets.imgAndrianPoster, fit: fit, width: width, height: height, alignment: alignment),
      );
    }

    return Image.asset(
      AppAssets.imgAndrianPoster,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
    );
  }
}

