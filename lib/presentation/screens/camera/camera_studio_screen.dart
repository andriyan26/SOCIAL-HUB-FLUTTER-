import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/presentation/providers/camera_provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';

class CameraStudioScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onPublishSuccess;

  const CameraStudioScreen({
    super.key,
    this.onClose,
    this.onPublishSuccess,
  });

  @override
  State<CameraStudioScreen> createState() => _CameraStudioScreenState();
}

class _CameraStudioScreenState extends State<CameraStudioScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flipAnimationController;

  int _timerCountdown = 0;
  Timer? _countdownTimer;
  bool _showFlash = false;
  bool _showFiltersDrawer = false;
  bool _isBeautyOn = false;

  final List<Map<String, dynamic>> _filtersList = [
    {
      'id': 0,
      'name': 'Normal',
      'matrix': <double>[
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ],
      'color': Colors.grey,
      'avatar': AppAssets.imgProfile,
    },
    {
      'id': 1,
      'name': 'Natural Creamy',
      'matrix': <double>[
        1.12, 0, 0, 0, 15,
        0, 1.05, 0, 0, 12,
        0, 0, 0.92, 0, -5,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFFFBBF24),
      'avatar': AppAssets.imgFeed,
    },
    {
      'id': 2,
      'name': 'Cyberpunk',
      'matrix': <double>[
        1.25, 0, 0, 0, 20,
        0, 0.9, 0, 0, -10,
        0, 0, 1.35, 0, 30,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFF00F2FE),
      'avatar': AppAssets.imgFriends,
    },
    {
      'id': 3,
      'name': 'Vintage 90s',
      'matrix': <double>[
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFFD97706),
      'avatar': AppAssets.imgInbox,
    },
    {
      'id': 4,
      'name': 'Monochrome B&W',
      'matrix': <double>[
        0.33, 0.33, 0.33, 0, 0,
        0.33, 0.33, 0.33, 0, 0,
        0.33, 0.33, 0.33, 0, 0,
        0, 0, 0, 1, 0,
      ],
      'color': Colors.white,
      'avatar': AppAssets.imgProfile,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flipAnimationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _triggerShutterAction(CameraProvider camera) {
    if (_timerCountdown > 0) return;

    if (camera.durationMode == CameraDurationMode.foto) {
      _executePhotoCapture(camera);
    } else {
      if (camera.isRecording) {
        camera.stopRecording();
        AppAudioService.instance.playChimeSound();
        _showPublishDialog(context, camera, isVideo: true);
      } else {
        AppAudioService.instance.playPopSound();
        camera.startRecording();
      }
    }
  }

  void _executePhotoCapture(CameraProvider camera) {
    AppAudioService.instance.playPopSound();
    setState(() => _showFlash = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _showFlash = false);
        _showPublishDialog(context, camera, isVideo: false);
      }
    });
  }

  void _startTimerCountdown(int seconds, VoidCallback onFinished) {
    setState(() => _timerCountdown = seconds);
    AppAudioService.instance.playPopSound();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerCountdown <= 1) {
        timer.cancel();
        setState(() => _timerCountdown = 0);
        onFinished();
      } else {
        setState(() => _timerCountdown--);
        AppAudioService.instance.playPopSound();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final camera = context.watch<CameraProvider>();
    final activeFilter = _filtersList[camera.activeFilterIndex % _filtersList.length];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Clean, High-Fidelity Camera Viewfinder (NO fake burnt-in UI buttons)
          AnimatedBuilder(
            animation: _flipAnimationController,
            builder: (context, child) {
              final angle = _flipAnimationController.value * 3.14159;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(activeFilter['matrix'] as List<double>),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Camera Lens Sensor Simulation Background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0F172A),
                              Color(0xFF050811),
                              Color(0xFF000000),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Optional Camera Feed / Lens Depth Texture
                      Center(
                        child: Opacity(
                          opacity: 0.18,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                          ),
                        ),
                      ),

                      // Camera Vignette for Depth
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                            radius: 0.95,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. 3x3 Composition Grid Overlay (When Toggled)
          if (camera.isGridOn)
            CustomPaint(
              size: Size.infinite,
              painter: _GridPainter(),
            ),

          // 3. Shutter Flash Overlay
          if (_showFlash)
            Positioned.fill(
              child: Container(color: Colors.white),
            ),

          // 4. Timer Countdown Overlay (3.. 2.. 1..)
          if (_timerCountdown > 0)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.55),
                child: Center(
                  child: Text(
                    '$_timerCountdown',
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: AppColors.primary, blurRadius: 40),
                        Shadow(color: Colors.black, blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 5. Recording Progress Bar (When Recording)
          if (camera.isRecording)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: true,
                bottom: false,
                child: LinearProgressIndicator(
                  value: camera.recordedSeconds /
                      (camera.durationMode == CameraDurationMode.fifteenSec ? 15.0 : 60.0),
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ),
            ),

          // 6. Top Bar (Close '✕' on Left, '♫ Tambah suara' in Center)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close '✕' Button
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      ),
                    ),

                    // "♫ Tambah suara" Capsule
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showSoundSelector(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.48),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 0.7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.music_note, color: Colors.white, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              camera.selectedSound,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Invisible spacer for balance
                    const SizedBox(width: 32),
                  ],
                ),
              ),
            ),
          ),

          // 7. Right Side Tool Column (7 Icons matching Gambar 1 Reference)
          Positioned(
            top: 54,
            right: 14,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  // 1. Flip Camera (Putar Kamera)
                  _buildToolIcon(
                    icon: Icons.flip_camera_ios_rounded,
                    onTap: () {
                      AppAudioService.instance.playChimeSound();
                      camera.toggleCameraFacing();
                      if (_flipAnimationController.isCompleted) {
                        _flipAnimationController.reverse();
                      } else {
                        _flipAnimationController.forward();
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // 2. Flash / Blitz
                  _buildToolIcon(
                    icon: camera.isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: camera.isFlashOn ? const Color(0xFFFBBF24) : Colors.white,
                    onTap: () {
                      camera.toggleFlash();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(camera.isFlashOn ? 'Flash Kamera: AKTIF ⚡' : 'Flash Kamera: NONAKTIF'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // 3. Timer (Hitung Mundur)
                  _buildToolIcon(
                    icon: Icons.timer_outlined,
                    color: _timerCountdown > 0 ? AppColors.primary : Colors.white,
                    onTap: () {
                      _startTimerCountdown(3, () {
                        _triggerShutterAction(camera);
                      });
                    },
                  ),
                  const SizedBox(height: 18),

                  // 4. Composition Grid (Garis Kisi 3x3)
                  _buildToolIcon(
                    icon: Icons.grid_view_rounded,
                    color: camera.isGridOn ? AppColors.cyan : Colors.white,
                    onTap: () {
                      camera.toggleGrid();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(camera.isGridOn ? 'Garis Kisi 3x3: AKTIF' : 'Garis Kisi 3x3: NONAKTIF'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // 5. Beautify / Percantik
                  _buildToolIcon(
                    icon: Icons.face_retouching_natural_rounded,
                    color: _isBeautyOn ? const Color(0xFFFE2C55) : Colors.white,
                    onTap: () {
                      setState(() => _isBeautyOn = !_isBeautyOn);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isBeautyOn ? 'Mode Cantik (Skin Smooth): AKTIF ✨' : 'Mode Cantik: NONAKTIF'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // 6. Filters / Efek Warna
                  _buildToolIcon(
                    icon: Icons.auto_awesome_rounded,
                    color: _showFiltersDrawer ? AppColors.primary : Colors.white,
                    onTap: () {
                      setState(() {
                        _showFiltersDrawer = !_showFiltersDrawer;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 7. Expand Chevron
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showExtraSettings(context),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 26),
                  ),
                ],
              ),
            ),
          ),

          // 8. Sliding Filter Bar Drawer (When Toggled)
          if (_showFiltersDrawer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 175,
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.78),
                  border: const Border(
                    top: BorderSide(color: Colors.white12),
                    bottom: BorderSide(color: Colors.white12),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtersList.length,
                  itemBuilder: (context, idx) {
                    final f = _filtersList[idx];
                    final isSelected = camera.activeFilterIndex == idx;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        camera.setFilterIndex(idx);
                        AppAudioService.instance.playPopSound();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? (f['color'] as Color).withOpacity(0.3) : Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? (f['color'] as Color) : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: f['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              f['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 9. Bottom Controls Section (Duration, Shutter with Filter Bubbles, and Modes)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A. Duration Selector Row: 10 mnt | 60 detik | 15 detik | FOTO | TEKS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDurationItem(CameraDurationMode.tenMin, '10 mnt', camera),
                        _buildDurationItem(CameraDurationMode.sixtySec, '60 detik', camera),
                        _buildDurationItem(CameraDurationMode.fifteenSec, '15 detik', camera),
                        _buildDurationItem(CameraDurationMode.foto, 'FOTO', camera),
                        _buildDurationItem(CameraDurationMode.teks, 'TEKS', camera),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // B. Shutter Row flanked by Gallery and Filter Bubbles (Matching Gambar 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Gallery Upload Button (Bottom Left)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showGalleryPicker(context, camera),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
                              image: const DecorationImage(
                                image: AssetImage(AppAssets.imgAndrianPoster),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Filter Circle 1
                        _buildFaceFilterBubble(1, camera),
                        // Filter Circle 2
                        _buildFaceFilterBubble(2, camera),

                        // Center Shutter Button (TikTok Red Button with Outer Ring)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _triggerShutterAction(camera),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              double scale = camera.isRecording ? 1.0 + (_pulseController.value * 0.08) : 1.0;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 82,
                                  height: 82,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.95),
                                      width: 4.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: camera.isRecording
                                          ? 38
                                          : (camera.durationMode == CameraDurationMode.foto ? 66 : 68),
                                      height: camera.isRecording
                                          ? 38
                                          : (camera.durationMode == CameraDurationMode.foto ? 66 : 68),
                                      decoration: BoxDecoration(
                                        color: camera.durationMode == CameraDurationMode.foto
                                            ? Colors.white
                                            : AppColors.primary,
                                        shape: camera.isRecording ? BoxShape.rectangle : BoxShape.circle,
                                        borderRadius: camera.isRecording ? BorderRadius.circular(8) : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Filter Circle 3
                        _buildFaceFilterBubble(3, camera),
                        // Filter Circle 4
                        _buildFaceFilterBubble(4, camera),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // C. Bottom Modes Tabs: KAMERA | BUAT | LIVE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBottomTab(CameraBottomTab.kamera, 'KAMERA', camera),
                      const SizedBox(width: 28),
                      _buildBottomTab(CameraBottomTab.buat, 'BUAT', camera),
                      const SizedBox(width: 28),
                      _buildBottomTab(CameraBottomTab.live, 'LIVE', camera),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon({
    required IconData icon,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          color: color,
          size: 25,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildDurationItem(CameraDurationMode mode, String title, CameraProvider camera) {
    final isSelected = camera.durationMode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppAudioService.instance.playPopSound();
        camera.setDurationMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5.5),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.75),
          ),
        ),
      ),
    );
  }

  Widget _buildFaceFilterBubble(int index, CameraProvider camera) {
    final isSelected = camera.activeFilterIndex == index;
    final f = _filtersList[index % _filtersList.length];
    final avatar = f['avatar'] as String;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        camera.setFilterIndex(index);
        AppAudioService.instance.playPopSound();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filter ${f['name']} Diterapkan ✨'), duration: const Duration(milliseconds: 800)),
        );
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white38,
            width: isSelected ? 2.5 : 1.2,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            avatar,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: f['color'] as Color),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab(CameraBottomTab tab, String label, CameraProvider camera) {
    final isSelected = camera.bottomTab == tab;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        camera.setBottomTab(tab);
        if (tab == CameraBottomTab.live) {
          _showLiveBroadcastModal(context);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : Colors.white54,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showLiveBroadcastModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sensors, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text('Siaran Langsung LIVE', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Mulai siaran langsung untuk berinteraksi langsung dengan pengikut Anda secara real-time!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menghubungkan ke Server LIVE Streaming Social Hub...')),
                  );
                },
                child: const Text('Mulai Siaran Langsung Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExtraSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.motion_photos_on, color: AppColors.cyan),
              title: const Text('Stabilisasi Video Otomatis (Ultra Smooth)', style: TextStyle(color: Colors.white, fontSize: 14)),
              trailing: const Icon(Icons.check, color: AppColors.cyan),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.aspect_ratio, color: Colors.white),
              title: const Text('Rasio Aspek 9:16 (Layar Penuh iPhone 13)', style: TextStyle(color: Colors.white, fontSize: 14)),
              trailing: const Icon(Icons.check, color: AppColors.cyan),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round, color: Colors.amber),
              title: const Text('Mode Malam (Night Shot Ultra Clarity)', style: TextStyle(color: Colors.white, fontSize: 14)),
              trailing: const Icon(Icons.toggle_on, color: AppColors.primary, size: 32),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showGalleryPicker(BuildContext context, CameraProvider camera) {
    final galleryImages = [
      AppAssets.imgAndrianPoster,
      AppAssets.imgFeed,
      AppAssets.imgFriends,
      AppAssets.imgProfile,
      AppAssets.imgInbox,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Foto / Video dari Galeri', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: galleryImages.length,
              itemBuilder: (context, idx) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(context);
                    _showPublishDialog(context, camera, isVideo: false, selectedThumb: galleryImages[idx]);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(galleryImages[idx], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPublishDialog(BuildContext context, CameraProvider camera, {required bool isVideo, String? selectedThumb}) {
    final captionController = TextEditingController(
      text: isVideo
          ? 'Momen seru studio Social Hub hari ini! 🚀 #socialhub #fyp #viral'
          : 'Hasil jepretan studio kamera terbaru! ✨ #aesthetic #photo',
    );
    final thumb = selectedThumb ?? (isVideo ? AppAssets.imgAndrianPoster : AppAssets.imgFeed);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isVideo ? 'Publikasikan Video Baru' : 'Publikasikan Foto Baru',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(thumb, width: 68, height: 90, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: captionController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Jelaskan konten Anda, tambahkan tagar...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF141418),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.music_note, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    camera.selectedSound != 'Tambah suara' ? camera.selectedSound : '♫ Sound Asli - andrianpei',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                ),
                onPressed: () async {
                  final user = context.read<AuthProvider>().currentUser;
                  final feedProvider = context.read<FeedProvider>();
                  final profileProvider = context.read<ProfileProvider>();

                  final newPost = PostEntity(
                    id: DateTime.now().millisecondsSinceEpoch,
                    userId: user?.id ?? 1,
                    authorName: user?.name ?? 'Andrian Pei',
                    authorUsername: user?.username ?? 'andrianpei',
                    authorAvatar: user?.avatarUrl ?? AppAssets.imgProfile,
                    videoUrl: AppAssets.videoAndrian,
                    caption: captionController.text.trim().isNotEmpty
                        ? captionController.text.trim()
                        : 'Konten terbaru dari Studio Social Hub! ✨ #fyp #socialhub',
                    musicTitle: camera.selectedSound != 'Tambah suara'
                        ? camera.selectedSound
                        : '♫ Sound Asli - andrianpei',
                    likesCount: 1,
                    commentsCount: 0,
                    sharesCount: 0,
                    bookmarksCount: 0,
                    isLiked: true,
                    isBookmarked: false,
                    viewCount: 1,
                    thumbnailPath: thumb,
                    createdAt: 'Baru saja',
                  );

                  // 1. Add post directly to FeedProvider (so it shows at the very top of Beranda)
                  feedProvider.addPostToFeed(newPost);

                  // 2. Add post directly to ProfileProvider (so it shows in profile grid)
                  await profileProvider.createNewPost(
                    userId: newPost.userId,
                    authorName: newPost.authorName,
                    authorUsername: newPost.authorUsername,
                    authorAvatar: newPost.authorAvatar,
                    videoUrl: newPost.videoUrl,
                    caption: newPost.caption,
                    musicTitle: newPost.musicTitle,
                    thumbnailPath: newPost.thumbnailPath,
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // close sheet
                    if (widget.onPublishSuccess != null) {
                      widget.onPublishSuccess!(); // return directly to Beranda (Feed)
                    } else if (widget.onClose != null) {
                      widget.onClose!();
                    }
                    AppAudioService.instance.playChimeSound();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Postingan berhasil dipublish ke Beranda dan Profil Anda!'),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Posting Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSoundSelector(BuildContext context) {
    final sounds = [
      '♫ Sound Asli - Aurelie',
      '♫ Anak Kampung (Remix)',
      '♫ Sound Wisuda Bangga (Original) - andrianpei',
      '♫ Trending TikTok Hits 2026',
      '♫ Instrumental Santai Beat',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pilih Musik & Suara',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            ...sounds.map(
              (sound) => ListTile(
                leading: const Icon(Icons.music_note, color: AppColors.primary),
                title: Text(sound, style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.check, color: AppColors.cyan, size: 18),
                onTap: () {
                  context.read<CameraProvider>().setSound(sound);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 0.8;

    // 2 vertical lines
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    // 2 horizontal lines
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
