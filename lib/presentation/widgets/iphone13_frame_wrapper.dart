import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/presentation/providers/ui_frame_provider.dart';
import 'package:social_hub/presentation/widgets/social_hub_brand_logo.dart';

class IPhone13FrameWrapper extends StatelessWidget {
  final Widget child;

  const IPhone13FrameWrapper({
    super.key,
    required this.child,
  });

  static const double iphone13Width = 390.0;
  static const double iphone13Height = 844.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If opened on native mobile phone screen
        if (constraints.maxWidth < 520) {
          return child;
        }

        final frameProvider = context.watch<UiFrameProvider>();
        final mode = frameProvider.viewportMode;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Column(
            children: [
              _buildTopSimulatorToolbar(
                context,
                frameProvider,
                mode,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildViewportBody(
                    context,
                    mode,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSimulatorToolbar(
    BuildContext context,
    UiFrameProvider provider,
    ViewportMode activeMode,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Green pulse dot + Brand logo
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SocialHubBrandLogo(size: 26),
          const SizedBox(width: 9),
          const Text(
            'Social Hub • Studio Preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),

          // Database Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF059669), width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage_rounded,
                  size: 11,
                  color: Color(0xFF6EE7B7),
                ),
                SizedBox(width: 5),
                Text(
                  'SQLite Database Ready',
                  style: TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Replay Button (Ulangi Animasi Login / Intro)
          InkWell(
            onTap: () => provider.triggerReplay(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF475569), width: 0.8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.replay_rounded,
                    size: 13,
                    color: Color(0xFFA3E635),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Ulangi Animasi (Intro ➔ Login ➔ Beranda)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Device Mode Chips (iPhone 13, Tablet, Desktop)
          _buildModeChip(
            label: 'iPhone 13 (390×844)',
            icon: Icons.phone_iphone_rounded,
            selected: activeMode == ViewportMode.iphone13,
            onTap: () => provider.setViewportMode(ViewportMode.iphone13),
          ),
          const SizedBox(width: 6),
          _buildModeChip(
            label: 'Tablet (768×1024)',
            icon: Icons.tablet_mac_rounded,
            selected: activeMode == ViewportMode.tablet,
            onTap: () => provider.setViewportMode(ViewportMode.tablet),
          ),
          const SizedBox(width: 6),
          _buildModeChip(
            label: 'Desktop Split View',
            icon: Icons.desktop_windows_rounded,
            selected: activeMode == ViewportMode.desktopFull,
            onTap: () => provider.setViewportMode(ViewportMode.desktopFull),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF05A28) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFF05A28) : const Color(0xFF334155),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewportBody(
    BuildContext context,
    ViewportMode mode,
  ) {
    if (mode == ViewportMode.desktopFull) {
      return SizedBox.expand(
        key: const ValueKey('desktop'),
        child: child,
      );
    }

    if (mode == ViewportMode.tablet) {
      return Center(
        key: const ValueKey('tablet'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 820,
              height: 1024,
              decoration: BoxDecoration(
                color: const Color(0xFF07080C),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0xFF475569), width: 10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 32,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: const Size(800, 1004),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // iPhone 13 (Default)
    const double phoneW = iphone13Width;
    const double phoneH = iphone13Height;

    return Center(
      key: const ValueKey('iphone13'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: phoneW + 24,
            height: phoneH + 24,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27303F), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(54),
              border: Border.all(
                color: const Color(0xFF475569),
                width: 2.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 36,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42),
              child: Container(
                width: phoneW,
                height: phoneH,
                color: const Color(0xFF07080C),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: const Size(phoneW, phoneH),
                    padding: const EdgeInsets.only(top: 34, bottom: 18),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(child: child),

                      // iPhone 13 Status Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: _buildIPhone13StatusBar(),
                        ),
                      ),

                      // iOS Home Indicator
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 134,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0x6694A3B8),
                                borderRadius: BorderRadius.circular(10),
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
          ),
        ),
      ),
    );
  }

  Widget _buildIPhone13StatusBar() {
    const fgColor = Colors.white;

    return SizedBox(
      height: 32,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '19:44',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: fgColor,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_alt_rounded,
                      size: 14,
                      color: fgColor,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.wifi_rounded,
                      size: 14,
                      color: fgColor,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.battery_full_rounded,
                      size: 15,
                      color: fgColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // iPhone 13 Notch
          Container(
            width: 146,
            height: 25,
            decoration: const BoxDecoration(
              color: Color(0xFF0B0F17),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07080C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

