import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/presentation/providers/inbox_provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = context.read<AuthProvider>().currentUser;
      final userId = user?.id ?? 1;
      context.read<InboxProvider>().loadNotifications(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final inbox = context.watch<InboxProvider>();
    final notifications = inbox.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 24),
          onPressed: () {},
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kotak Masuk',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: inbox.isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final user = context.read<AuthProvider>().currentUser;
                final userId = user?.id ?? 1;
                await inbox.loadNotifications(userId);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // 1. Top Stories / Widget Row (Matches IMG_8667)
                  SizedBox(
                    height: 95,
                    child: Row(
                      children: [
                        // "Buat" Status (+ on purple 'a')
                        _buildStoryItem(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: AppColors.avatarPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('a', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF20D5EC),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                          label: 'Buat',
                        ),
                        const SizedBox(width: 18),

                        // "+ Widget" item
                        _buildStoryItem(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFF28282E),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                          label: '+ Widget',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Notification Category Items (Matches IMG_8667)
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFFFF2B54),
                    icon: Icons.bolt,
                    title: 'Aktivitas dan pengikut baru',
                    subtitle: 'MPL Indonesia mengundangmu unt...',
                    hasBadge: false,
                    timeLabel: '',
                    onTap: () {},
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFF162544),
                    icon: Icons.archive_outlined,
                    title: 'Notifikasi sistem',
                    subtitle: 'Asisten transaksi: Saldo akan...',
                    hasBadge: true,
                    timeLabel: '21 j',
                    onTap: () {},
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFF00C4D6),
                    icon: Icons.forum_outlined,
                    title: 'TikTok Tako',
                    subtitle: 'Mulainya dari mana?',
                    hasBadge: false,
                    timeLabel: '2 h',
                    onTap: () {},
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFFFF9500),
                    icon: Icons.shopping_bag_outlined,
                    title: 'Pesan toko',
                    subtitle: '5 pembaruan toko dan 14...',
                    hasBadge: true,
                    timeLabel: '25 Okt',
                    onTap: () {},
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: AppColors.avatarPurple,
                    icon: null,
                    customLeading: const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.avatarPurple,
                      child: Text('a', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    title: 'andrianpei',
                    subtitle: 'Terkirim',
                    trailingIcon: Icons.camera_alt_outlined,
                    hasBadge: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

                  // 3. Saran Akun Section Header
                  Row(
                    children: [
                      const Text(
                        'Saran akun',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 14, color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Suggested account card 1
                  _buildSuggestedAccount(
                    name: 'ei.kaa🍭',
                    subtitle: 'Membagikan video kepada Anda',
                    avatarUrl: AppAssets.imgFriends,
                  ),
                  const SizedBox(height: 14),

                  // Suggested account card 2
                  _buildSuggestedAccount(
                    name: 's',
                    subtitle: 'Orang yang mungkin Anda kenal',
                    avatarUrl: AppAssets.imgFriends,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStoryItem({required Widget child, required String label}) {
    return Column(
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildNotificationCategoryTile({
    required Color iconBg,
    IconData? icon,
    Widget? customLeading,
    required String title,
    required String subtitle,
    bool hasBadge = false,
    String timeLabel = '',
    IconData? trailingIcon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            customLeading ??
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (timeLabel.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '· $timeLabel',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (hasBadge)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.badgeRed,
                  shape: BoxShape.circle,
                ),
              ),
            if (trailingIcon != null)
              Icon(trailingIcon, color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedAccount({
    required String name,
    required String subtitle,
    required String avatarUrl,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(avatarUrl),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              elevation: 0,
            ),
            onPressed: () {},
            child: const Text('Ikuti', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }
}

