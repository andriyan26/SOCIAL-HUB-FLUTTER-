import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/providers/community_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CommunityProvider>().loadFriends();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showContactsSyncModal(BuildContext context) {
    final contacts = [
      {'name': 'Budi Santoso', 'phone': '+62 812-3456-7890', 'isUser': true},
      {'name': 'Dewi Lestari', 'phone': '+62 857-9876-5432', 'isUser': true},
      {'name': 'Kevin Sanjaya', 'phone': '+62 821-1122-3344', 'isUser': false},
      {'name': 'Rizky Billar', 'phone': '+62 813-9988-7766', 'isUser': true},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.contact_phone, color: Color(0xFF10C055), size: 22),
                        SizedBox(width: 8),
                        Text('Kontak Telepon Ditemukan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('4 kontak dari buku telepon Anda menggunakan Social Hub', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 14),
                ...contacts.map((c) {
                  final isUser = c['isUser'] as bool;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isUser ? AppColors.avatarPurple : Colors.grey[700],
                      child: Text((c['name'] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(c['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(c['phone'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUser ? AppColors.primary : const Color(0xFF2E3238),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        AppAudioService.instance.playChimeSound();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isUser ? 'Mengikuti ${c['name']}' : 'Undangan terkirim ke ${c['name']}')),
                        );
                      },
                      child: Text(
                        isUser ? 'Ikuti' : 'Undang',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showUserProfileModal(BuildContext context, String name, String subtitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: const AssetImage(AppAssets.imgFriends),
            ),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () {
                      Navigator.pop(context);
                      AppAudioService.instance.playChimeSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sekarang berteman dengan $name! ✨')),
                      );
                    },
                    child: const Text('Kirim Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final auth = context.watch<AuthProvider>();
    final userAvatar = auth.currentUser?.avatarUrl ?? '';
    final friends = communityProvider.friends;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buka Studio Kamera untuk membuat Status Cerita!')),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.avatarPurple,
                  backgroundImage: (userAvatar.isNotEmpty && userAvatar != 'purple_a' && userAvatar.startsWith('assets/'))
                      ? AssetImage(userAvatar)
                      : null,
                  child: (userAvatar.isEmpty || userAvatar == 'purple_a' || !userAvatar.startsWith('assets/'))
                      ? const Text('a', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
                      : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFF20D5EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: const Text(
          'Teman',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  communityProvider.search('');
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: communityProvider.isLoading && friends.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              onRefresh: () => communityProvider.loadFriends(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Optional Search Bar
                  if (_isSearchVisible) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Cari teman atau username...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        ),
                        onChanged: (val) => communityProvider.search(val),
                      ),
                    ),
                  ],

                  // 1. Sync Contacts Card (Matches IMG_8665)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222228), width: 0.8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Green Contact Icon
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10C055),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.phone_in_talk,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kontak',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Temukan kontak Anda',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Wide Pink "Temukan" button -> Opens contacts sheet
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => _showContactsSyncModal(context),
                            child: const Text(
                              'Temukan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Friends / Suggested Accounts List
                  if (friends.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Tidak ada akun yang ditemukan',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...friends.map((friend) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            // Avatar
                            GestureDetector(
                              onTap: () => _showUserProfileModal(context, friend.name, friend.subtitle),
                              child: const CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.surfaceElevated,
                                backgroundImage: AssetImage(AppAssets.imgFriends),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Name & Subtitle
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showUserProfileModal(context, friend.name, friend.subtitle),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend.name,
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      friend.subtitle,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Action Buttons: "Hapus" & "Ikuti"
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // "Hapus" button
                                SizedBox(
                                  height: 34,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2C2C34),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    onPressed: () {
                                      communityProvider.removeFriend(friend.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Saran teman ${friend.name} dihapus'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // "Ikuti" / "Mengikuti" button
                                SizedBox(
                                  height: 34,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: friend.isFollowing ? const Color(0xFF2C2C34) : AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      AppAudioService.instance.playChimeSound();
                                      communityProvider.toggleFollow(friend.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            friend.isFollowing
                                                ? 'Berhenti mengikuti ${friend.name}'
                                                : 'Mulai mengikuti ${friend.name} ✨',
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (friend.isFollowing) ...[
                                          const Icon(Icons.check, size: 14, color: AppColors.cyan),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          friend.isFollowing ? 'Mengikuti' : 'Ikuti',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: friend.isFollowing ? AppColors.cyan : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
