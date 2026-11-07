import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/utils/formatters.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'package:social_hub/presentation/screens/feed/widgets/comments_sheet.dart';
import 'package:social_hub/presentation/screens/feed/widgets/share_sheet.dart';
import 'package:social_hub/presentation/screens/feed/widgets/rotating_music_disc.dart';

class PostDetailReelScreen extends StatefulWidget {
  final List<PostEntity> posts;
  final int initialIndex;

  const PostDetailReelScreen({
    super.key,
    required this.posts,
    this.initialIndex = 0,
  });

  @override
  State<PostDetailReelScreen> createState() => _PostDetailReelScreenState();
}

class _PostDetailReelScreenState extends State<PostDetailReelScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final List<Offset> _heartPositions = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details, PostEntity post) {
    AppAudioService.instance.playPopSound();
    setState(() {
      _heartPositions.add(details.localPosition);
    });

    if (!post.isLiked) {
      context.read<FeedProvider>().toggleLike(post.id);
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _heartPositions.remove(details.localPosition);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.posts.isNotEmpty ? widget.posts : [
      PostEntity(
        id: 1,
        userId: 1,
        authorName: 'Andrian Pei',
        authorUsername: 'andrianpei',
        authorAvatar: AppAssets.imgProfile,
        videoUrl: AppAssets.videoLogin,
        caption: 'Momen seru Social Hub Studio! 🚀 #fyp #socialhub',
        musicTitle: '♫ Sound Asli - andrianpei',
        likesCount: 1420,
        commentsCount: 88,
        sharesCount: 34,
        bookmarksCount: 56,
        isLiked: false,
        isBookmarked: false,
        viewCount: 12000,
        thumbnailPath: AppAssets.imgProfile,
        createdAt: 'Baru saja',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildReelItem(post);
        },
      ),
    );
  }

  Widget _buildReelItem(PostEntity post) {
    final feedProvider = context.watch<FeedProvider>();
    final currentPostInState = feedProvider.posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );

    return GestureDetector(
      onDoubleTapDown: (details) => _onDoubleTap(details, currentPostInState),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High Resolution Video / Photo Background
          Image.asset(
            post.thumbnailPath.isNotEmpty ? post.thumbnailPath : AppAssets.imgProfile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // 2. Gradients for high contrast readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.black.withOpacity(0.75),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 3. Floating Hearts on Double Tap
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
                      scale: 1.2 * val,
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

          // 4. Top App Bar with Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button to Profile
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),

                  // Center title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill, color: AppColors.primary, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Video Kreator',
                          style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Sound Mute Toggle
                  GestureDetector(
                    onTap: () {
                      AppAudioService.instance.toggleMute();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppAudioService.instance.isMuted ? 'Suara Dimatikan' : 'Suara Diaktifkan ♫'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Icon(
                        AppAudioService.instance.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Right Action Bar
          Positioned(
            right: 12,
            bottom: 70,
            child: Column(
              children: [
                // Author Avatar with verified badge
                _buildAuthorAvatar(currentPostInState.authorAvatar),
                const SizedBox(height: 18),

                // Like Button
                _buildActionButton(
                  icon: currentPostInState.isLiked ? Icons.favorite : Icons.favorite_border,
                  iconColor: currentPostInState.isLiked ? AppColors.primary : Colors.white,
                  label: Formatters.formatCount(currentPostInState.likesCount),
                  onTap: () {
                    AppAudioService.instance.playPopSound();
                    feedProvider.toggleLike(currentPostInState.id);
                  },
                ),
                const SizedBox(height: 16),

                // Comment Button
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

                // Bookmark Button
                _buildActionButton(
                  icon: currentPostInState.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
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

                // Share Button
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

                // Rotating Vinyl Disc
                RotatingMusicDisc(imagePath: currentPostInState.authorAvatar),
              ],
            ),
          ),

          // 6. Bottom Creator Information & Music
          Positioned(
            left: 14,
            right: 80,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Author name with verified badge
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

                // Music Track Ticker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note, color: Colors.white, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        currentPostInState.musicTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildAuthorAvatar(String avatarPath) {
    return Container(
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
              size: 32,
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
}
