import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ShareSheet extends StatelessWidget {
  const ShareSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
