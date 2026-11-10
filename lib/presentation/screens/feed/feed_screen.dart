import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/utils/formatters.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/widgets/app_avatar.dart';
import 'package:social_hub/presentation/widgets/smart_media_image.dart';
import 'widgets/rotating_music_disc.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/share_sheet.dart';
import 'web_video_silencer.dart';
import 'package:social_hub/core/services/media_store/web_media_store.dart';

class FeedScreen extends StatefulWidget {
  final bool isActive;
  const FeedScreen({super.key, this.isActive = true});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _activeTopTabIndex = 4; // 1: Komunitas, 2: Depok, 3: Mengikuti, 4: Saran (Default FYP)
  final List<Offset> _heartPositions = [];
  final Set<int> _followedAuthors = {};
  late AnimationController _soundWaveController;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = true;
  bool _wasPlayingBeforeLeaving = true;
  int _currentPlayingIndex = 0;
  String _currentVideoUrl = '';
  int? _lastTopPostId;
  int _playRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _soundWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    Future.microtask(() async {
      final feed = context.read<FeedProvider>();
      await feed.loadFeed();
      if (mounted && feed.posts.isNotEmpty) {
        _playVideoForIndex(0, feed.posts);
      }
    });
  }

  @override
  void didUpdateWidget(FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _handleActiveChange(widget.isActive);
    }
  }

  void _handleActiveChange(bool active) {
    if (!active) {
      _wasPlayingBeforeLeaving = _videoController?.value.isPlaying ?? false;
      try {
        _videoController?.setVolume(0.0);
        _videoController?.pause();
      } catch (_) {}
      silenceBackgroundWebVideos();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      silenceBackgroundWebVideos();
      final posts = context.read<FeedProvider>().posts;
      if (posts.isNotEmpty) {
        final targetIndex = _currentPlayingIndex.clamp(0, posts.length - 1);
        final targetPost = posts[targetIndex];
        final targetUrl = targetPost.videoUrl.isNotEmpty ? targetPost.videoUrl : AppAssets.videoAndrian;

        if (_videoController == null || _currentVideoUrl != targetUrl) {
          _playVideoForIndex(targetIndex, posts);
        } else if (_wasPlayingBeforeLeaving) {
          try {
            _videoController?.setVolume(1.0);
            _videoController?.play();
          } catch (_) {}
          if (mounted) {
            setState(() {
              _isPlaying = true;
            });
          }
        }
      }
    }
  }

  Future<void> _playVideoForIndex(int index, List<PostEntity> posts) async {
    if (posts.isEmpty || index < 0 || index >= posts.length) return;
    final post = posts[index];
    String url = post.videoUrl.isNotEmpty ? post.videoUrl : AppAssets.videoAndrian;
    final storedVideoUrl = await WebMediaStore.getPostVideoUrl(post.id);
    if (storedVideoUrl != null && storedVideoUrl.isNotEmpty) {
      url = storedVideoUrl;
    }

    if (_currentPlayingIndex == index &&
        _currentVideoUrl == url &&
        _videoController != null &&
        _isVideoInitialized) {
      if (widget.isActive && !(_videoController!.value.isPlaying)) {
        try {
          await _videoController!.setVolume(1.0);
          await _videoController!.play();
        } catch (_) {}
        if (mounted) setState(() => _isPlaying = true);
      }
      return;
    }

    final int token = ++_playRequestToken;
    _currentPlayingIndex = index;
    _currentVideoUrl = url;

    // 1. Immediately mute and stop existing controller so sound stops in 0ms!
    final oldController = _videoController;
    _videoController = null;
    _isVideoInitialized = false;

    if (oldController != null) {
      try {
        oldController.setVolume(0.0);
        oldController.pause();
      } catch (_) {}
      // Safely dispose old controller in background
      Future.microtask(() async {
        try {
          await oldController.pause();
          await oldController.dispose();
        } catch (_) {}
      });
    }

    // 2. Also silence any stray HTML5 video elements in browser DOM
    silenceBackgroundWebVideos();

    if (mounted) setState(() {});

    try {
      VideoPlayerController newController;
      if (url.startsWith('assets/')) {
        newController = VideoPlayerController.asset(url);
      } else {
        newController = VideoPlayerController.networkUrl(Uri.parse(url));
      }

      await newController.initialize();
      await newController.setLooping(true);

      // Check if user has already scrolled away or left feed while initializing
      if (token != _playRequestToken || !mounted || !widget.isActive) {
        try {
          newController.setVolume(0.0);
          newController.pause();
        } catch (_) {}
        newController.dispose();
        return;
      }

      await newController.setVolume(1.0);

      if (widget.isActive && _isPlaying) {
        await newController.play();
      }

      if (token == _playRequestToken && mounted) {
        setState(() {
          _videoController = newController;
          _isVideoInitialized = true;
          _isPlaying = widget.isActive;
        });
      } else {
        try {
          newController.setVolume(0.0);
          newController.pause();
        } catch (_) {}
        newController.dispose();
      }
    } catch (e) {
      debugPrint('Feed video play notice ($url): $e, fallback asset');
      if (token == _playRequestToken && mounted && widget.isActive) {
        final isDefault = (url == AppAssets.videoAndrian);
        _playFallbackVideo(index, token, isDefaultPost: isDefault);
      }
    }
  }

  Future<void> _playFallbackVideo(int index, int token, {bool isDefaultPost = false}) async {
    try {
      final assetPath = isDefaultPost ? AppAssets.videoAndrian : AppAssets.videoLanding;
      final fallback = VideoPlayerController.asset(assetPath);
      await fallback.initialize();
      await fallback.setLooping(true);

      if (token != _playRequestToken || !mounted || !widget.isActive) {
        try {
          fallback.setVolume(0.0);
          fallback.pause();
        } catch (_) {}
        fallback.dispose();
        return;
      }

      await fallback.setVolume(1.0);
      if (widget.isActive && _isPlaying) {
        await fallback.play();
      }

      if (token == _playRequestToken && mounted) {
        setState(() {
          _videoController = fallback;
          _isVideoInitialized = true;
          _isPlaying = widget.isActive;
        });
      } else {
        try {
          fallback.setVolume(0.0);
          fallback.pause();
        } catch (_) {}
        fallback.dispose();
      }
    } catch (_) {}
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;
    AppAudioService.instance.playPopSound();
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _soundWaveController.dispose();
    try {
      _videoController?.setVolume(0.0);
      _videoController?.pause();
    } catch (_) {}
    _videoController?.dispose();
    silenceBackgroundWebVideos();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details, PostEntity post) {
    AppAudioService.instance.playPopSound();
    setState(() {
      _heartPositions.add(details.localPosition);
    });

    if (!post.isLiked) {
      context.read<FeedProvider>().toggleLike(post.id).then((updated) {
        if (updated != null && mounted) {
          context.read<ProfileProvider>().syncPostState(updated);
        }
      });
    }

    Future.delayed(const Duration(milliseconds: 750), () {
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
                      image: AssetImage(AppAssets.imgAndrianPoster),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
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
    final isFeedActive = feedProvider.isFeedActive && widget.isActive;
    final posts = feedProvider.posts;

    if (posts.isNotEmpty) {
      if (_lastTopPostId != null && posts.first.id != _lastTopPostId) {
        _lastTopPostId = posts.first.id;
        _currentPlayingIndex = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
          _playVideoForIndex(0, posts);
        });
      } else if (_lastTopPostId == null) {
        _lastTopPostId = posts.first.id;
      }
    }

    if (!isFeedActive) {
      if (_videoController != null && (_videoController!.value.isPlaying || _videoController!.value.volume > 0)) {
        try {
          _videoController!.setVolume(0.0);
          _videoController!.pause();
        } catch (_) {}
        silenceBackgroundWebVideos();
      }
    }

    if (feedProvider.isLoading && posts.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final List<PostEntity> displayPosts = posts.isNotEmpty
        ? posts
        : [
            PostEntity(
              id: 1,
              userId: 1,
              authorName: 'Andrian',
              authorUsername: 'andrianpei',
              authorAvatar: AppAssets.imgProfile,
              videoUrl: AppAssets.videoAndrian,
              caption: 'Wisuda Sarjana Teknik Informatika S1 🎓 IPK 3.73 Wisudawan Terbaik! Terima kasih untuk semua dukungannya ✨ #wisuda #unpam #informatika #fyp',
              musicTitle: '♫ Berisi: Sound Wisuda Bangga (Original) - andrianpei',
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
            PostEntity(
              id: 2,
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
            PostEntity(
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

    if (feedProvider.targetPageIndexOnReturn >= 0) {
      final target = feedProvider.targetPageIndexOnReturn;
      feedProvider.clearJumpRequest();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(target);
        }
        _playVideoForIndex(target, displayPosts);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Vertical PageView for TikTok / Reels Feed Swiping with instant mute on scroll
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final page = _pageController.page;
                if (page != null && (page - _currentPlayingIndex).abs() > 0.45) {
                  // Mute current controller so audio never bleeds across slides
                  if (_videoController != null && _videoController!.value.volume > 0) {
                    try {
                      _videoController!.setVolume(0.0);
                    } catch (_) {}
                  }
                }
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                _playVideoForIndex(index, displayPosts);
              },
              itemCount: displayPosts.length,
              itemBuilder: (context, index) {
                final post = displayPosts[index];
                return _buildFeedItem(post, feedProvider, isCurrentItem: index == _currentPlayingIndex);
              },
            ),
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

          // 3. Top Tabs Bar PINNED AT THE VERY TOP beneath Status Bar / Notch
          // Uses balanced Row with proper spacing so LIVE button matches and never crowds tabs
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: SizedBox(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. LIVE Button cleanly positioned on the left
                      _buildLiveButton(context),

                      const SizedBox(width: 8),

                      // 2. Centered Top Tabs (Komunitas, Depok, Mengikuti, Saran) distributed evenly
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTopTab(1, 'Komunitas'),
                            _buildTopTab(2, 'Depok'),
                            _buildTopTab(3, 'Mengikuti'),
                            _buildTopTab(4, 'Saran'),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 3. Search Button on Right
                      _buildSearchButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Subtle Floating Sound Toggle (Mute/Unmute with Live Equalizer)
          Positioned(
            right: 14,
            top: 76,
            child: SafeArea(
              top: true,
              bottom: false,
              child: _buildFloatingSoundToggle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(PostEntity post, FeedProvider feedProvider, {bool isCurrentItem = false}) {
    final currentPostInState = feedProvider.posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );
    final isFollowing = _followedAuthors.contains(post.id);

    final currentUser = context.watch<AuthProvider>().currentUser;
    final isMe = currentPostInState.userId == (currentUser?.id ?? 1) ||
        currentPostInState.authorUsername.toLowerCase() == (currentUser?.username ?? 'andrianpei').toLowerCase() ||
        currentPostInState.authorUsername.toLowerCase() == 'andrianpei';

    final authorAvatar = (isMe && currentUser?.avatarUrl.isNotEmpty == true)
        ? currentUser!.avatarUrl
        : currentPostInState.authorAvatar;

    final authorName = (isMe && currentUser?.name.isNotEmpty == true)
        ? currentUser!.name
        : currentPostInState.authorName;

    final covers = const [
      AppAssets.imgFeed,
      AppAssets.imgFriends,
      AppAssets.imgNotifications,
      AppAssets.imgAndrianPoster,
      AppAssets.imgProfile,
    ];
    final safeFallback = covers[post.id.abs() % covers.length];
    final safeThumb = (post.thumbnailPath.isNotEmpty && (!post.thumbnailPath.startsWith('data:') || post.thumbnailPath.length >= 7500))
        ? post.thumbnailPath
        : safeFallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        // A1. Crisp Poster Image (Always rendered underneath so screen is NEVER black)
        SmartMediaImage(
          pathOrUrl: safeThumb,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        ),

        // A2. Video Player for current active post
        // Wrapped with IgnorePointer so native HTML element does NOT swallow Flutter taps or trigger Edge PiP toolbar
        if (isCurrentItem && _isVideoInitialized && _videoController != null)
          IgnorePointer(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width > 0 ? _videoController!.value.size.width : 390,
                  height: _videoController!.value.size.height > 0 ? _videoController!.value.size.height : 844,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          ),

        // B. High-Fidelity Readability Gradients (Top & Bottom)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                    Colors.black.withOpacity(0.82),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),
        ),

        // C. Direct Full-Screen Tap-To-Pause / Double-Tap-To-Like Detector Layer
        // Guarantees 100% reliable pause/play response when tapping anywhere on the video
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isCurrentItem ? _togglePlayPause : null,
            onDoubleTapDown: (details) => _onDoubleTap(details, currentPostInState),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Pause Indicator in Center when video is paused
        if (isCurrentItem && !_isPlaying)
          Center(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.75, end: 1.0),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 16),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // D. Right Side Action Bar (Flag, Avatar with +, Heart, Comment, Bookmark, Share, Music Disc)
        Positioned(
          right: 10,
          bottom: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Flag / Report icon
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan konten terkirim ke tim moderasi Social Hub.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.outlined_flag_rounded,
                    color: Colors.white70,
                    size: 25,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Avatar with '+' Follow button
              _buildAuthorAvatar(
                authorAvatar,
                isFollowing: isFollowing,
                onFollowTap: () => _toggleFollowAuthor(post.id, authorName),
              ),
              const SizedBox(height: 16),

              // 3. Like button
              _buildActionButton(
                icon: Icons.favorite,
                iconColor: currentPostInState.isLiked ? AppColors.primary : Colors.white,
                label: Formatters.formatCount(currentPostInState.likesCount),
                onTap: () async {
                  AppAudioService.instance.playPopSound();
                  final updated = await feedProvider.toggleLike(currentPostInState.id);
                  if (updated != null && context.mounted) {
                    context.read<ProfileProvider>().syncPostState(updated);
                  }
                },
              ),
              const SizedBox(height: 14),

              // 4. Comment button
              _buildActionButton(
                icon: Icons.chat_bubble_rounded,
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
              const SizedBox(height: 14),

              // 5. Bookmark button
              _buildActionButton(
                icon: Icons.bookmark_rounded,
                iconColor: currentPostInState.isBookmarked ? const Color(0xFFFFD700) : Colors.white,
                label: Formatters.formatCount(currentPostInState.bookmarksCount),
                onTap: () async {
                  AppAudioService.instance.playChimeSound();
                  final updated = await feedProvider.toggleBookmark(currentPostInState.id);
                  if (updated != null && context.mounted) {
                    context.read<ProfileProvider>().syncPostState(updated);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(currentPostInState.isBookmarked ? 'Dihapus dari Favorit' : 'Disimpan ke Favorit ✨'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 6. Share button
              _buildActionButton(
                icon: Icons.reply_rounded,
                iconColor: Colors.white,
                label: Formatters.formatCount(currentPostInState.sharesCount),
                isMirrored: true,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ShareSheet(post: currentPostInState),
                  );
                },
              ),
              const SizedBox(height: 18),

              // 7. Rotating Music Disc
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showSoundSheet(context, currentPostInState.musicTitle),
                child: RotatingMusicDisc(imagePath: authorAvatar),
              ),
            ],
          ),
        ),

        // E. Bottom Left Overlay: Effect Tag, Author Name, Caption, Music Ticker, Search Recommendation
        Positioned(
          left: 14,
          right: 84,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Effect Tag matching Reference: "[ 🌟 Natural Creamy | 2 ⌵ ]"
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter Natural Creamy diterapkan! ✨'), duration: Duration(seconds: 1)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.42),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Natural Creamy  |  2 ⌵',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 2. Author Name with Verified badge
              Row(
                children: [
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF20D5EC), size: 15),
                ],
              ),
              const SizedBox(height: 5),

              // 3. Dynamic Caption formatted cleanly with hashtag highlighting
              Builder(
                builder: (context) {
                  final captionText = currentPostInState.caption.isNotEmpty
                      ? currentPostInState.caption
                      : 'Momen seru di Social Hub! ✨ #fyp';
                  final words = captionText.split(' ');
                  return RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.25,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                      ),
                      children: words.map((word) {
                        final isTag = word.startsWith('#');
                        return TextSpan(
                          text: '$word ',
                          style: TextStyle(
                            fontWeight: isTag ? FontWeight.bold : FontWeight.normal,
                            color: isTag ? Colors.white : Colors.white.withOpacity(0.95),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),

              // 4. Music Track ticker (Clickable)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showSoundSheet(context, currentPostInState.musicTitle),
                child: Row(
                  children: [
                    const Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        currentPostInState.musicTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 5. Search Recommendation Pill (Clickable)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showSearchDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.48),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 0.6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 13.5, color: Colors.white70),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Pencarian · ${authorName.toLowerCase()} ${currentPostInState.caption.isNotEmpty ? currentPostInState.caption.split(' ').take(3).join(' ') : 'fyp'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showLiveStreamModal(context),
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.28),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.live_tv_rounded, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(color: Colors.black87, blurRadius: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTab(int index, String label) {
    final isSelected = _activeTopTabIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _activeTopTabIndex = index);
        AppAudioService.instance.playPopSound();
        if (index == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feed Komunitas Terkini'), duration: Duration(milliseconds: 900)),
          );
        } else if (index == 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feed Sekitar Depok (Lokasi Terdekat) 📍'), duration: Duration(milliseconds: 900)),
          );
        } else if (index == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feed Akun yang Anda Ikuti'), duration: Duration(milliseconds: 900)),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.65),
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: isSelected ? 24 : 0,
            height: 2.5,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showSearchDialog(context),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(
          Icons.search_rounded,
          color: Colors.white,
          size: 25,
          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildFloatingSoundToggle() {
    final isMuted = AppAudioService.instance.isMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppAudioService.instance.toggleMute();
        if (_videoController != null && _isVideoInitialized) {
          _videoController!.setVolume(AppAudioService.instance.isMuted ? 0.0 : 1.0);
        }
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppAudioService.instance.isMuted ? 'Suara Video Dimatikan 🔇' : 'Suara Video Diaktifkan 🔊♫'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.42),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 13,
            ),
            if (!isMuted) ...[
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _soundWaveController,
                builder: (context, _) {
                  return Row(
                    children: [
                      Container(width: 1.8, height: 4 + (_soundWaveController.value * 5), color: AppColors.cyan),
                      const SizedBox(width: 1.5),
                      Container(width: 1.8, height: 9 - (_soundWaveController.value * 4), color: AppColors.primary),
                      const SizedBox(width: 1.5),
                      Container(width: 1.8, height: 6 + (_soundWaveController.value * 3), color: Colors.white),
                    ],
                  );
                },
              ),
            ],
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
        AppAvatar(
          avatarUrl: avatarPath,
          size: 48,
          borderWidth: 1.5,
          borderColor: Colors.white,
        ),
        Positioned(
          bottom: -7,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onFollowTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(isMirrored ? 3.14159 : 0),
            child: Icon(
              icon,
              size: 32,
              color: iconColor,
              shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(AppAssets.imgProfile),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Andrian Pei • LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        SizedBox(height: 2),
                        Text('Q&A Wisuda & Karir Software Engineer 🚀', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.play_circle_fill, color: AppColors.primary, size: 30),
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Jelajahi Semua LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Cari di Social Hub', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ketik nama kreator, video, atau tagar...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                filled: true,
                fillColor: Colors.black.withOpacity(0.35),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onSubmitted: (val) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mencari "$val"... ✨')),
                );
              },
            ),
            const SizedBox(height: 14),
            const Text('Tren Populer:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                '#wisuda2026',
                '#wisudawanterbaik',
                '#informatika',
                '#andrianpei',
                '#socialhub',
              ].map((tag) => GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mencari $tag... ✨')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
