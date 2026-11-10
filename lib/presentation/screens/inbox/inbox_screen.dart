import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/presentation/providers/inbox_provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/widgets/app_avatar.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<String> _dismissedSuggestions = [];
  final Set<String> _followedUsers = {};
  String _selectedFilter = 'Semua Aktivitas';
  bool _hasCreatedStory = false;
  String _storyText = '';

  // Persistent DM chat messages for andrianpei
  final List<Map<String, String>> _andrianChatMessages = [
    {
      'sender': 'them',
      'text': 'Halo bro! Selamat datang di Social Hub 🚀',
      'time': '10:14',
    },
    {
      'sender': 'them',
      'text': 'Gimana video wisuda Informatika tadi? Keren ga konsepnya? 🎓',
      'time': '10:15',
    },
    {
      'sender': 'me',
      'text': 'Keren banget bro! Tampilannya udah persis kayak TikTok di iPhone 13 🔥',
      'time': '10:18',
    },
    {
      'sender': 'them',
      'text': 'Mantap! Ada yang mau diobrolin lagi tentang fiturnya?',
      'time': '10:20',
    },
  ];

  // Persistent Tako AI messages
  final List<Map<String, String>> _takoMessages = [
    {
      'sender': 'tako',
      'text': 'Halo! Saya Tako, asisten AI pintar Social Hub 🤖 Ada yang bisa saya bantu hari ini?',
      'time': 'Sekarang',
    },
    {
      'sender': 'tako',
      'text': 'Kamu bisa bertanya tentang: Cara FYP, Ide Konten Video, atau Rekomendasi Sound Musik Viral!',
      'time': 'Sekarang',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = context.read<AuthProvider>().currentUser;
      final userId = user?.id ?? 1;
      context.read<InboxProvider>().loadNotifications(userId);
    });
  }

  // 1. Top-Left: Add Friend Sheet
  void _showAddFriendSheet(BuildContext context) {
    AppAudioService.instance.playPopSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text('Tambah Teman & Kontak', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.qr_code_scanner, color: AppColors.cyan, size: 22),
              ),
              title: const Text('Pindai Kode QR Teman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Pindai profil teman untuk langsung terhubung', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka Kamera Pemindai QR Social Hub... 📸')));
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF25D366).withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.share, color: Color(0xFF25D366), size: 22),
              ),
              title: const Text('Undang Teman via WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Bagikan tautan download aplikasi ke teman dekat', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {
                Navigator.pop(context);
                AppAudioService.instance.playChimeSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tautan undangan Social Hub disalin ke papan klip! Siap kirim ke WA 💬')),
                );
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.contacts, color: AppColors.primary, size: 22),
              ),
              title: const Text('Sinkronisasi Kontak Buku Telepon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Temukan kontak tersimpan yang sudah menggunakan Social Hub', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {
                Navigator.pop(context);
                AppAudioService.instance.playChimeSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('48 Teman dari kontak telepon berhasil disinkronkan! ✨')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. Dropdown Category Filter
  void _showActivityFilter(BuildContext context) {
    AppAudioService.instance.playPopSound();
    final filters = [
      {'name': 'Semua Aktivitas', 'icon': Icons.all_inbox_rounded},
      {'name': 'Suka & Favorit', 'icon': Icons.favorite_rounded},
      {'name': 'Komentar', 'icon': Icons.chat_bubble_rounded},
      {'name': 'Sebutan & Tag', 'icon': Icons.alternate_email_rounded},
      {'name': 'Pengikut Baru', 'icon': Icons.person_add_rounded},
      {'name': 'Dari Social Hub', 'icon': Icons.verified_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Filter Kotak Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            ...filters.map((f) {
              final isSelected = _selectedFilter == f['name'];
              return ListTile(
                leading: Icon(f['icon'] as IconData, color: isSelected ? AppColors.primary : Colors.white70, size: 20),
                title: Text(
                  f['name'] as String,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20) : null,
                onTap: () {
                  setState(() {
                    _selectedFilter = f['name'] as String;
                  });
                  Navigator.pop(context);
                  AppAudioService.instance.playPopSound();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Filter aktif: $_selectedFilter'), duration: const Duration(milliseconds: 900)),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // 3. Search Inbox Dialog
  void _showSearchInboxDialog(BuildContext context) {
    AppAudioService.instance.playPopSound();
    final searchController = TextEditingController();
    final recentItems = ['andrianpei', 'TikTok Tako', 'Aktivitas baru', 'Pesan toko', 'ei.kaa🍭'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final query = searchController.text.trim().toLowerCase();
          final filtered = recentItems.where((i) => i.toLowerCase().contains(query)).toList();

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 8),
                Text('Cari Pesan & Notifikasi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama akun atau pesan...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.35),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 14),
                  const Text('Hasil & Obrolan Terkait:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...filtered.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.chat_bubble_outline, color: AppColors.cyan, size: 18),
                    title: Text(item, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (item == 'andrianpei') {
                        _showDirectMessageChat(context, name: 'Andrian Pei', username: 'andrianpei');
                      } else if (item == 'TikTok Tako') {
                        _showTakoAiChat(context);
                      } else if (item == 'Pesan toko') {
                        _showShopMessages(context);
                      } else {
                        _showDirectMessageChat(context, name: item, username: item.replaceAll(RegExp(r'[^\w]'), ''));
                      }
                    },
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Create Story / Status Modal ('Buat' button)
  void _showCreateStorySheet(BuildContext context) {
    AppAudioService.instance.playPopSound();
    final storyController = TextEditingController(text: _storyText);
    int selectedBg = 0;
    final bgGradients = [
      [const Color(0xFFFE2C55), const Color(0xFFF97316)],
      [const Color(0xFF20D5EC), const Color(0xFF3B82F6)],
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
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
                    const Text('Buat Cerita Baru (Story 24 Jam)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 140,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: bgGradients[selectedBg],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: storyController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Tuliskan status atau momen seru kamu hari ini... ✨',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text('Pilih Tema:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 10),
                    ...List.generate(bgGradients.length, (i) {
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedBg = i),
                        child: Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: bgGradients[i]),
                            shape: BoxShape.circle,
                            border: Border.all(color: selectedBg == i ? Colors.white : Colors.transparent, width: 2),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    label: const Text('Bagikan ke Cerita Anda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    onPressed: () {
                      final val = storyController.text.trim();
                      setState(() {
                        _hasCreatedStory = true;
                        _storyText = val.isNotEmpty ? val : 'Lagi seru-seruan di Social Hub! 🚀';
                      });
                      Navigator.pop(ctx);
                      AppAudioService.instance.playChimeSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🎉 Cerita Anda berhasil dibagikan dan tayang selama 24 jam!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 5. Widget Settings Modal (+ Widget)
  void _showWidgetSettings(BuildContext context) {
    AppAudioService.instance.playPopSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.widgets_rounded, color: AppColors.cyan, size: 36),
            ),
            const SizedBox(height: 12),
            const Text('Widget Layar Utama iPhone 13', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Pasang widget interaktif Social Hub di Layar Kunci dan Layar Utama untuk pantau notifikasi, status pesan, dan video viral dalam sekejap!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Widget Feed Trending & Pesan Cepat aktif dan siap disematkan ke iOS Desktop!',
                      style: TextStyle(color: Colors.white, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  AppAudioService.instance.playChimeSound();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Widget Social Hub berhasil dipasang di layar utama! ✨')),
                  );
                },
                child: const Text('Pasang Widget Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Direct Message (DM) Chat with Real-Time Reply Simulation
  void _showDirectMessageChat(BuildContext context, {required String name, required String username}) {
    AppAudioService.instance.playPopSound();
    final textController = TextEditingController();
    final scrollController = ScrollController();
    bool isTyping = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141418),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setChatState) {
          void scrollToBottom() {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            });
          }

          void handleSendMessage(String text) {
            if (text.trim().isEmpty) return;
            final now = DateTime.now();
            final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

            setChatState(() {
              _andrianChatMessages.add({
                'sender': 'me',
                'text': text.trim(),
                'time': timeStr,
              });
              isTyping = true;
            });
            textController.clear();
            AppAudioService.instance.playPopSound();
            scrollToBottom();

            // Intelligent Creator Auto-Reply
            Future.delayed(const Duration(milliseconds: 1100), () {
              if (ctx.mounted) {
                String replyText;
                final lower = text.toLowerCase();
                if (lower.contains('halo') || lower.contains('hai') || lower.contains('pagi') || lower.contains('siang')) {
                  replyText = 'Halo juga bro! Senang bisa ngobrol langsung di sini 🙌';
                } else if (lower.contains('wisuda') || lower.contains('unpam') || lower.contains('sarjana') || lower.contains('ipk')) {
                  replyText = 'Alhamdulillah wisuda kemarin lancar bro! IPK 3.73 berkat doa dan kerja keras 🎓 Terima kasih dukungannya!';
                } else if (lower.contains('keren') || lower.contains('mantap') || lower.contains('bagus') || lower.contains('hebat')) {
                  replyText = 'Makasih banyak apresiasinya! Terus dukung karya-karya kita selanjutnya ya bro 🔥';
                } else if (lower.contains('fitur') || lower.contains('aplikasi') || lower.contains('kamera') || lower.contains('video')) {
                  replyText = 'Semua fiturnya udah lengkap dan responsif banget kan! Sekarang bisa upload foto/video, ganti filter warna, dan kirim pesan lancar 🚀';
                } else {
                  replyText = 'Siap bro! Pesan kamu udah kebaca. Nanti kita collab bikin konten viral berikutnya ya! ✨';
                }

                setChatState(() {
                  isTyping = false;
                  _andrianChatMessages.add({
                    'sender': 'them',
                    'text': replyText,
                    'time': timeStr,
                  });
                });
                AppAudioService.instance.playChimeSound();
                scrollToBottom();
              }
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: 520,
              child: Column(
                children: [
                  // Top DM Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E24),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      children: [
                        AppAvatar(
                          avatarUrl: (username.toLowerCase() == (context.read<AuthProvider>().currentUser?.username ?? 'andrianpei').toLowerCase() || username == 'andrianpei')
                              ? (context.read<AuthProvider>().currentUser?.avatarUrl ?? AppAssets.imgAndrianPoster)
                              : '',
                          size: 38,
                          fallbackInitial: name.isNotEmpty ? name[0].toLowerCase() : 'a',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF20D5EC), size: 14),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  const Text('Aktif sekarang', style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call_outlined, color: Colors.white70, size: 21),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memulai panggilan suara dengan $name... 📞')));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.videocam_outlined, color: Colors.white70, size: 24),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memulai video call dengan $name... 📹')));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Messages ListView
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _andrianChatMessages.length,
                      itemBuilder: (context, idx) {
                        final m = _andrianChatMessages[idx];
                        final isMe = m['sender'] == 'me';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : const Color(0xFF2A2A32),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['text']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  m['time'] ?? 'Sekarang',
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Typing Indicator
                  if (isTyping)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 6),
                      child: Row(
                        children: [
                          const Text('andrianpei sedang mengetik', style: TextStyle(color: Colors.white60, fontSize: 11.5, fontStyle: FontStyle.italic)),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.cyan.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),

                  // Quick Emoji Reactions Bar
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: const Color(0xFF1A1A20),
                    child: Row(
                      children: ['❤️', '🔥', '👏', '😂', '🎓', '🚀', '👍', '💯'].map((emoji) {
                        return GestureDetector(
                          onTap: () => handleSendMessage(emoji),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(emoji, style: const TextStyle(fontSize: 18)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Input Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0xFF1E1E24),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt_rounded, color: AppColors.cyan, size: 22),
                          onPressed: () {
                            handleSendMessage('📷 [Foto Momen Wisuda Terkirim]');
                          },
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: TextField(
                              controller: textController,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              decoration: const InputDecoration(
                                hintText: 'Kirim pesan...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onSubmitted: (val) => handleSendMessage(val),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 22),
                          onPressed: () => handleSendMessage(textController.text),
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

  // 7. Social Hub Tako AI Chatbot
  void _showTakoAiChat(BuildContext context) {
    AppAudioService.instance.playPopSound();
    final textController = TextEditingController();
    final scrollController = ScrollController();
    bool isTakoThinking = false;

    final quickChips = [
      'Bagaimana cara video masuk FYP?',
      'Ide konten viral untuk kreator baru',
      'Sound musik apa yang lagi viral hari ini?',
      'Tips caption wisuda keren',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141418),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setTakoState) {
          void askTako(String prompt) {
            if (prompt.trim().isEmpty) return;
            setTakoState(() {
              _takoMessages.add({'sender': 'me', 'text': prompt.trim()});
              isTakoThinking = true;
            });
            textController.clear();
            AppAudioService.instance.playPopSound();

            Future.delayed(const Duration(milliseconds: 1200), () {
              if (ctx.mounted) {
                String reply;
                final lower = prompt.toLowerCase();
                if (lower.contains('fyp')) {
                  reply = '🚀 **3 Rahasia FYP Social Hub:**\n1. Tangkap perhatian dalam 3 detik pertama dengan visual hook.\n2. Gunakan audio trending seperti *Sound Wisuda Bangga*.\n3. Ajak penonton berkomentar dengan pertanyaan di caption!';
                } else if (lower.contains('ide')) {
                  reply = '💡 **Ide Konten Viral Hari Ini:**\n- Behind the scenes perjalanan kuliah & skripsi 🎓\n- Rekomendasi tempat nongkrong estetik di Depok ☕\n- Tips editing video cepat langsung dari iPhone 13!';
                } else if (lower.contains('sound') || lower.contains('musik')) {
                  reply = '🎵 **Sound Paling Viral Minggu Ini:**\n1. *Sound Wisuda Bangga (Original)* - andrianpei (1.2M video)\n2. *Anak Kampung (Remix)*\n3. *Beat Aesthetic Viral 2026*';
                } else {
                  reply = 'Tako senang kamu bertanya! Untuk ide "$prompt", pastikan kamu konsisten upload pada jam prime time (18.00 - 21.00 WIB) dan gunakan tagar #fyp #socialhub #viral agar jangkauan kontenmu maksimal! ✨';
                }

                setTakoState(() {
                  isTakoThinking = false;
                  _takoMessages.add({'sender': 'tako', 'text': reply});
                });
                AppAudioService.instance.playChimeSound();
              }
            });
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: 520,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E24),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF20D5EC), Color(0xFF0284C7)]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TikTok Tako AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                              Text('Asisten Kreator Cerdas • Siap Membantu', style: TextStyle(color: Color(0xFF20D5EC), fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                  ),

                  // Quick prompt chips
                  Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: quickChips.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () => askTako(quickChips[i]),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF20D5EC).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF20D5EC).withOpacity(0.4)),
                            ),
                            child: Text(quickChips[i], style: const TextStyle(color: Color(0xFF20D5EC), fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ),

                  // Messages List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _takoMessages.length,
                      itemBuilder: (context, idx) {
                        final m = _takoMessages[idx];
                        final isMe = m['sender'] == 'me';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : const Color(0xFF222B38),
                              borderRadius: BorderRadius.circular(16),
                              border: isMe ? null : Border.all(color: Colors.white12),
                            ),
                            child: Text(m['text']!, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35)),
                          ),
                        );
                      },
                    ),
                  ),

                  if (isTakoThinking)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFF20D5EC), size: 14),
                          SizedBox(width: 6),
                          Text('Tako AI sedang berpikir & meracik ide...', style: TextStyle(color: Color(0xFF20D5EC), fontSize: 11.5)),
                        ],
                      ),
                    ),

                  // Input Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    color: const Color(0xFF1E1E24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: TextField(
                              controller: textController,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              decoration: const InputDecoration(
                                hintText: 'Tanyakan sesuatu ke Tako AI...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onSubmitted: (val) => askTako(val),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: Color(0xFF20D5EC)),
                          onPressed: () => askTako(textController.text),
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

  // 8. Shop Messages Sheet
  void _showShopMessages(BuildContext context) {
    AppAudioService.instance.playPopSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded, color: Color(0xFFF97316), size: 24),
                    SizedBox(width: 8),
                    Text('Pesan Toko & Pesanan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: const Color(0xFFF97316).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.local_shipping_rounded, color: Color(0xFFF97316)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pesanan #SH-98124 Dikirim 🚚', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        SizedBox(height: 2),
                        Text('Paket Tripod & Ring Light Studio sedang diantar kurir ke alamat Anda.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.confirmation_number_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voucher Diskon 50% Aktif! 🎟️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        SizedBox(height: 2),
                        Text('Gunakan kode DISKON50K saat checkout produk kreator pilihan Anda.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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

  // 9. System Notifications Sheet
  void _showSystemNotifications(BuildContext context) {
    AppAudioService.instance.playPopSound();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: Color(0xFF38BDF8), size: 24),
                    SizedBox(width: 8),
                    Text('Notifikasi Sistem', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Color(0xFF1E293B), child: Icon(Icons.verified_user_rounded, color: Color(0xFF38BDF8))),
              title: const Text('Keamanan Akun Terlindungi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              subtitle: const Text('Autentikasi dua faktor berhasil diverifikasi di perangkat iPhone 13.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Text('21 j', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),
            const Divider(color: Colors.white10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Color(0xFF1E293B), child: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))),
              title: const Text('Verifikasi Kreator Disetujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
              subtitle: const Text('Selamat! Akun Andrian Pei telah mendapatkan lencana centang biru resmi.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Text('2 hari', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  // 10. Activity & New Followers Details Sheet
  void _showActivityDetails(BuildContext context) {
    AppAudioService.instance.playPopSound();
    final activities = [
      {'user': 'MPL Indonesia', 'desc': 'mengundangmu untuk bergabung ke turnamen kreator 🏆', 'time': '1 jam lalu', 'avatar': AppAssets.imgFriends},
      {'user': 'Aurelie Hermansyah', 'desc': 'menyukai video wisuda Anda ❤️', 'time': '3 jam lalu', 'avatar': AppAssets.imgFeed},
      {'user': 'ei.kaa🍭', 'desc': 'mulai mengikuti akun Anda', 'time': '5 jam lalu', 'avatar': AppAssets.imgFriends},
      {'user': 'Budi Santoso', 'desc': 'memberikan komentar: "Selamat atas kelulusannya bro!"', 'time': 'Kemarin', 'avatar': AppAssets.imgProfile},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text('Aktivitas dan Pengikut Baru', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            ...activities.map((act) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundImage: AssetImage(act['avatar'] as String)),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  children: [
                    TextSpan(text: '${act['user']} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: act['desc'] as String, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              subtitle: Text(act['time'] as String, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  minimumSize: const Size(60, 28),
                ),
                onPressed: () {
                  AppAudioService.instance.playChimeSound();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mengikuti balik ${act['user']} ✨')));
                },
                child: const Text('Ikuti Balik', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inbox = context.watch<InboxProvider>();
    final auth = context.watch<AuthProvider>();
    final userAvatar = auth.currentUser?.avatarUrl ?? '';
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
          behavior: HitTestBehavior.opaque,
          onTap: () => _showActivityFilter(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedFilter == 'Semua Aktivitas' ? 'Kotak Masuk' : _selectedFilter,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: () => _showSearchInboxDialog(context),
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
                  // 1. Top Stories / Widget Row (Buat Story & + Widget)
                  SizedBox(
                    height: 95,
                    child: Row(
                      children: [
                        // "Buat" Status (+ on purple 'a')
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showCreateStorySheet(context),
                          child: _buildStoryItem(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AppAvatar(
                                  avatarUrl: userAvatar,
                                  size: 56,
                                  borderWidth: _hasCreatedStory ? 2.5 : 0,
                                  borderColor: const Color(0xFF20D5EC),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _hasCreatedStory ? const Color(0xFF10B981) : const Color(0xFF20D5EC),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 2),
                                    ),
                                    child: Icon(_hasCreatedStory ? Icons.check : Icons.add, color: Colors.white, size: 12),
                                  ),
                                ),
                              ],
                            ),
                            label: _hasCreatedStory ? 'Lihat Cerita' : 'Buat',
                          ),
                        ),
                        const SizedBox(width: 18),

                        // "+ Widget" item
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
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

                  // 2. Notification Category Items (All 100% Interactive)
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
                    title: auth.currentUser?.username ?? 'andrianpei',
                    subtitle: 'Terkirim',
                    hasBadge: false,
                    timeLabel: 'Kemarin',
                    isUserAvatar: true,
                    onTap: () => _showDirectMessageChat(
                      context,
                      name: auth.currentUser?.name ?? 'Andrian Pei',
                      username: auth.currentUser?.username ?? 'andrianpei',
                    ),
                    onCameraTap: () {
                      _showDirectMessageChat(
                        context,
                        name: auth.currentUser?.name ?? 'Andrian Pei',
                        username: auth.currentUser?.username ?? 'andrianpei',
                      );
                    },
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
                            behavior: HitTestBehavior.opaque,
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

                  // Suggested Account: ei.kaa🍭
                  if (!_dismissedSuggestions.contains('ei.kaa'))
                    _buildSuggestedAccountItem(
                      id: 'ei.kaa',
                      name: 'ei.kaa🍭',
                      subtitle: 'Membagikan video kepada Anda',
                      avatarPath: AppAssets.imgFriends,
                    ),

                  // Suggested Account: s
                  if (!_dismissedSuggestions.contains('s'))
                    _buildSuggestedAccountItem(
                      id: 's',
                      name: 's',
                      subtitle: 'Orang yang mungkin Anda kenal',
                      avatarPath: AppAssets.imgProfile,
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
    VoidCallback? onCameraTap,
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
            isUserAvatar
                ? AppAvatar(
                    avatarUrl: context.watch<AuthProvider>().currentUser?.avatarUrl ?? '',
                    size: 50,
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(icon, color: Colors.white, size: 26),
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
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCameraTap ?? onTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white60, size: 22),
                ),
              )
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
    final isFollowing = _followedUsers.contains(id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showDirectMessageChat(context, name: name, username: id),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(avatarPath),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showDirectMessageChat(context, name: name, username: id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
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
                setState(() {
                  if (isFollowing) {
                    _followedUsers.remove(id);
                  } else {
                    _followedUsers.add(id);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(!isFollowing ? 'Mulai mengikuti $name ✨' : 'Batal mengikuti $name'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                isFollowing ? 'Mengikuti' : 'Ikuti',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isFollowing ? AppColors.cyan : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
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
  }
}
