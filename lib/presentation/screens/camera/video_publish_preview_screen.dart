import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:social_hub/core/constants/app_colors.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/app_audio_service.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/presentation/providers/auth_provider.dart';
import 'package:social_hub/presentation/providers/feed_provider.dart';
import 'package:social_hub/presentation/providers/profile_provider.dart';
import 'package:social_hub/presentation/widgets/app_avatar.dart';
import 'package:social_hub/presentation/widgets/smart_media_image.dart';
import 'package:social_hub/core/services/media_store/web_media_store.dart';

class VideoPublishPreviewScreen extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isVideo;
  final String? initialCaption;
  final String? customFileName;
  final String soundTitle;
  final VoidCallback onPublishSuccess;
  final VoidCallback onBackToCamera;

  const VideoPublishPreviewScreen({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isVideo,
    this.initialCaption,
    this.customFileName,
    required this.soundTitle,
    required this.onPublishSuccess,
    required this.onBackToCamera,
  });

  @override
  State<VideoPublishPreviewScreen> createState() => _VideoPublishPreviewScreenState();
}

class _VideoPublishPreviewScreenState extends State<VideoPublishPreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = true;
  bool _isPublishing = false;
  late TextEditingController _captionController;
  String? _selectedFilterName;

  final List<String> _quickHashtags = [
    '#fyp',
    '#trending',
    '#socialhub',
    '#wisuda',
    '#viral',
    '#aesthetic',
    '#bestie',
    '#vlog',
  ];

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(
      text: widget.initialCaption ??
          (widget.isVideo
              ? 'Momen seru video baru di Social Hub! 🚀 #socialhub #fyp #viral'
              : 'Hasil jepretan kamera terbaru! ✨ #aesthetic #photo #fyp'),
    );

    if (widget.isVideo) {
      _initVideoPlayer();
    }
  }

  Future<void> _initVideoPlayer() async {
    try {
      final url = widget.videoUrl.isNotEmpty ? widget.videoUrl : AppAssets.videoAndrian;

      if (url.startsWith('assets/')) {
        _videoController = VideoPlayerController.asset(url);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        // Fallback to local asset if blob or custom URI cannot be decoded by video_player_web
        try {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        } catch (_) {
          _videoController = VideoPlayerController.asset(AppAssets.videoAndrian);
        }
      }

      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(1.0);
      await _videoController!.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Preview video init notice (fallback asset): $e');
      try {
        _videoController = VideoPlayerController.asset(AppAssets.videoAndrian);
        await _videoController!.initialize();
        _videoController!.setLooping(true);
        await _videoController!.play();
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isPlaying = true;
          });
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
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

  void _appendHashtag(String tag) {
    AppAudioService.instance.playPopSound();
    final current = _captionController.text;
    if (current.contains(tag)) return;
    final separator = current.isNotEmpty && !current.endsWith(' ') ? ' ' : '';
    setState(() {
      _captionController.text = '$current$separator$tag ';
    });
  }

  Future<void> _handlePublish() async {
    if (_isPublishing) return;

    setState(() {
      _isPublishing = true;
    });

    final auth = context.read<AuthProvider>();
    final feedProvider = context.read<FeedProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final user = auth.currentUser;

    AppAudioService.instance.playChimeSound();

    final caption = _captionController.text.trim().isNotEmpty
        ? _captionController.text.trim()
        : 'Momen seru video baru di Social Hub! 🚀 #socialhub #fyp #viral';

    final effectiveVideo = widget.videoUrl.isNotEmpty ? widget.videoUrl : AppAssets.videoLanding;

    // Pick varied aesthetic cover so thumbnail is NEVER solid black
    final covers = const [
      AppAssets.imgFeed,
      AppAssets.imgFriends,
      AppAssets.imgNotifications,
      AppAssets.imgAndrianPoster,
      AppAssets.imgProfile,
    ];
    final defaultThumb = covers[caption.hashCode.abs() % covers.length];
    final effectiveThumb = (widget.thumbnailUrl.isNotEmpty && (!widget.thumbnailUrl.startsWith('data:') || widget.thumbnailUrl.length >= 7500))
        ? widget.thumbnailUrl
        : defaultThumb;

    // AI Viral Engagement Simulator: Generate varied numbers in the thousands (ribuan)
    final random = math.Random();
    final dynamicLikes = 14500 + random.nextInt(78200); // 14.5K - 92.7K
    final dynamicComments = 280 + random.nextInt(1650); // 280 - 1.9K
    final dynamicShares = 1200 + random.nextInt(8800); // 1.2K - 10K
    final dynamicBookmarks = 650 + random.nextInt(5600); // 650 - 6.2K
    final dynamicViews = 45000 + random.nextInt(340000); // 45K - 385K

    // 1. Save post to database and insert to ProfileProvider user video grid
    final savedPost = await profileProvider.createNewPost(
      userId: user?.id ?? 1,
      authorName: user?.name.isNotEmpty == true ? user!.name : 'Andrian Aja',
      authorUsername: user?.username.isNotEmpty == true ? user!.username : 'andrianpei',
      authorAvatar: user?.avatarUrl.isNotEmpty == true ? user!.avatarUrl : AppAssets.imgProfile,
      videoUrl: effectiveVideo,
      caption: caption,
      musicTitle: widget.soundTitle.isNotEmpty ? widget.soundTitle : '♫ Sound Asli - andrianpei',
      thumbnailPath: effectiveThumb,
      likesCount: dynamicLikes,
      commentsCount: dynamicComments,
      sharesCount: dynamicShares,
      bookmarksCount: dynamicBookmarks,
      viewCount: dynamicViews,
      isLiked: true,
    );

    // Save to IndexedDB and localStorage so video and thumbnail never disappear
    await WebMediaStore.savePostVideo(savedPost.id, WebMediaStore.getCachedSelectedVideoBlob());
    WebMediaStore.savePostThumbnail(savedPost.id, savedPost.thumbnailPath);

    // 2. Add post directly to FeedProvider at index 0 and request immediate page jump to 0
    await feedProvider.addPostToFeed(savedPost, saveToDb: false);
    feedProvider.requestJumpToPage(0);

    if (mounted) {
      _videoController?.pause();
      widget.onPublishSuccess();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '🎉 Video berhasil diunggah dan langsung tayang di Beranda & Profil Anda!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Screen Video or Photo Preview Background
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.isVideo ? _togglePlayPause : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.isVideo && _isVideoInitialized && _videoController != null)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width > 0 ? _videoController!.value.size.width : 390,
                        height: _videoController!.value.size.height > 0 ? _videoController!.value.size.height : 844,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                else
                  SmartMediaImage(
                    pathOrUrl: widget.thumbnailUrl.isNotEmpty ? widget.thumbnailUrl : AppAssets.imgAndrianPoster,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                // Subtle Top and Bottom Dark Gradients for Readability
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Center Play / Pause Indicator
                if (widget.isVideo && !_isPlaying)
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.60),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Top Bar: Back Button, Sound Badge, Next
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () {
                        AppAudioService.instance.playPopSound();
                        _videoController?.pause();
                        widget.onBackToCamera();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),

                    // Sound Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.music_note, color: Color(0xFF20D5EC), size: 15),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              widget.soundTitle,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mode Indicator Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.isVideo ? 'VIDEO' : 'FOTO',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Right Vertical Editing Tools (Teks, Stiker, Filter, Efek)
          Positioned(
            top: 90,
            right: 12,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  _buildEditTool(
                    icon: Icons.title,
                    label: 'Teks',
                    onTap: () {
                      AppAudioService.instance.playPopSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ketik teks langsung pada kolom deskripsi di bawah ✍️')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEditTool(
                    icon: Icons.sentiment_satisfied_alt,
                    label: 'Stiker',
                    onTap: () {
                      _appendHashtag('✨');
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEditTool(
                    icon: Icons.auto_awesome,
                    label: 'Filter',
                    color: _selectedFilterName != null ? const Color(0xFF20D5EC) : Colors.white,
                    onTap: () {
                      AppAudioService.instance.playChimeSound();
                      setState(() {
                        _selectedFilterName = _selectedFilterName == null ? 'Vivid Glow' : null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_selectedFilterName != null ? 'Filter Vivid Glow Aktif ✨' : 'Filter Normal')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEditTool(
                    icon: Icons.volume_up_rounded,
                    label: 'Volume',
                    onTap: () {
                      AppAudioService.instance.playPopSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Volume audio video diset 100% 🔊')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Publishing Section: Caption, Hashtags, and Post Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14151C).withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  border: const Border(top: BorderSide(color: Colors.white12)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, -4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Header Row
                    Row(
                      children: [
                        AppAvatar(
                          avatarUrl: user?.avatarUrl ?? '',
                          size: 34,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Andrian Pei',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '@${user?.username ?? 'andrianpei'} • Publik 🌐',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (widget.customFileName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF20D5EC).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                widget.customFileName!,
                                style: const TextStyle(color: Color(0xFF20D5EC), fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Caption Input Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F212D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _captionController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Tulis deskripsi video Anda, tambahkan #tagar atau @sebut teman...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 12.5),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick Hashtag Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickHashtags.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              backgroundColor: const Color(0xFF282B3A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              onPressed: () => _appendHashtag(tag),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Prominent TikTok Red Gradient "Posting Sekarang" Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.6),
                        ),
                        onPressed: _isPublishing ? null : _handlePublish,
                        child: _isPublishing
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Memublikasikan Video...',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.file_upload_outlined, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Posting Sekarang',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTool({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

