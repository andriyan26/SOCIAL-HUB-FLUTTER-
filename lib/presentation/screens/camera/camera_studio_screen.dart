import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/presentation/providers/camera_provider.dart';

class CameraStudioScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const CameraStudioScreen({super.key, this.onClose});

  @override
  State<CameraStudioScreen> createState() => _CameraStudioScreenState();
}

class _CameraStudioScreenState extends State<CameraStudioScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = context.watch<CameraProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Viewfinder / Preview
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0C0C0E),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle filter tint based on active filter
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: camera.activeFilterIndex == 0
                            ? [Colors.white.withOpacity(0.04), Colors.black]
                            : [Colors.pink.withOpacity(0.08), Colors.black],
                        radius: 0.9,
                      ),
                    ),
                  ),

                  // Optional Grid Lines
                  if (camera.isGridOn)
                    CustomPaint(
                      size: Size.infinite,
                      painter: _GridPainter(),
                    ),

                  // Center recording indicator / instructions
                  if (camera.isRecording)
                    Positioned(
                      top: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Merekam: 00:${camera.recordedSeconds.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. Top Bar (Close 'X', Add Sound)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close 'X' button
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () {
                      if (widget.onClose != null) {
                        widget.onClose!();
                      } else {
                        Navigator.maybePop(context);
                      }
                    },
                  ),

                  // "Tambah suara" Pill
                  GestureDetector(
                    onTap: () {
                      _showSoundSelector(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
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

                  const SizedBox(width: 44), // Balances close button
                ],
              ),
            ),
          ),

          // 3. Right Tool Panel (Flip, Flash, Timer, Grid, Beauty, Captions)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 14),
                child: Column(
                  children: [
                    _buildToolIcon(
                      icon: Icons.flip_camera_ios,
                      label: '',
                      onTap: () => camera.toggleCameraFacing(),
                    ),
                    const SizedBox(height: 20),
                    _buildToolIcon(
                      icon: camera.isFlashOn ? Icons.flash_on : Icons.flash_off,
                      label: '',
                      color: camera.isFlashOn ? Colors.amber : Colors.white,
                      onTap: () => camera.toggleFlash(),
                    ),
                    const SizedBox(height: 20),
                    _buildToolIcon(
                      icon: Icons.timer,
                      label: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Timer 3s diaktifkan')),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildToolIcon(
                      icon: Icons.grid_view,
                      label: '',
                      color: camera.isGridOn ? AppColors.cyan : Colors.white,
                      onTap: () => camera.toggleGrid(),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        _buildToolIcon(
                          icon: Icons.auto_awesome,
                          label: '',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filter Kecantikan Diaktifkan')),
                            );
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
                    const SizedBox(height: 20),
                    _buildToolIcon(
                      icon: Icons.closed_caption,
                      label: '',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 24),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Controls Section
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
                  const SizedBox(height: 18),

                  // Shutter Button Row flanked by Filter Thumbnails & Gallery
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Gallery Thumbnail preview (bottom left)
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Membuka galeri foto & video...')),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 1.5),
                              image: const DecorationImage(
                                image: AssetImage(AppAssets.imgFeed),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Filter Avatar 1
                        _buildFilterThumb(1, 'assets/images/img_8666.jpg', camera),
                        // Filter Avatar 2
                        _buildFilterThumb(2, 'assets/images/img_8666.jpg', camera),

                        // Center Pulsating Red Record Button
                        GestureDetector(
                          onTap: () => camera.toggleRecording(),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              double scale = camera.isRecording ? 1.0 + (_pulseController.value * 0.1) : 1.0;
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
                                      width: camera.isRecording ? 42 : 68,
                                      height: camera.isRecording ? 42 : 68,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
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

                        // Filter Avatar 3
                        _buildFilterThumb(3, 'assets/images/img_8666.jpg', camera),
                        // Filter Avatar 4
                        _buildFilterThumb(4, 'assets/images/img_8666.jpg', camera),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 12),
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
      child: Icon(icon, color: color, size: 26),
    );
  }

  Widget _buildDurationItem(CameraDurationMode mode, String title, CameraProvider camera) {
    final isSelected = camera.durationMode == mode;
    return GestureDetector(
      onTap: () => camera.setDurationMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 6),
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

  Widget _buildFilterThumb(int index, String assetPath, CameraProvider camera) {
    final isSelected = camera.activeFilterIndex == index;
    return GestureDetector(
      onTap: () => camera.setFilterIndex(index),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white54,
            width: isSelected ? 2.5 : 1.2,
          ),
          image: const DecorationImage(
            image: AssetImage(AppAssets.imgCamera),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab(CameraBottomTab tab, String label, CameraProvider camera) {
    final isSelected = camera.bottomTab == tab;
    return GestureDetector(
      onTap: () => camera.setBottomTab(tab),
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

  void _showPublishDialog(BuildContext context, CameraProvider camera) {
    final captionController = TextEditingController(text: 'Momen seru hari ini! 🚀 #socialhub #fyp');
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
                const Text('Publikasikan Konten', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: captionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Jelaskan video Anda, tambahkan tagar, atau sebut teman...',
                fillColor: const Color(0xFF141418),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
                    thumbnailPath: AppAssets.imgProfile,
                  );
                  if (context.mounted) {
                    context.read<FeedProvider>().addPostToFeed(newPost);
                    Navigator.pop(context); // close sheet
                    if (widget.onClose != null) widget.onClose!(); // return to feed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video berhasil dipublikasikan ke Beranda & Profil! 🔥')),
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
      ..color = Colors.white.withOpacity(0.2)
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

