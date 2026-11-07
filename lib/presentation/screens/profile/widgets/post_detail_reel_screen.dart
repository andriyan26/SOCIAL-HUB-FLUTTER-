import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoController;
  bool _isPlaying = true;
  bool _showPauseRipple = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    Future.microtask(() {
      if (mounted) context.read<FeedProvider>().setFeedActive(false);
    });
    _initializeCurrentVideo();
  }

  void _initializeCurrentVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    if (widget.posts.isNotEmpty && _currentIndex < widget.posts.length) {
      final post = widget.posts[_currentIndex];
      final videoUrl = post.videoUrl.isNotEmpty ? post.videoUrl : AppAssets.videoAndrian;

      _videoController = VideoPlayerController.asset(videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            _videoController?.setLooping(true);
            _videoController?.setVolume(AppAudioService.instance.isMuted ? 0.0 : 1.0);
            _videoController?.play();
            setState(() {
              _isPlaying = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
        _showPauseRipple = true;
      } else {
        _videoController!.play();
        _isPlaying = true;
        _showPauseRipple = true;
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _showPauseRipple = false);
        });
      }
    });
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
        authorAvatar: AppAssets.imgAndrianPoster,
        videoUrl: AppAssets.videoAndrian,
        caption: 'Wisuda Sarjana Teknik Informatika S1 🎓 IPK 3.73 Wisudawan Terbaik! #wisuda #unpam',
        musicTitle: '♫ Sound Wisuda Bangga (Original) - andrianpei',
        likesCount: 844300,
        commentsCount: 3322,
        sharesCount: 12300,
        bookmarksCount: 17100,
        isLiked: false,
        isBookmarked: false,
        viewCount: 182000,
        thumbnailPath: AppAssets.imgAndrianPoster,
        createdAt: 'Hari ini',
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
          _initializeCurrentVideo();
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
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayPause,
      onDoubleTapDown: (details) => _onDoubleTap(details, currentPostInState),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Player with fallback to high-resolution poster
          if (_videoController != null && _videoController!.value.isInitialized)
            IgnorePointer(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _videoController!.value.size.width > 0 ? _videoController!.value.size.width : 390,
                  height: _videoController!.value.size.height > 0 ? _videoController!.value.size.height : 844,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          else
            Image.asset(
              post.thumbnailPath.isNotEmpty ? post.thumbnailPath : AppAssets.imgAndrianPoster,
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

          // 3. Tap to pause/play ripple icon
          if (!_isPlaying || _showPauseRipple)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isPlaying ? 0.0 : 0.85,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
            ),

          // 4. Floating Hearts on Double Tap
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

          // 5. Top App Bar with Back Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
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
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),

                    // Center pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill, color: AppColors.primary, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Video Unggahan Profil',
                            style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    // Sound Mute Toggle
                    GestureDetector(
                      onTap: () {
                        AppAudioService.instance.toggleMute();
                        final isMuted = AppAudioService.instance.isMuted;
                        _videoController?.setVolume(isMuted ? 0.0 : 1.0);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isMuted ? 'Suara Dimatikan' : 'Suara Diaktifkan ♫'),
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
          ),

          // 6. Right Action Bar
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

          // 7. Bottom Left Content (Author, Caption, Sound, Search)
          Positioned(
            left: 12,
            right: 80,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Author Name & Blue Verified Badge
                Row(
                  children: [
                    Text(
                      currentPostInState.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, color: Color(0xFF20D5EC), size: 15),
                  ],
                ),
                const SizedBox(height: 8),

                // Caption
                Text(
                  currentPostInState.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 10),

                // Sound Title with Music note icon
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        currentPostInState.musicTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
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
        child: avatarPath.isNotEmpty && avatarPath != 'purple_a' && avatarPath.startsWith('assets/')
            ? Image.asset(
                avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.avatarPurple,
                  child: const Center(
                    child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            : Container(
                color: AppColors.avatarPurple,
                child: const Center(
                  child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
