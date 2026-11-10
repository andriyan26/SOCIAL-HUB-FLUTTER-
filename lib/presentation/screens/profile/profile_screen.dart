import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/utils/formatters.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/screens/landing/landing_screen.dart';
import 'package:social_hub/presentation/widgets/app_avatar.dart';
import 'package:social_hub/presentation/widgets/smart_media_image.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/post_detail_reel_screen.dart';

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
      context.read<ProfileProvider>().loadProfileData(userId);
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
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka Pengaturan & Privasi...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_mosaic_outlined, color: Color(0xFF20D5EC)),
              title: const Text('TikTok Studio / Alat Kreator', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka Analitik & Alat Kreator...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2, color: Colors.white),
              title: const Text('Kode QR Saya', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showQrDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF7B500)),
              title: const Text('Saldo & Koin Rewards', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showCoinRewards(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.white),
              title: const Text('Keamanan & Autentikasi', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status Keamanan: Terproteksi PIN & Sandi')),
                );
              },
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

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Center(
          child: Text('Kode QR Profil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code_rounded, size: 160, color: Colors.black),
            ),
            const SizedBox(height: 14),
            const Text('@andrianpei', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('Pindai untuk mengikuti saya di Social Hub', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showCoinRewards(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFF7B500),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('P', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Social Hub Points', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Saldo Koin: 2.450 Poin (Rp 245.000)', style: TextStyle(color: AppColors.cyan, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            const Text('Gunakan poin untuk mengirim Hadiah LIVE kepada kreator favorit atau tukarkan dengan saldo dompet!',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7B500), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Isi Ulang Koin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisitorsSheet(BuildContext context) {
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
            const Text('Kunjungan Profil (30 Hari Terakhir)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Hanya Anda yang dapat melihat riwayat pengunjung ini', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            _buildVisitorTile('Aurelie Hermansyah', 'assets/images/img_8664.jpg', '2 jam lalu'),
            _buildVisitorTile('ei.kaa🍭', 'assets/images/img_8665.jpg', 'Kemarin'),
            _buildVisitorTile('annisasabila13', 'assets/images/img_8667.jpg', '2 hari lalu'),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorTile(String name, String avatar, String time) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(avatar)),
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
        child: const Text('Ikuti Balik', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showOrdersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('📦', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text('Pesanan & Transaksi TikTok Shop', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF141418), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: AppColors.cyan, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wireless Mic Studio Creator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        SizedBox(height: 3),
                        Text('Status: Sedang Dikirim oleh Kurir J&T', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temukan Teman', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF10C055),
                child: Icon(Icons.contacts, color: Colors.white, size: 22),
              ),
              title: const Text('Kontak Telepon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Temukan teman dari buku kontak Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menyinkronkan kontak telepon...')),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1877F2),
                child: Icon(Icons.facebook, color: Colors.white, size: 22),
              ),
              title: const Text('Teman Facebook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Hubungkan akun Facebook untuk melihat teman', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menghubungkan akun Facebook...')),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.share, color: Colors.white, size: 20),
              ),
              title: const Text('Undang Teman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Bagikan tautan profil Anda ke WhatsApp/Instagram', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tautan profil disalin ke clipboard!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSwitcher(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final userAvatar = user?.avatarUrl ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Beralih Akun', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ListTile(
              leading: AppAvatar(
                avatarUrl: userAvatar,
                size: 40,
              ),
              title: Text(user?.username ?? 'andrianpei', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Akun Utama (Aktif)', style: TextStyle(color: AppColors.cyan, fontSize: 12)),
              trailing: const Icon(Icons.check_circle, color: AppColors.cyan),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Tambah Akun Baru', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka formulir pendaftaran akun baru...')),
                );
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
    final selectedSubTab = profileProvider.selectedSubTab;

    final publicPosts = profileProvider.userPosts;
    final privatePosts = profileProvider.privatePosts;
    final repostedPosts = profileProvider.repostedPosts;
    final bookmarkedPosts = profileProvider.bookmarkedPosts;
    final likedPosts = profileProvider.likedPosts;

    final displayName = user?.username ?? 'andrianpei';
    final bioText = user?.bio.isNotEmpty == true ? user!.bio : 'Taken 🤍';
    final userAvatar = user?.avatarUrl ?? '';

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
            GestureDetector(
              onTap: () => _showCoinRewards(context),
              child: Container(
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
            ),
          ],
        ),
        leadingWidth: 70,
        title: GestureDetector(
          onTap: () => _showAccountSwitcher(context),
          child: Row(
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
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 22),
            onPressed: () => _showVisitorsSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined, color: Colors.white, size: 22),
            onPressed: () => _showAddFriendsSheet(context),
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

            // Profile Header Row: Details on left, Dynamic Avatar on right
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
                          user?.name.isNotEmpty == true ? user!.name : 'Andrian Pei',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 3),
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
                            GestureDetector(
                              onTap: () => _showOrdersSheet(context),
                              child: Container(
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

                  // Right Side: Big Circular Avatar that syncs across entire app
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const EditProfileSheet(),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AppAvatar(
                          avatarUrl: userAvatar,
                          size: 96,
                          borderWidth: 3,
                          borderColor: const Color(0xFF20D5EC),
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

            // Sub-Tab Content Rendering
            if (selectedSubTab == 0) ...[
              // Tab 0: Clean 3-Column Video Grid showing Public uploaded video(s)
              if (publicPosts.isEmpty)
                _buildEmptyTabState(
                  icon: Icons.videocam_outlined,
                  title: 'Belum Ada Video Publik',
                  description: 'Unggah video pertama Anda lewat tombol Kamera di menu bawah.',
                )
              else
                _buildPostGrid(publicPosts, countIcon: Icons.play_arrow_outlined),
            ] else if (selectedSubTab == 1) ...[
              // Tab 1: Private (Locked) Videos
              if (privatePosts.isEmpty)
                _buildEmptyTabState(
                  icon: Icons.lock_outline,
                  title: 'Video Pribadi Anda',
                  description: 'Hanya Anda yang dapat melihat video di tab ini. Anda dapat mengunci video kapan saja lewat menu Bagikan.',
                )
              else
                _buildPostGrid(privatePosts, countIcon: Icons.lock_outline),
            ] else if (selectedSubTab == 2) ...[
              // Tab 2: Reposted Videos
              if (repostedPosts.isEmpty)
                _buildEmptyTabState(
                  icon: Icons.repeat,
                  title: 'Posting Ulang Video',
                  description: 'Posting ulang video kreator favorit Anda untuk merekomendasikannya ke teman dan pengikut.',
                )
              else
                _buildPostGrid(repostedPosts, countIcon: Icons.repeat),
            ] else if (selectedSubTab == 3) ...[
              // Tab 3: Favorit & Koleksi (Bookmarks)
              if (bookmarkedPosts.isEmpty)
                _buildEmptyTabState(
                  icon: Icons.bookmark_outline,
                  title: 'Favorit & Koleksi',
                  description: 'Semua postingan yang Anda simpan sebagai favorit di Beranda akan dikelompokkan di sini.',
                )
              else
                _buildPostGrid(bookmarkedPosts, countIcon: Icons.bookmark_outline),
            ] else if (selectedSubTab == 4) ...[
              // Tab 4: Disukai / Liked Videos
              if (likedPosts.isEmpty)
                _buildEmptyTabState(
                  icon: Icons.favorite_outline,
                  title: 'Hanya Anda yang dapat melihat tab ini',
                  description: 'Video yang Anda sukai dirahasiakan dari publik. Ketuk ikon Love di Beranda untuk menyukai video.',
                )
              else
                _buildPostGrid(likedPosts, countIcon: Icons.favorite, useLikeCount: true),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPostGrid(List<PostEntity> list, {IconData countIcon = Icons.play_arrow_outlined, bool useLikeCount = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 0.78,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final post = list[index];
        final countLabel = useLikeCount
            ? Formatters.formatCompactK(post.likesCount)
            : Formatters.formatCompactK(post.viewCount > 0 ? post.viewCount : post.likesCount);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailReelScreen(
                  posts: list,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video thumbnail image
              SmartMediaImage(
                pathOrUrl: post.thumbnailPath.isNotEmpty ? post.thumbnailPath : AppAssets.imgAndrianPoster,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),

              // Dark bottom gradient for count readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Bottom left count badge
              Positioned(
                left: 6,
                bottom: 6,
                child: Row(
                  children: [
                    Icon(countIcon, color: countIcon == Icons.favorite ? AppColors.primary : Colors.white, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      countLabel,
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
    );
  }

  Widget _buildEmptyTabState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
        ],
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
}
