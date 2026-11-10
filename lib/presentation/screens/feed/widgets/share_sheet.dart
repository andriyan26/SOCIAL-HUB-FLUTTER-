import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';

class ShareSheet extends StatelessWidget {
  final PostEntity? post;
  const ShareSheet({super.key, this.post});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? 1;
    final isMe = post != null && (post!.userId == currentUserId || post!.authorUsername == 'andrianpei');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bagikan ke',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Friends Row
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _buildShareUser('ei.kaa🍭', 'assets/images/img_8665.jpg'),
                  _buildShareUser('s', 'assets/images/img_8665.jpg'),
                  _buildShareUser('Angsuran17', 'assets/images/img_8665.jpg'),
                  _buildShareUser('annisasabila', 'assets/images/img_8665.jpg'),
                  _buildShareUser('gasss', 'assets/images/img_8665.jpg'),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 24),

            // Share Action Buttons Row
            SizedBox(
              height: 75,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  // 1. Repost Button (Posting Ulang)
                  _buildActionIcon(
                    Icons.repeat,
                    post?.isReposted == true ? 'Batal Repost' : 'Posting Ulang',
                    const Color(0xFFFFD700),
                    () async {
                      Navigator.pop(context);
                      if (post != null) {
                        final feed = context.read<FeedProvider>();
                        final updated = await feed.toggleRepost(post!.id);
                        if (updated != null && context.mounted) {
                          context.read<ProfileProvider>().syncPostState(updated);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              updated?.isReposted == true
                                  ? '🎉 Berhasil memposting ulang video! Tersimpan di tab Posting Ulang.'
                                  : 'Batal memposting ulang video.',
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // 2. Lock / Unlock Privacy (for user's own post)
                  if (isMe)
                    _buildActionIcon(
                      post!.isPrivate ? Icons.lock_open : Icons.lock_outline,
                      post!.isPrivate ? 'Jadikan Publik' : 'Kunci Video',
                      const Color(0xFF20D5EC),
                      () async {
                        Navigator.pop(context);
                        final feed = context.read<FeedProvider>();
                        final updated = await feed.togglePrivate(post!.id);
                        if (updated != null && context.mounted) {
                          context.read<ProfileProvider>().syncPostState(updated);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              updated?.isPrivate == true
                                  ? '🔒 Video berhasil dikunci dan dipindahkan ke tab Video Pribadi.'
                                  : '🌐 Video berhasil dibuka ke tab Publik.',
                            ),
                          ),
                        );
                      },
                    ),

                  _buildActionIcon(Icons.link, 'Salin Tautan', Colors.blue, () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tautan berhasil disalin ke clipboard!')),
                    );
                  }),
                  _buildActionIcon(Icons.send, 'WhatsApp', Colors.green, () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka WhatsApp...')),
                    );
                  }),
                  _buildActionIcon(Icons.download, 'Simpan Video', Colors.teal, () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video berhasil diunduh ke galeri!')),
                    );
                  }),
                  _buildActionIcon(Icons.qr_code, 'Kode QR', Colors.purple, () {
                    Navigator.pop(context);
                  }),
                  _buildActionIcon(Icons.flag_outlined, 'Laporkan', Colors.red, () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan Anda telah dikirim untuk ditinjau.')),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareUser(String name, String avatar) {
    return Container(
      width: 65,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(avatar),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

