import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/utils/formatters.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/data/models/post_model.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'widgets/rotating_music_disc.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/share_sheet.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _activeTopTabIndex = 4; // 0: LIVE, 1: Komunitas, 2: Depok, 3: Mengikuti, 4: Saran
  final List<Offset> _heartPositions = [];
  final Set<int> _followedAuthors = {};
  late AnimationController _soundWaveController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _soundWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    Future.microtask(() {
      context.read<FeedProvider>().loadFeed();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _soundWaveController.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details, PostModel post) {
    AppAudioService.instance.playPopSound();
    setState(() {
      _heartPositions.add(details.localPosition);
    });

    if (!post.isLiked) {
      context.read<FeedProvider>().toggleLike(post.id);
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _heartPositions.remove(details.localPosition);
        });
      }
    });
  }

  void _toggleFollowAuthor(int postId, String authorName) {
    AppAudioService.instance.playChimeSound();
    setState(() {
      if (_followedAuthors.contains(postId)) {
        _followedAuthors.remove(postId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Batal mengikuti $authorName'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        _followedAuthors.add(postId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mulai mengikuti $authorName ✨'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _showSoundSheet(BuildContext context, String musicTitle) {
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
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage(AppAssets.imgFeed),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        musicTitle,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text('1.2M Video menggunakan suara ini', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text('Gunakan Suara Ini', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Suara dipilih untuk Studio Kamera! 🎙️')),
                      );
                    },
                  ),
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

    // Default rich fallback posts if empty
    final displayPosts = posts.isNotEmpty
        ? posts
        : [
            PostModel(
              id: 1,
              userId: 2,
              authorName: 'Aurelie Hermansyah',
              authorUsername: 'aurelie.hermansyah',
              authorAvatar: AppAssets.imgFeed,
              videoUrl: AppAssets.videoLanding,
              caption: 'Kalo ini sama kembaran aku👯‍♀️',
              musicTitle: '♫ Berisi: Anak Kampung (T...',
              likesCount: 844300,
              commentsCount: 3322,
              sharesCount: 12300,
              bookmarksCount: 17100,
              isLiked: false,
              isBookmarked: false,
              viewCount: 1520000,
              thumbnailPath: AppAssets.imgFeed,
              createdAt: 'Hari ini',
            ),
            PostModel(
              id: 2,
              userId: 1,
              authorName: 'Andrian Pei',
              authorUsername: 'andrianpei',
              authorAvatar: AppAssets.imgProfile,
              videoUrl: AppAssets.videoLogin,
              caption: 'Behind the scenes shooting konten baru bareng tim Social Hub! 🔥 #creator #fyp',
              musicTitle: '♫ Sound Asli - andrianpei',
              likesCount: 128500,
              commentsCount: 1480,
              sharesCount: 4100,
              bookmarksCount: 9200,
              isLiked: false,
              isBookmarked: false,
              viewCount: 430000,
              thumbnailPath: AppAssets.imgProfile,
              createdAt: 'Kemarin',
            ),
            PostModel(
              id: 3,
              userId: 3,
              authorName: 'ei.kaa🍭',
              authorUsername: 'ei.kaa',
              authorAvatar: AppAssets.imgFriends,
              videoUrl: AppAssets.videoLanding,
              caption: 'Seru banget jalan-jalan sore bareng bestie! Jangan lupa follow dan like ya guys ✨ #friends #vlog',
              musicTitle: '♫ Beat Aesthetic Viral 2026',
              likesCount: 95400,
              commentsCount: 890,
              sharesCount: 2800,
              bookmarksCount: 5600,
              isLiked: false,
              isBookmarked: false,
              viewCount: 280000,
              thumbnailPath: AppAssets.imgFriends,
              createdAt: '2 hari lalu',
            ),
          ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Vertical PageView for TikTok / Reels Feed Swiping
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: displayPosts.length,
            itemBuilder: (context, index) {
              final post = displayPosts[index];
              return _buildFeedItem(post, feedProvider);
            },
          ),

          // 2. Floating Heart Animations on Double Tap
          ..._heartPositions.map((pos) => Positioned(
            left: pos.dx - 45,
            top: pos.dy - 45,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutBack,
              builder: (context, val, child) {
                return Opacity(
                  opacity: (1.0 - val).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -60 * val),
                    child: Transform.scale(
                      scale: 1.25 * val,
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 90,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                      ),
                    ),
                  ),
                );
              },
            ),
          )),

          // 3. Top Tabs Bar (LIVE, Komunitas, Depok, Mengikuti, Saran + Sound + Search)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // LIVE Icon
                  GestureDetector(
                    onTap: () {
                      _showLiveStreamModal(context);
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

                  // Audio Mute/Unmute Equalizer Toggle
                  GestureDetector(
                    onTap: () {
                      AppAudioService.instance.toggleMute();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppAudioService.instance.isMuted ? 'Suara Video Dimatikan' : 'Suara Video Diaktifkan ♫'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24, width: 0.6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppAudioService.instance.isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 16,
                          ),
                          if (!AppAudioService.instance.isMuted) ...[
                            const SizedBox(width: 4),
                            AnimatedBuilder(
                              animation: _soundWaveController,
                              builder: (context, _) {
                                return Row(
                                  children: [
                                    Container(width: 2, height: 6 + (_soundWaveController.value * 6), color: AppColors.cyan),
                                    const SizedBox(width: 2),
                                    Container(width: 2, height: 12 - (_soundWaveController.value * 6), color: AppColors.primary),
                                    const SizedBox(width: 2),
                                    Container(width: 2, height: 8 + (_soundWaveController.value * 4), color: Colors.white),
                                  ],
                                );
                              },
                            ),
                          ],
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
        ],
      ),
    );
  }

  Widget _buildFeedItem(PostModel post, FeedProvider feedProvider) {
    final currentPostInState = feedProvider.posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );
    final isFollowing = _followedAuthors.contains(post.id);

    return GestureDetector(
      onDoubleTapDown: (details) => _onDoubleTap(details, currentPostInState),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A. Full Screen Image Background - ALWAYS Crisp & Full Viewport
          Image.asset(
            post.thumbnailPath.isNotEmpty ? post.thumbnailPath : AppAssets.imgFeed,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),

          // B. High-Fidelity Readability Gradients (Top & Bottom)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.52),
                    Colors.transparent,
                    Colors.black.withOpacity(0.72),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // C. Right Side Action Bar (Flag, Avatar with +, Heart, Comment, Bookmark, Share, Music Disc)
          Positioned(
            right: 12,
            bottom: 75,
            child: Column(
              children: [
                // Flag / Report icon
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan konten terkirim ke moderator.')),
                    );
                  },
                  child: const Icon(Icons.flag_outlined, color: Colors.white70, size: 24),
                ),
                const SizedBox(height: 14),

                // Avatar with '+' Follow button
                _buildAuthorAvatar(
                  currentPostInState.authorAvatar,
                  isFollowing: isFollowing,
                  onFollowTap: () => _toggleFollowAuthor(post.id, currentPostInState.authorName),
                ),
                const SizedBox(height: 18),

                // Like button
                _buildActionButton(
                  icon: currentPostInState.isLiked ? Icons.favorite : Icons.favorite,
                  iconColor: currentPostInState.isLiked ? AppColors.primary : Colors.white,
                  label: Formatters.formatCount(currentPostInState.likesCount),
                  onTap: () {
                    AppAudioService.instance.playPopSound();
                    feedProvider.toggleLike(currentPostInState.id);
                  },
                ),
                const SizedBox(height: 16),

                // Comment button
                _buildActionButton(
                  icon: Icons.chat_bubble,
                  iconColor: Colors.white,
                  label: Formatters.formatThousands(currentPostInState.commentsCount),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentsSheet(
                        postId: currentPostInState.id,
                        totalComments: currentPostInState.commentsCount,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Bookmark button
                _buildActionButton(
                  icon: currentPostInState.isBookmarked ? Icons.bookmark : Icons.bookmark,
                  iconColor: currentPostInState.isBookmarked ? const Color(0xFFFFD700) : Colors.white,
                  label: Formatters.formatCount(currentPostInState.bookmarksCount),
                  onTap: () {
                    AppAudioService.instance.playChimeSound();
                    feedProvider.toggleBookmark(currentPostInState.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(currentPostInState.isBookmarked ? 'Dihapus dari Favorit' : 'Disimpan ke Favorit ✨'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Share button
                _buildActionButton(
                  icon: Icons.reply,
                  iconColor: Colors.white,
                  label: Formatters.formatCount(currentPostInState.sharesCount),
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
                GestureDetector(
                  onTap: () => _showSoundSheet(context, currentPostInState.musicTitle),
                  child: RotatingMusicDisc(imagePath: currentPostInState.authorAvatar),
                ),
              ],
            ),
          ),

          // D. Bottom Left Overlay: Effect Tag, Author Name, Caption, Music Ticker, Search Recommendation
          Positioned(
            left: 14,
            right: 80,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Effect Tag: "Natural Creamy | 2 ∨"
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter Natural Creamy diterapkan!')),
                    );
                  },
                  child: Container(
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
                ),
                const SizedBox(height: 8),

                // Author Name with Verified badge
                Row(
                  children: [
                    Text(
                      currentPostInState.authorName,
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
                  currentPostInState.caption,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 8),

                // Music Track ticker (Clickable)
                GestureDetector(
                  onTap: () => _showSoundSheet(context, currentPostInState.musicTitle),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          currentPostInState.musicTitle,
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
                ),
                const SizedBox(height: 10),

                // Search Recommendation Pill (Clickable)
                GestureDetector(
                  onTap: () => _showSearchDialog(context),
                  child: Container(
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

  Widget _buildAuthorAvatar(String avatarPath, {required bool isFollowing, required VoidCallback onFollowTap}) {
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
          child: GestureDetector(
            onTap: onFollowTap,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isFollowing ? const Color(0xFF10B981) : AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Icon(
                isFollowing ? Icons.check : Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
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

  void _showLiveStreamModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.sensors, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text('Social Hub LIVE Stream', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Tonton siaran langsung ribuan kreator, berikan koin hadiah dan berkomentar langsung secara interaktif!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Jelajahi Siaran LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
