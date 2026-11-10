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
import 'package:social_hub/presentation/widgets/smart_media_image.dart';
import 'webcam_preview.dart';
import 'web_file_picker.dart';
import 'video_publish_preview_screen.dart';

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
  bool _isBeautyOn = true;
  int _timerSetting = 0; // 0: off, 3: 3s, 10: 10s

  // 5 Aesthetic Real-Time Beauty & Color Filters (Matching Gambar 1)
  final List<Map<String, dynamic>> _filtersList = [
    {
      'id': 0,
      'name': 'Normal',
      'label': 'Asli',
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
      'name': 'Glamour Glow',
      'label': 'Glamour',
      'matrix': <double>[
        1.15, 0, 0, 0, 18,
        0, 1.08, 0, 0, 12,
        0, 0, 0.94, 0, -4,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFFFBBF24),
      'avatar': AppAssets.imgFeed,
    },
    {
      'id': 2,
      'name': 'Golden Sun',
      'label': 'Golden',
      'matrix': <double>[
        1.22, 0, 0, 0, 22,
        0, 1.02, 0, 0, 10,
        0, 0, 0.85, 0, -15,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFFF59E0B),
      'avatar': AppAssets.imgProfile,
    },
    {
      'id': 3,
      'name': 'Soft Hijab Chic',
      'label': 'Soft Chic',
      'matrix': <double>[
        1.05, 0, 0, 0, 10,
        0, 1.12, 0, 0, 14,
        0, 0, 1.18, 0, 18,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFF20D5EC),
      'avatar': AppAssets.imgFriends,
    },
    {
      'id': 4,
      'name': 'Rosy Glam',
      'label': 'Rosy Pink',
      'matrix': <double>[
        1.24, 0, 0, 0, 25,
        0, 0.96, 0, 0, -6,
        0, 0, 1.15, 0, 15,
        0, 0, 0, 1, 0,
      ],
      'color': const Color(0xFFEC4899),
      'avatar': AppAssets.imgInbox,
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

    if (_timerSetting > 0) {
      _startTimerCountdown(_timerSetting, () {
        _executeCaptureOrRecord(camera);
      });
    } else {
      _executeCaptureOrRecord(camera);
    }
  }

  void _executeCaptureOrRecord(CameraProvider camera) {
    if (camera.durationMode == CameraDurationMode.foto) {
      _executePhotoCapture(camera);
    } else {
      if (camera.isRecording) {
        camera.stopRecording();
        AppAudioService.instance.playChimeSound();
        _openPublishPreviewScreen(isVideo: true);
      } else {
        AppAudioService.instance.playPopSound();
        camera.startRecording(onComplete: () {
          if (mounted) {
            AppAudioService.instance.playChimeSound();
            _openPublishPreviewScreen(isVideo: true);
          }
        });
      }
    }
  }

  void _executePhotoCapture(CameraProvider camera) {
    AppAudioService.instance.playPopSound();
    setState(() => _showFlash = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _showFlash = false);
        _openPublishPreviewScreen(isVideo: false);
      }
    });
  }

  void _openPublishPreviewScreen({
    required bool isVideo,
    String? selectedThumb,
    String? selectedVideoUrl,
    String? customFileName,
    String? initialCaption,
  }) {
    final camera = context.read<CameraProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPublishPreviewScreen(
          videoUrl: selectedVideoUrl ?? AppAssets.videoAndrian,
          thumbnailUrl: selectedThumb ?? (isVideo ? AppAssets.imgAndrianPoster : AppAssets.imgFeed),
          isVideo: isVideo,
          initialCaption: initialCaption,
          customFileName: customFileName,
          soundTitle: camera.selectedSound != 'Tambah suara'
              ? camera.selectedSound
              : '♫ Sound Asli - andrianpei',
          onPublishSuccess: () {
            Navigator.pop(context); // Close preview screen
            if (widget.onPublishSuccess != null) {
              widget.onPublishSuccess!();
            } else if (widget.onClose != null) {
              widget.onClose!();
            }
          },
          onBackToCamera: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
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

  void _toggleFlipCamera(CameraProvider camera) {
    AppAudioService.instance.playPopSound();
    camera.toggleCameraFacing();
    _flipAnimationController.forward(from: 0.0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(camera.isFrontCamera ? 'Kamera Depan Aktif 🤳' : 'Kamera Belakang Aktif 📷'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _cycleTimer() {
    AppAudioService.instance.playPopSound();
    setState(() {
      if (_timerSetting == 0) {
        _timerSetting = 3;
      } else if (_timerSetting == 3) {
        _timerSetting = 10;
      } else {
        _timerSetting = 0;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_timerSetting > 0 ? 'Timer Diatur ke ${_timerSetting} Detik ⏱️' : 'Timer Dinonaktifkan'),
        duration: const Duration(seconds: 1),
      ),
    );
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
          // 1. Live Camera Feed (Webcam Stream + Fallback Simulated Viewfinder)
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
                      // A. Real HTML5 Webcam Live Video Stream
                      WebcamPreviewWidget(
                        isFrontCamera: camera.isFrontCamera,
                        isMirrored: camera.isFrontCamera,
                      ),

                      // B. Lens Depth & Studio Ambient Fallback
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.35),
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // C. Dynamic Studio Reticle / Focus Center Box
                      Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12, width: 1.0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              // Top-Left bracket
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF20D5EC), width: 2), left: BorderSide(color: Color(0xFF20D5EC), width: 2)))),
                              ),
                              // Top-Right bracket
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF20D5EC), width: 2), right: BorderSide(color: Color(0xFF20D5EC), width: 2)))),
                              ),
                              // Bottom-Left bracket
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF20D5EC), width: 2), left: BorderSide(color: Color(0xFF20D5EC), width: 2)))),
                              ),
                              // Bottom-Right bracket
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF20D5EC), width: 2), right: BorderSide(color: Color(0xFF20D5EC), width: 2)))),
                              ),
                            ],
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

          // 4. Timer Countdown Overlay Animation (3, 2, 1)
          if (_timerCountdown > 0)
            Center(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_timerCountdown),
                tween: Tween(begin: 1.5, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '$_timerCountdown',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 5. Recording Progress Bar at the Top (Red Bar filling up)
          if (camera.isRecording)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: camera.recordedSeconds /
                          (camera.durationMode == CameraDurationMode.fifteenSec
                              ? 15.0
                              : (camera.durationMode == CameraDurationMode.sixtySec ? 60.0 : 600.0)),
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 4,
                    ),
                  ),
                ),
              ),
            ),

          // 6. Top Bar: [✕ Close Button] and [♫ Tambah suara] Centered Pill
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close '✕' Button
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        AppAudioService.instance.playPopSound();
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 22),
                      ),
                    ),

                    // Centered Music Pill '♫ Tambah suara'
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showSoundPicker(context, camera),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.music_note, color: Colors.white, size: 15),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(
                                camera.selectedSound,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Placeholder to balance the row
                    const SizedBox(width: 38),
                  ],
                ),
              ),
            ),
          ),

          // 7. Right Vertical Tool Bar (Flip, Flash, Timer, Grid, Beauty, Voice, Expand)
          Positioned(
            top: 60,
            right: 12,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  _buildToolButton(
                    icon: Icons.flip_camera_ios_outlined,
                    label: 'Balik',
                    onTap: () => _toggleFlipCamera(camera),
                  ),
                  const SizedBox(height: 16),
                  _buildToolButton(
                    icon: camera.isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    label: camera.isFlashOn ? 'Nyala' : 'Lampu',
                    color: camera.isFlashOn ? const Color(0xFFFBBF24) : Colors.white,
                    onTap: () {
                      AppAudioService.instance.playChimeSound();
                      camera.toggleFlash();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildToolButton(
                    icon: _timerSetting > 0 ? Icons.timer_outlined : Icons.timer_off_outlined,
                    label: _timerSetting > 0 ? '${_timerSetting}d' : 'Waktu',
                    color: _timerSetting > 0 ? const Color(0xFF20D5EC) : Colors.white,
                    onTap: _cycleTimer,
                  ),
                  const SizedBox(height: 16),
                  _buildToolButton(
                    icon: Icons.grid_on_rounded,
                    label: 'Kisi',
                    color: camera.isGridOn ? const Color(0xFF20D5EC) : Colors.white,
                    onTap: () {
                      AppAudioService.instance.playPopSound();
                      camera.toggleGrid();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildToolButton(
                    icon: Icons.face_retouching_natural,
                    label: 'Cantik',
                    color: _isBeautyOn ? const Color(0xFFEC4899) : Colors.white,
                    onTap: () {
                      AppAudioService.instance.playChimeSound();
                      setState(() => _isBeautyOn = !_isBeautyOn);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isBeautyOn ? 'Mode Cantik & Retouch Aktif ✨' : 'Mode Cantik Dinonaktifkan'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildToolButton(
                    icon: Icons.mic_none_outlined,
                    label: 'Suara',
                    onTap: () {
                      AppAudioService.instance.playPopSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Efek Mikrofon Studio & Pengurang Bising Aktif 🎙️')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildToolButton(
                    icon: Icons.keyboard_arrow_down,
                    label: '',
                    onTap: () => _showExtraSettings(context),
                  ),
                ],
              ),
            ),
          ),

          // 8. Bottom Controls Section (Duration, Shutter with 4 Filter Bubbles, Gallery, Modes)
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
                  // A. Duration Selector Row: 10 mnt | 60 detik | [ 15 detik ] | FOTO | TEKS
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Stacked Gallery Button (Bottom Left) -> directly triggers native file picker or gallery
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showGallerySheet(context, camera),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Stack card shadow
                              Container(
                                width: 38,
                                height: 38,
                                transform: Matrix4.translationValues(4, -3, 0)..rotateZ(0.08),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              // Front gallery card
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white, width: 1.8),
                                  image: const DecorationImage(
                                    image: AssetImage(AppAssets.imgAndrianPoster),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Filter Circle 1 (Glamour Glow)
                        _buildFaceFilterBubble(1, camera),
                        // Filter Circle 2 (Golden Sun)
                        _buildFaceFilterBubble(2, camera),

                        // Center Shutter Button (TikTok Red Button with Outer White Ring)
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
                                  width: 80,
                                  height: 80,
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
                                          ? 36
                                          : (camera.durationMode == CameraDurationMode.foto ? 64 : 66),
                                      height: camera.isRecording
                                          ? 36
                                          : (camera.durationMode == CameraDurationMode.foto ? 64 : 66),
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

                        // Filter Circle 3 (Soft Hijab Chic)
                        _buildFaceFilterBubble(3, camera),
                        // Filter Circle 4 (Rosy Glam)
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

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationItem(CameraDurationMode mode, String label, CameraProvider camera) {
    final isSelected = camera.durationMode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppAudioService.instance.playPopSound();
        camera.setDurationMode(mode);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFaceFilterBubble(int filterIndex, CameraProvider camera) {
    final filter = _filtersList[filterIndex % _filtersList.length];
    final isSelected = camera.activeFilterIndex == filterIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppAudioService.instance.playPopSound();
        camera.setFilterIndex(filterIndex);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Filter Aktif: ${filter['name']}'),
            duration: const Duration(milliseconds: 900),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF20D5EC) : Colors.white24,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF20D5EC).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: Image.asset(
            filter['avatar'] as String,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: filter['color'] as Color,
              child: const Icon(Icons.face, color: Colors.white, size: 20),
            ),
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
        AppAudioService.instance.playPopSound();
        camera.setBottomTab(tab);
        if (tab == CameraBottomTab.live) {
          _showLiveStartModal(context);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showSoundPicker(BuildContext context, CameraProvider camera) {
    final sounds = [
      '♫ Sound Wisuda Bangga (Original) - andrianpei',
      '♫ Anak Kampung (Remix) - Aurel',
      '♫ Beat Aesthetic Viral 2026 - DJ Mengkane',
      '♫ Pop Up Glow - TikTok Trending',
      '♫ Cinematic Vlog Chill - Lo-Fi Beats',
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
            const Text('Pilih Musik Latar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...sounds.map((sound) => ListTile(
              leading: const Icon(Icons.music_note, color: AppColors.primary),
              title: Text(sound, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
              trailing: camera.selectedSound == sound ? const Icon(Icons.check, color: AppColors.cyan) : null,
              onTap: () {
                AppAudioService.instance.playChimeSound();
                camera.setSound(sound);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showLiveStartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sensors, color: AppColors.primary, size: 48),
            const SizedBox(height: 12),
            const Text('Mulai Siaran LIVE Social Hub', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Interaksi langsung dengan penonton, dapatkan hadiah dan bangun komunitas Anda!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
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

  void _showGallerySheet(BuildContext context, CameraProvider camera) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Unggah Media dari Galeri', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Button to trigger Real File Dialog (Desktop & Phone files)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20D5EC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.file_upload_outlined, color: Colors.black),
                label: const Text('Pilih File Video/Foto dari Perangkat', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.5)),
                onPressed: () {
                  Navigator.pop(context);
                  pickMediaFileNative(
                    onSelected: (fileName, objectUrl, isVideo, thumbnailUrl) {
                      if (!mounted) return;
                      _openPublishPreviewScreen(
                        isVideo: isVideo,
                        selectedVideoUrl: objectUrl,
                        selectedThumb: thumbnailUrl ?? objectUrl ?? (isVideo ? AppAssets.imgFeed : AppAssets.imgProfile),
                        customFileName: fileName,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            const Text('Atau Pilih Media Cepat:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 10),

            // Quick Presets
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _openPublishPreviewScreen(
                        isVideo: true,
                        selectedThumb: AppAssets.imgAndrianPoster,
                        selectedVideoUrl: AppAssets.videoAndrian,
                        initialCaption: 'Wisuda Sarjana Teknik Informatika S1 🎓 IPK 3.73 Wisudawan Terbaik! #wisuda #unpam',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141418),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(AppAssets.imgAndrianPoster, height: 60, width: double.infinity, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 6),
                          const Text('Andrian.MOV\n(Video Wisuda)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _openPublishPreviewScreen(
                        isVideo: true,
                        selectedThumb: AppAssets.imgFeed,
                        selectedVideoUrl: AppAssets.videoLanding,
                        initialCaption: 'Keseruan dance viral hari ini ✨👯‍♀️ #trending #tiktok',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141418),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(AppAssets.imgFeed, height: 60, width: double.infinity, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 6),
                          const Text('Dance Viral\n(Video TikTok)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _openPublishPreviewScreen(
                        isVideo: false,
                        selectedThumb: AppAssets.imgProfile,
                        initialCaption: 'Foto studio portrait Social Hub ✨ #photoshoot',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141418),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(AppAssets.imgProfile, height: 60, width: double.infinity, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 6),
                          const Text('Studio Portrait\n(Foto HD)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
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
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.0;

    double dx = size.width / 3;
    double dy = size.height / 3;

    canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    canvas.drawLine(Offset(dx * 2, 0), Offset(dx * 2, size.height), paint);
    canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    canvas.drawLine(Offset(0, dy * 2), Offset(size.width, dy * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
