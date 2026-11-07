import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Renders the app inside an authentic, proportional Apple iPhone 13 chassis
/// when viewed on desktop browsers/wide screens.
/// When viewed on a real mobile device, it renders 100% edge-to-edge natively.
class IPhone13Frame extends StatelessWidget {
  final Widget child;

  const IPhone13Frame({super.key, required this.child});

  static const double phoneScreenWidth = 390.0;
  static const double phoneScreenHeight = 844.0;
  static const double bezelThickness = 10.0;
  static const double outerWidth = phoneScreenWidth + (bezelThickness * 2);
  static const double outerHeight = phoneScreenHeight + (bezelThickness * 2);

  @override
  Widget build(BuildContext context) {
    // If running natively on mobile phone (iOS / Android), render full screen without frame
    if (!kIsWeb) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // If browser screen is narrow (opened directly on a mobile phone browser)
        if (constraints.maxWidth <= 480) {
          return child;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0B0E),
          body: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // Ambient studio spotlight glow behind iPhone
              Center(
                child: Container(
                  width: 580,
                  height: 900,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFE2C55).withOpacity(0.08),
                        const Color(0xFF25F4EE).withOpacity(0.05),
                        Colors.transparent,
                      ],
                      radius: 0.75,
                    ),
                  ),
                ),
              ),

              // Responsive Centered iPhone 13 Phone Mockup
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Apple Header Badge
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16171E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2A2C38), width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.apple, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Apple iPhone 13 · Social Hub Mobile Preview',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Hardware Frame with Buttons
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Left: Mute Switch
                              Positioned(
                                left: -5,
                                top: 120,
                                child: Container(
                                  width: 5,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF383844),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Left: Volume Up
                              Positioned(
                                left: -5,
                                top: 165,
                                child: Container(
                                  width: 5,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF383844),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Left: Volume Down
                              Positioned(
                                left: -5,
                                top: 225,
                                child: Container(
                                  width: 5,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF383844),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Right: Power / Siri Button
                              Positioned(
                                right: -5,
                                top: 185,
                                child: Container(
                                  width: 5,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF383844),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              // Main iPhone Chassis
                              Container(
                                width: outerWidth,
                                height: outerHeight,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color(0xFF2C2D38),
                                    width: bezelThickness,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.95),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                      offset: const Offset(0, 16),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFE2C55).withOpacity(0.06),
                                      blurRadius: 60,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: SizedBox(
                                    width: phoneScreenWidth,
                                    height: phoneScreenHeight,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // 1. App Screen Viewport
                                        MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                            size: const Size(phoneScreenWidth, phoneScreenHeight),
                                            padding: const EdgeInsets.only(top: 44, bottom: 34),
                                            viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
                                          ),
                                          child: child,
                                        ),

                                        // 2. iOS Status Bar (9:41, Cellular, WiFi, Battery)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: 44,
                                          child: IgnorePointer(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 24),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // 9:41 Time
                                                  const Text(
                                                    '9:41',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                  // Right Status Icons
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // 4 Signal bars
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: List.generate(4, (i) => Container(
                                                          width: 2.5,
                                                          height: (i + 1) * 2.8 + 2,
                                                          margin: const EdgeInsets.only(right: 1.5),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(1),
                                                          ),
                                                        )),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      const Icon(Icons.wifi, color: Colors.white, size: 14),
                                                      const SizedBox(width: 5),
                                                      // Battery Icon
                                                      Container(
                                                        width: 21,
                                                        height: 11,
                                                        padding: const EdgeInsets.all(1.5),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.white70, width: 1.2),
                                                          borderRadius: BorderRadius.circular(3.5),
                                                        ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(1.5),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 3. iPhone 13 Sensor Notch
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: IgnorePointer(
                                            child: Center(
                                              child: Container(
                                                width: 140,
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
                                                    // Speaker Grille
                                                    Container(
                                                      width: 48,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF1E1E26),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    // Front Camera Lens
                                                    Container(
                                                      width: 9,
                                                      height: 9,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF0F0F16),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(0xFF262634),
                                                          width: 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 4. Apple iOS Home Indicator Bar
                                        Positioned(
                                          bottom: 8,
                                          left: 0,
                                          right: 0,
                                          child: IgnorePointer(
                                            child: Center(
                                              child: Container(
                                                width: 130,
                                                height: 4.5,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.65),
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
