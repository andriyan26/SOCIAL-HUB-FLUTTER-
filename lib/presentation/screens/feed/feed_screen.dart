import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/feed_provider.dart';
import 'widgets/rotating_music_disc.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/share_sheet.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  int _activeTopTabIndex = 4; // 0: LIVE, 1: Komunitas, 2: Depok, 3: Mengikuti, 4: Saran

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FeedProvider>().loadFeed();
    });
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.asset(AppAssets.videoLanding);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      await _videoController!.play();
      if (mounted) {
        setState(() {
          _isVideoReady = true;
        });
      }
    } catch (e) {
      debugPrint('Feed video fallback: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final posts = feedProvider.posts;

    if (feedProvider.isLoading && posts.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final currentPost = posts.isNotEmpty ? posts.first : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Screen Video Background / Image Asset
          Positioned.fill(
            child: _isVideoReady && _videoController != null
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                : Image.asset(
                    AppAssets.imgFeed,
                    fit: BoxFit.cover,
                  ),
          ),

          // 2. Subtle Gradient Shadow Overlays for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Top Tabs Bar (LIVE, Komunitas, Depok, Mengikuti, Saran + Search)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // LIVE Icon
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka Beranda LIVE...')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 1.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Middle Tabs
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTopTab(1, 'Komunitas'),
                          _buildTopTab(2, 'Depok'),
                          _buildTopTab(3, 'Mengikuti'),
                          _buildTopTab(4, 'Saran'),
                        ],
                      ),
                    ),
                  ),

                  // Search Icon
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 26),
                    onPressed: () {
                      _showSearchDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Right Side Actions (Avatar, Like, Comment, Bookmark, Share, Music Disc)
          if (currentPost != null)
            Positioned(
              right: 12,
              bottom: 110,
              child: Column(
                children: [
                  // Avatar with '+' Follow button
                  _buildAuthorAvatar(currentPost.authorAvatar),
                  const SizedBox(height: 18),

                  // Like button
                  _buildActionButton(
                    icon: currentPost.isLiked ? Icons.favorite : Icons.favorite,
                    iconColor: currentPost.isLiked ? AppColors.primary : Colors.white,
                    label: Formatters.formatCount(currentPost.likesCount),
                    onTap: () => feedProvider.toggleLike(currentPost.id),
                  ),
                  const SizedBox(height: 16),

                  // Comment button
                  _buildActionButton(
                    icon: Icons.chat_bubble,
                    iconColor: Colors.white,
                    label: Formatters.formatThousands(currentPost.commentsCount),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CommentsSheet(
                          postId: currentPost.id,
                          totalComments: currentPost.commentsCount,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bookmark button
                  _buildActionButton(
                    icon: currentPost.isBookmarked ? Icons.bookmark : Icons.bookmark,
                    iconColor: currentPost.isBookmarked ? const Color(0xFFFFD700) : Colors.white,
                    label: Formatters.formatCount(currentPost.bookmarksCount),
                    onTap: () => feedProvider.toggleBookmark(currentPost.id),
                  ),
                  const SizedBox(height: 16),

                  // Share button
                  _buildActionButton(
                    icon: Icons.reply,
                    iconColor: Colors.white,
                    label: Formatters.formatCount(currentPost.sharesCount),
                    isMirrored: true,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ShareSheet(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Rotating Music Disc
                  RotatingMusicDisc(imagePath: currentPost.authorAvatar),
                ],
              ),
            ),

          // 5. Bottom Overlay: Creator info, Caption, Music Ticker, Search recommendation
          if (currentPost != null)
            Positioned(
              left: 14,
              right: 80,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Effect Tag: "Natural Creamy | 2 ∨"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Natural Creamy  |  2 ∨',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author Name with Verified badge
                  Row(
                    children: [
                      Text(
                        currentPost.authorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.check_circle, color: Color(0xFF20D5EC), size: 16),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Caption
                  Text(
                    currentPost.caption,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Music Track ticker
                  Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          currentPost.musicTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search Recommendation Pill (Matches IMG_8664)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 0.6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 14, color: Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          'Pencarian · aurel nangis liat ameena',
                          style: TextStyle(fontSize: 11.5, color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 14, color: Colors.white70),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopTab(int index, String label) {
    final isSelected = _activeTopTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTopTabIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white60,
                shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 28,
                height: 2.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 2.2),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar(String avatarPath) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              avatarPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.avatarPurple,
                child: const Center(
                  child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -7,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isMirrored = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(isMirrored ? 3.14159 : 0),
            child: Icon(
              icon,
              size: 34,
              color: iconColor,
              shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Cari Konten & Kreator', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ketik nama kreator atau tren...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            fillColor: Colors.black.withOpacity(0.3),
          ),
          onSubmitted: (val) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mencari "$val"...')),
            );
          },
        ),
      ),
    );
  }
}
