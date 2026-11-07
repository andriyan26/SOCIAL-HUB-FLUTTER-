import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/presentation/providers/camera_provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';

class CameraStudioScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const CameraStudioScreen({super.key, this.onClose});

  @override
  State<CameraStudioScreen> createState() => _CameraStudioScreenState();
}

class _CameraStudioScreenState extends State<CameraStudioScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flashAnimationController;
  late AnimationController _flipAnimationController;

  int _timerCountdown = 0;
  Timer? _countdownTimer;
  bool _showFlash = false;
  bool _showFiltersDrawer = false;
  bool _isLiveActive = false;

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
    },
    {
      'id': 1,
      'name': 'Natural Creamy',
      'matrix': <double>[
        1.1, 0, 0, 0, 15,
        0, 1.05, 0, 0, 12,
        0, 0, 0.95, 0, -5,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFFFBBF24),
    },
    {
      'id': 2,
      'name': 'Cyberpunk',
      'matrix': <double>[
        1.2, 0, 0, 0, 20,
        0, 0.9, 0, 0, -10,
        0, 0, 1.3, 0, 30,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFF00F2FE),
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
    },
    {
      'id': 5,
      'name': 'Vivid Glow',
      'matrix': <double>[
        1.3, 0, 0, 0, 0,
        0, 1.3, 0, 0, 0,
        0, 0, 1.3, 0, 0,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFFFE2C55),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _flashAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flashAnimationController.dispose();
    _flipAnimationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _triggerShutterAction(CameraProvider camera) {
    // If timer is on (3s or 10s)
    if (_timerCountdown > 0) return; // already counting down

    int seconds = (camera.durationMode == CameraDurationMode.foto) ? 0 : 0;
    // Check if user set timer
    if (camera.isGridOn) {
      // timer enabled or normal
    }

    if (camera.durationMode == CameraDurationMode.foto) {
      _executePhotoCapture(camera);
    } else {
      if (camera.isRecording) {
        camera.stopRecording();
        _showPublishDialog(context, camera, isVideo: true);
      } else {
        camera.startRecording();
      }
    }
  }

  void _executePhotoCapture(CameraProvider camera) {
    AppAudioService.instance.playShutterSound();
    setState(() {
      _showFlash = true;
    });

    _flashAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _showFlash = false;
      });
      _showPublishDialog(context, camera, isVideo: false);
    });
  }

  void _startTimerCountdown(int seconds, VoidCallback onFinish) {
    setState(() {
      _timerCountdown = seconds;
    });
    AppAudioService.instance.playTimerBeep(seconds);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerCountdown <= 1) {
        timer.cancel();
        setState(() {
          _timerCountdown = 0;
        });
        AppAudioService.instance.playTimerBeep(0);
        onFinish();
      } else {
        setState(() {
          _timerCountdown--;
        });
        AppAudioService.instance.playTimerBeep(_timerCountdown);
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
          // 1. Live Camera Viewfinder with 3D Flip & Active Color Filter
          AnimatedBuilder(
            animation: _flipAnimationController,
            builder: (context, child) {
              final angle = _flipAnimationController.value * 3.14159;
              final isFlipped = _flipAnimationController.value >= 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(activeFilter['matrix']),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Viewfinder base image
                      Image.asset(
                        AppAssets.imgCamera,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),

                      // Camera Lens Breathing Vignette
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.45),
                            ],
                            radius: 0.85,
                          ),
                        ),
                      ),

                      // Optional Face Detection Reticle Simulator
                      Center(
                        child: Container(
                          width: 170,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF20D5EC).withOpacity(0.6),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.face, color: Color(0xFF20D5EC), size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'Kreator Terdeteksi',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. 3x3 Composition Grid Overlay
          if (camera.isGridOn)
            CustomPaint(
              size: Size.infinite,
              painter: _GridPainter(),
            ),

          // 3. Subtitles / CC Simulation Badge
          Positioned(
            bottom: 240,
            left: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.closed_caption, color: AppColors.cyan, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Subtitel Otomatis: Siap Merekam Suara & Gerakan 🎙️',
                      style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. White Screen Shutter Flash Animation
          if (_showFlash)
            Positioned.fill(
              child: Container(color: Colors.white),
            ),

          // 5. Timer Countdown Overlay (3.. 2.. 1..)
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

          // 6. Top Bar (Close 'X', Add Sound Pill)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close 'X' button
                  GestureDetector(
                    onTap: () {
                      if (widget.onClose != null) {
                        widget.onClose!();
                      } else {
                        Navigator.maybePop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),

                  // "Tambah suara" Pill
                  GestureDetector(
                    onTap: () => _showSoundSelector(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.music_note, color: Colors.white, size: 16),
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

                  const SizedBox(width: 38), // Balances close button
                ],
              ),
            ),
          ),

          // 7. Right Tool Panel (Flip, Flash, Timer, Grid, Beauty/Filter, Captions, More)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 14),
                child: Column(
                  children: [
                    // Flip Camera
                    _buildToolIcon(
                      icon: Icons.flip_camera_ios,
                      label: '',
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

                    // Flash Toggle
                    _buildToolIcon(
                      icon: camera.isFlashOn ? Icons.flash_on : Icons.flash_off,
                      label: '',
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

                    // Timer (3s countdown)
                    _buildToolIcon(
                      icon: Icons.timer,
                      label: '',
                      color: _timerCountdown > 0 ? AppColors.primary : Colors.white,
                      onTap: () {
                        _startTimerCountdown(3, () {
                          _triggerShutterAction(camera);
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // Grid Lines Toggle
                    _buildToolIcon(
                      icon: Icons.grid_view,
                      label: '',
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

                    // Beauty / Filters Wand Drawer Toggle
                    Stack(
                      children: [
                        _buildToolIcon(
                          icon: Icons.auto_awesome,
                          label: '',
                          color: _showFiltersDrawer ? AppColors.primary : Colors.white,
                          onTap: () {
                            setState(() {
                              _showFiltersDrawer = !_showFiltersDrawer;
                            });
                          },
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // CC / Subtitles Toggle
                    _buildToolIcon(
                      icon: Icons.closed_caption,
                      label: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pengenalan Suara Otomatis Diaktifkan')),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Chevron dropdown
                    GestureDetector(
                      onTap: () => _showExtraSettings(context),
                      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 8. Interactive Filter Selector Drawer (Sliding Bar above shutter)
          if (_showFiltersDrawer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 180,
              child: Container(
                height: 78,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
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
                      onTap: () {
                        camera.setFilterIndex(idx);
                        AppAudioService.instance.playPopSound();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? f['color'].withOpacity(0.3) : Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? f['color'] : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: f['color'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              f['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12.5,
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

          // 9. Bottom Controls Section (Duration, Shutter, Modes)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Duration mode selector: 10 mnt, 60 detik, 15 detik, FOTO, TEKS
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

                  // Shutter Button Row flanked by Gallery and Filter Bubbles
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Gallery Thumbnail preview (bottom left)
                        GestureDetector(
                          onTap: () => _showGalleryPicker(context, camera),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
                              image: const DecorationImage(
                                image: AssetImage(AppAssets.imgFeed),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Filter Circle 1
                        _buildFilterThumb(1, camera),
                        // Filter Circle 2
                        _buildFilterThumb(2, camera),

                        // Center Shutter / Record Button
                        GestureDetector(
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
                                      color: Colors.white.withOpacity(0.9),
                                      width: 4.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: camera.isRecording ? 38 : (camera.durationMode == CameraDurationMode.foto ? 66 : 68),
                                      height: camera.isRecording ? 38 : (camera.durationMode == CameraDurationMode.foto ? 66 : 68),
                                      decoration: BoxDecoration(
                                        color: camera.durationMode == CameraDurationMode.foto ? Colors.white : AppColors.primary,
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
                        _buildFilterThumb(3, camera),
                        // Filter Circle 4
                        _buildFilterThumb(4, camera),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Bottom Mode Tabs: KAMERA, BUAT, LIVE
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
                  const SizedBox(height: 10),
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
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildDurationItem(CameraDurationMode mode, String title, CameraProvider camera) {
    final isSelected = camera.durationMode == mode;
    return GestureDetector(
      onTap: () {
        AppAudioService.instance.playPopSound();
        camera.setDurationMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterThumb(int index, CameraProvider camera) {
    final isSelected = camera.activeFilterIndex == index;
    final f = _filtersList[index % _filtersList.length];
    return GestureDetector(
      onTap: () {
        camera.setFilterIndex(index);
        AppAudioService.instance.playPopSound();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (f['color'] as Color).withOpacity(0.8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white54,
            width: isSelected ? 2.5 : 1.2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome,
            size: 15,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab(CameraBottomTab tab, String label, CameraProvider camera) {
    final isSelected = camera.bottomTab == tab;
    return GestureDetector(
      onTap: () {
        camera.setBottomTab(tab);
        if (tab == CameraBottomTab.live) {
          _showLiveBroadcastModal(context);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
      AppAssets.imgFeed,
      AppAssets.imgFriends,
      AppAssets.imgCamera,
      AppAssets.imgInbox,
      AppAssets.imgProfile,
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
            const Text('Galeri Media Perangkat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    final captionController = TextEditingController(text: isVideo ? 'Vlog seru hari ini! Momen studio 🚀 #socialhub #fyp' : 'Hasil jepretan studio terbaik! ✨ #aesthetic');
    final thumb = selectedThumb ?? (isVideo ? AppAssets.imgCamera : AppAssets.imgFeed);

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
                Text(isVideo ? 'Publikasikan Video' : 'Publikasikan Foto',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      fillColor: const Color(0xFF141418),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                    camera.selectedSound,
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
                  final newPost = await context.read<ProfileProvider>().createNewPost(
                    userId: user?.id ?? 1,
                    authorName: user?.name ?? 'Andrian Pei',
                    authorUsername: user?.username ?? 'andrianpei',
                    authorAvatar: user?.avatarUrl ?? AppAssets.imgProfile,
                    videoUrl: AppAssets.videoLogin,
                    caption: captionController.text.trim(),
                    musicTitle: camera.selectedSound,
                    thumbnailPath: thumb,
                  );
                  if (context.mounted) {
                    context.read<FeedProvider>().addPostToFeed(newPost);
                    Navigator.pop(context); // close sheet
                    if (widget.onClose != null) widget.onClose!(); // return to feed
                    AppAudioService.instance.playChimeSound();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Konten berhasil dipublikasikan ke Beranda & Profil! 🔥')),
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
      '♫ Trending TikTok Hits 2026',
      '♫ Instrumental Santai Beat',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
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
