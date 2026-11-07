import 'package:flutter/material.dart';

class IPhone13Frame extends StatelessWidget {
  final Widget child;

  const IPhone13Frame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If on real mobile device or small screen, show full screen natively
        if (constraints.maxWidth <= 520) {
          return child;
        }

        // On desktop or widescreen browser, wrap in an iPhone 13 frame
        final screenHeight = constraints.maxHeight;
        final targetHeight = screenHeight * 0.94;
        final targetWidth = targetHeight * (390 / 844);

        return Scaffold(
          backgroundColor: const Color(0xFF0B0B0E),
          body: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle background glow
              Center(
                child: Container(
                  width: targetWidth + 80,
                  height: targetHeight + 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFE2C55).withOpacity(0.04),
                  ),
                ),
              ),

              // iPhone 13 Outer Case
              Center(
                child: Container(
                  width: targetWidth,
                  height: targetHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(
                      color: const Color(0xFF2C2C34),
                      width: 9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 40,
                        spreadRadius: 8,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFF25F4EE).withOpacity(0.06),
                        blurRadius: 60,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(39),
                    child: Stack(
                      children: [
                        // The actual Flutter App Screen
                        Positioned.fill(child: child),

                        // iPhone 13 Notch at top center
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 148,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Speaker grill
                                  Container(
                                    width: 48,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF222228),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Front camera
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161622),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF2A2A38), width: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // iPhone Bottom Home Indicator Bar
                        Positioned(
                          bottom: 6,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 125,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Top preview info pill
              Positioned(
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_iphone, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'iPhone 13 Preview (390 x 844)',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

