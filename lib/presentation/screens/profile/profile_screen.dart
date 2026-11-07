import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../landing/landing_screen.dart';
import 'widgets/edit_profile_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = context.read<AuthProvider>().currentUser;
      final userId = user?.id ?? 1;
      context.read<ProfileProvider>().loadUserPosts(userId);
    });
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white),
              title: const Text('Pengaturan dan Privasi', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.white),
              title: const Text('Kode QR Saya', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.primary),
              title: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final auth = context.read<AuthProvider>();
                await auth.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LandingScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = auth.currentUser;
    final posts = profileProvider.userPosts;

    final displayName = user?.username ?? 'andrianpei';
    final bioText = user?.bio.isNotEmpty == true ? user!.bio : 'Taken 🤍';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const EditProfileSheet(),
                );
              },
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 8),
            // Yellow 'P' coin badge
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFF7B500),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('P', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
        leadingWidth: 70,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              displayName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onPressed: () => _showSettingsMenu(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Header Row: Details on left, Avatar on right (Matches IMG_8668)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Handle, Stats, Bio, Order button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@$displayName',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),

                        // Stats Row: 0 Mengikuti, 0 Pengikut, 0 Suka
                        Row(
                          children: [
                            _buildStatItem('${user?.followingCount ?? 0}', 'Mengikuti'),
                            const SizedBox(width: 20),
                            _buildStatItem('${user?.followersCount ?? 0}', 'Pengikut'),
                            const SizedBox(width: 20),
                            _buildStatItem('${user?.likesCount ?? 0}', 'Suka'),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Bio: "Taken 🤍"
                        Text(
                          bioText,
                          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons: "🛍️ Pesanan Anda" & "Edit Profil"
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E24),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFF2C2C34)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🛍️', style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Pesanan Anda',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const EditProfileSheet(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E24),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFF2C2C34)),
                                ),
                                child: const Text(
                                  'Edit Profil',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right Side: Big Circular Avatar with Purple 'a' + Blue Plus Button
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.avatarPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'a',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF20D5EC),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2.5),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Profile Sub-Tabs (Grid, Lock, Repost, Bookmark, Heart)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubTab(0, Icons.grid_on),
                _buildSubTab(1, Icons.lock_outline),
                _buildSubTab(2, Icons.repeat),
                _buildSubTab(3, Icons.bookmark_outline),
                _buildSubTab(4, Icons.favorite_outline),
              ],
            ),
            const Divider(color: AppColors.border, height: 1),

            // 3-Column Video Grid (Matches IMG_8668)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.5,
                mainAxisSpacing: 1.5,
                childAspectRatio: 0.78,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () {
                    _showPostDetail(context, post.caption, post.musicTitle);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video thumbnail image
                      Image.asset(
                        AppAssets.imgProfile,
                        fit: BoxFit.cover,
                        alignment: _getGridAlignment(index),
                      ),

                      // Dark bottom gradient for view count readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Bottom left Play count icon and number (Matches '▷ 0')
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Row(
                          children: [
                            const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              '${post.viewCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSubTab(int index, IconData icon) {
    final isSelected = context.watch<ProfileProvider>().selectedSubTab == index;
    return GestureDetector(
      onTap: () => context.read<ProfileProvider>().setSelectedSubTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Alignment _getGridAlignment(int index) {
    // Distribute crops nicely across the 9 grid items
    final x = (index % 3) == 0 ? -1.0 : ((index % 3) == 1 ? 0.0 : 1.0);
    final y = (index ~/ 3) == 0 ? -1.0 : ((index ~/ 3) == 1 ? 0.0 : 1.0);
    return Alignment(x, y);
  }

  void _showPostDetail(BuildContext context, String caption, String music) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Detail Postingan', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(AppAssets.imgProfile, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(caption, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 6),
            Text(music, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
