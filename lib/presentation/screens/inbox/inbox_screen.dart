import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/presentation/providers/inbox_provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<String> _dismissedSuggestions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = context.read<AuthProvider>().currentUser;
      final userId = user?.id ?? 1;
      context.read<InboxProvider>().loadNotifications(userId);
    });
  }

  void _showAddFriendSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Teman Baru', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppColors.cyan),
              title: const Text('Pindai Kode QR', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka Kamera Pemindai QR...')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primary),
              title: const Text('Undang Teman via WhatsApp', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan undangan disalin ke papan klip!')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityFilter(BuildContext context) {
    final filters = ['Semua Aktivitas', 'Suka & Favorit', 'Komentar', 'Sebutan & Tag', 'Pengikut Baru'];
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
              child: Text('Filter Kotak Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            ...filters.map((f) => ListTile(
              leading: const Icon(Icons.check, color: AppColors.cyan, size: 18),
              title: Text(f, style: const TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menampilkan: $f')));
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDirectMessageChat(BuildContext context) {
    final chatMessages = [
      {'sender': 'them', 'text': 'Halo Andrian! Konten baru kamu keren banget 🔥'},
      {'sender': 'me', 'text': 'Halo! Makasih banyak ya, lagi eksperimen fitur baru nih.'},
      {'sender': 'them', 'text': 'Keren banget, terus berkarya ya bro!'},
    ];
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setChatState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: 480,
              child: Column(
                children: [
                  // Chat Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.avatarPurple,
                          child: Text('a', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('andrianpei', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Aktif sekarang', style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Message List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, idx) {
                        final m = chatMessages[idx];
                        final isMe = m['sender'] == 'me';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : const Color(0xFF2C2C34),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              m['text']!,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Input Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: const Color(0xFF16161A),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: const InputDecoration(
                              hintText: 'Kirim pesan...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: () {
                            final val = textController.text.trim();
                            if (val.isNotEmpty) {
                              setChatState(() {
                                chatMessages.add({'sender': 'me', 'text': val});
                              });
                              textController.clear();
                              AppAudioService.instance.playPopSound();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTakoAiChat(BuildContext context) {
    final takoMessages = [
      {'sender': 'tako', 'text': 'Halo! Saya Tako, asisten AI pintar Social Hub 🤖 Ada yang bisa saya bantu hari ini?'},
      {'sender': 'tako', 'text': 'Kamu bisa bertanya tentang: Cara FYP, Ide Konten Video, atau Rekomendasi Sound Musik Viral!'},
    ];
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setTakoState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: 480,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(color: Color(0xFF20D5EC), shape: BoxShape.circle),
                          child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TikTok Tako AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Asisten Kreator Cerdas', style: TextStyle(color: Color(0xFF20D5EC), fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: takoMessages.length,
                      itemBuilder: (context, idx) {
                        final m = takoMessages[idx];
                        final isMe = m['sender'] == 'me';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : const Color(0xFF242C38),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(m['text']!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: const Color(0xFF16161A),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: const InputDecoration(hintText: 'Tanyakan sesuatu ke Tako AI...', border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF20D5EC)),
                          onPressed: () {
                            final val = textController.text.trim();
                            if (val.isNotEmpty) {
                              setTakoState(() {
                                takoMessages.add({'sender': 'me', 'text': val});
                              });
                              textController.clear();
                              AppAudioService.instance.playPopSound();

                              // Auto reply from Tako
                              Future.delayed(const Duration(milliseconds: 600), () {
                                if (ctx.mounted) {
                                  setTakoState(() {
                                    takoMessages.add({
                                      'sender': 'tako',
                                      'text': 'Tips hebat! Untuk memaksimalkan konten "$val", pastikan 3 detik pertama memikat penonton dengan hook visual yang menarik & gunakan sound trending!'
                                    });
                                  });
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showShopMessages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_bag, color: Color(0xFFF97316), size: 22),
                SizedBox(width: 8),
                Text('Pesan Toko & Pesanan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Color(0xFFF97316), child: Icon(Icons.store, color: Colors.white)),
              title: const Text('Toko Aksesoris Studio Creator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              subtitle: const Text('Pesanan Anda #SH-98124 telah berhasil dikonfirmasi dan siap dikirim!', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Text('25 Okt', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSystemNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Color(0xFF38BDF8), size: 22),
                SizedBox(width: 8),
                Text('Notifikasi Sistem', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Color(0xFF1E293B), child: Icon(Icons.verified_user, color: Color(0xFF38BDF8))),
              title: const Text('Keamanan Akun Terlindungi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              subtitle: const Text('Autentikasi dua faktor berhasil diverifikasi di perangkat iPhone 13.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Text('21 j', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bolt, color: AppColors.primary, size: 22),
                SizedBox(width: 8),
                Text('Aktivitas dan Pengikut Baru', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundImage: AssetImage(AppAssets.imgFeed)),
              title: const Text('Aurelie Hermansyah menyukai video Anda', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              subtitle: const Text('1 jam yang lalu', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              trailing: Container(
                width: 36,
                height: 48,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), image: const DecorationImage(image: AssetImage(AppAssets.imgProfile), fit: BoxFit.cover)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWidgetSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.widgets, color: AppColors.cyan, size: 40),
            const SizedBox(height: 12),
            const Text('Widget Layar Utama iPhone', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tambahkan widget Social Hub ke layar utama iPhone 13 untuk melihat video viral dan pesan masuk seketika!',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Widget Social Hub berhasil disematkan! ✨')));
                },
                child: const Text('Pasang Widget Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
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
          onPressed: () => _showAddFriendSheet(context),
        ),
        title: GestureDetector(
          onTap: () => _showActivityFilter(context),
          child: const Row(
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
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka Pencarian Pesan...')));
            },
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
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka Kamera untuk Cerita Baru!')));
                          },
                          child: _buildStoryItem(
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
                        ),
                        const SizedBox(width: 18),

                        // "+ Widget" item
                        GestureDetector(
                          onTap: () => _showWidgetSettings(context),
                          child: _buildStoryItem(
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Notification Category Items (All Interactive!)
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFFFF2B54),
                    icon: Icons.bolt,
                    title: 'Aktivitas dan pengikut baru',
                    subtitle: 'MPL Indonesia mengundangmu unt...',
                    hasBadge: false,
                    timeLabel: '1 j',
                    onTap: () => _showActivityDetails(context),
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFF162544),
                    icon: Icons.archive_outlined,
                    title: 'Notifikasi sistem',
                    subtitle: 'Asisten transaksi: Saldo akan...',
                    hasBadge: true,
                    timeLabel: '21 j',
                    onTap: () => _showSystemNotifications(context),
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFF20D5EC),
                    icon: Icons.chat_bubble_outline,
                    title: 'TikTok Tako',
                    subtitle: 'Mulainya dari mana?',
                    hasBadge: false,
                    timeLabel: '2 h',
                    onTap: () => _showTakoAiChat(context),
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: const Color(0xFFF97316),
                    icon: Icons.shopping_bag_outlined,
                    title: 'Pesan toko',
                    subtitle: '5 pembaruan toko dan 14...',
                    hasBadge: true,
                    timeLabel: '25 Okt',
                    onTap: () => _showShopMessages(context),
                  ),
                  _buildNotificationCategoryTile(
                    iconBg: AppColors.avatarPurple,
                    icon: Icons.person,
                    title: 'andrianpei',
                    subtitle: 'Terkirim',
                    hasBadge: false,
                    timeLabel: 'Kemarin',
                    isUserAvatar: true,
                    onTap: () => _showDirectMessageChat(context),
                  ),

                  const SizedBox(height: 22),

                  // 3. Saran Akun Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Saran akun',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Akun disarankan berdasarkan teman kontak dan minat Anda.')),
                              );
                            },
                            child: const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Suggested accounts cards
                  if (!_dismissedSuggestions.contains('ei.kaa'))
                    _buildSuggestedAccountItem(
                      id: 'ei.kaa',
                      name: 'ei.kaa🍭',
                      subtitle: 'Membagikan video kepada Anda',
                      avatarPath: AppAssets.imgFriends,
                    ),
                  if (!_dismissedSuggestions.contains('s'))
                    _buildSuggestedAccountItem(
                      id: 's',
                      name: 's',
                      subtitle: 'Orang yang mungkin Anda kenal',
                      avatarPath: AppAssets.imgFriends,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStoryItem({required Widget child, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildNotificationCategoryTile({
    required Color iconBg,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasBadge,
    required String timeLabel,
    required VoidCallback onTap,
    bool isUserAvatar = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isUserAvatar
                    ? const Text('a', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))
                    : Icon(icon, color: Colors.white, size: 26),
              ),
            ),
            if (hasBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.badgeRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: isUserAvatar
            ? const Icon(Icons.camera_alt_outlined, color: Colors.white60, size: 20)
            : Text(
                timeLabel,
                style: const TextStyle(fontSize: 11.5, color: Colors.white38),
              ),
      ),
    );
  }

  Widget _buildSuggestedAccountItem({
    required String id,
    required String name,
    required String subtitle,
    required String avatarPath,
  }) {
    bool isFollowing = false;
    return StatefulBuilder(
      builder: (context, setTileState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(avatarPath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? const Color(0xFF2C2C34) : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    elevation: 0,
                  ),
                  onPressed: () {
                    AppAudioService.instance.playChimeSound();
                    setTileState(() {
                      isFollowing = !isFollowing;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isFollowing ? 'Mengikuti $name ✨' : 'Batal mengikuti $name')),
                    );
                  },
                  child: Text(
                    isFollowing ? 'Mengikuti' : 'Ikuti',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isFollowing ? AppColors.cyan : Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                onPressed: () {
                  setState(() {
                    _dismissedSuggestions.add(id);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
