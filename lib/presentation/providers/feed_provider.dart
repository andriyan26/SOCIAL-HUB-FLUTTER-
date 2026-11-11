import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/cloud_sync_service.dart';
import 'package:social_hub/core/services/media_store/web_media_store.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/domain/repositories/post_repository.dart';

class FeedProvider extends ChangeNotifier {
  final PostRepository postRepository;

  FeedProvider({required this.postRepository}) {
    _initDefaultPosts();
  }

  List<PostEntity> _posts = [];
  bool _isLoading = false;
  int _activePostIndex = 0;
  List<CommentEntity> _currentComments = [];
  bool _isLoadingComments = false;
  bool _isFeedActive = true;
  int _targetPageIndexOnReturn = -1;

  void _initDefaultPosts() {
    _posts = [
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
    ];
  }

  List<PostEntity> get posts => _posts;
  bool get isLoading => _isLoading;
  int get activePostIndex => _activePostIndex;
  List<CommentEntity> get currentComments => _currentComments;
  bool get isLoadingComments => _isLoadingComments;
  bool get isFeedActive => _isFeedActive;
  int get targetPageIndexOnReturn => _targetPageIndexOnReturn;

  void requestJumpToPage(int index) {
    _targetPageIndexOnReturn = index;
    notifyListeners();
  }

  void clearJumpRequest() {
    _targetPageIndexOnReturn = -1;
  }

  void setFeedActive(bool active) {
    if (_isFeedActive != active) {
      _isFeedActive = active;
      notifyListeners();
    }
  }

  Future<void> loadFeed() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loaded = await postRepository.getFeedPosts();
      PostEntity restoreThumb(PostEntity p) {
        final localThumb = WebMediaStore.getPostThumbnail(p.id);
        if (localThumb != null && localThumb.isNotEmpty) {
          return p.copyWith(thumbnailPath: localThumb);
        }
        return p;
      }
      if (loaded.isNotEmpty) {
        _posts = loaded.map(restoreThumb).toList();
      }
    } catch (e) {
      debugPrint('Error loading feed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Pull cloud posts in background to sync from other devices
    Future.microtask(() async {
      try {
        final cloudPosts = await CloudSyncService.fetchCloudPosts();
        bool hasNew = false;
        for (final map in cloudPosts) {
          final pid = map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString()) ?? 0;
          final vUrl = map['video_url']?.toString() ?? '';
          final alreadyExists = _posts.any((p) => p.id == pid || (vUrl.isNotEmpty && p.videoUrl == vUrl));

          if (pid != 0 && !alreadyExists) {
            final newPost = PostEntity(
              id: pid,
              userId: map['user_id'] is int ? map['user_id'] as int : int.tryParse(map['user_id'].toString()) ?? 1,
              authorName: map['author_name']?.toString() ?? 'Andrian',
              authorUsername: map['author_username']?.toString() ?? 'andrianpei',
              authorAvatar: map['author_avatar']?.toString() ?? AppAssets.imgProfile,
              videoUrl: vUrl.isNotEmpty ? vUrl : AppAssets.videoLanding,
              caption: map['caption']?.toString() ?? '',
              musicTitle: map['music_title']?.toString() ?? '♫ Sound Asli - andrianpei',
              likesCount: map['likes_count'] is int ? map['likes_count'] as int : 0,
              commentsCount: map['comments_count'] is int ? map['comments_count'] as int : 0,
              sharesCount: map['shares_count'] is int ? map['shares_count'] as int : 0,
              bookmarksCount: map['bookmarks_count'] is int ? map['bookmarks_count'] as int : 0,
              isLiked: (map['is_liked'] == 1 || map['is_liked'] == true),
              isBookmarked: (map['is_bookmarked'] == 1 || map['is_bookmarked'] == true),
              isReposted: (map['is_reposted'] == 1 || map['is_reposted'] == true),
              isPrivate: (map['is_private'] == 1 || map['is_private'] == true),
              viewCount: map['view_count'] is int ? map['view_count'] as int : 1,
              thumbnailPath: (map['thumbnail_path'] != null && map['thumbnail_path'].toString().isNotEmpty)
                  ? map['thumbnail_path'].toString()
                  : AppAssets.imgAndrianPoster,
              createdAt: map['created_at']?.toString() ?? 'Baru saja',
            );

            _posts.insert(0, newPost);
            hasNew = true;
          }
        }
        if (hasNew) {
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Cloud feed sync notice: $e');
      }
    });
  }

  Future<void> addPostToFeed(PostEntity post, {bool saveToDb = false}) async {
    _posts.insert(0, post);
    _activePostIndex = 0;
    _targetPageIndexOnReturn = 0;
    notifyListeners();

    if (saveToDb) {
      try {
        await postRepository.createPost(
          userId: post.userId,
          authorName: post.authorName,
          authorUsername: post.authorUsername,
          authorAvatar: post.authorAvatar,
          videoUrl: post.videoUrl,
          caption: post.caption,
          musicTitle: post.musicTitle,
          thumbnailPath: post.thumbnailPath,
        );
      } catch (e) {
        debugPrint('Notice saving post to repository in FeedProvider: $e');
      }
    }
  }

  Future<void> deletePost(int postId) async {
    _posts.removeWhere((p) => p.id == postId);
    if (_activePostIndex >= _posts.length && _posts.isNotEmpty) {
      _activePostIndex = _posts.length - 1;
    }
    notifyListeners();
    try {
      await postRepository.deletePost(postId);
    } catch (_) {}
    CloudSyncService.deleteCloudPost(postId);
    WebMediaStore.deletePostVideo(postId);
  }

  void updateAuthorAvatar(int userId, String newAvatar) {
    updateAuthorProfile(userId, avatarUrl: newAvatar);
  }

  void updateAuthorProfile(int userId, {String? name, String? username, String? avatarUrl}) {
    if (_posts.isEmpty) {
      _initDefaultPosts();
    }
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].userId == userId || _posts[i].authorUsername.toLowerCase() == 'andrianpei') {
        _posts[i] = _posts[i].copyWith(
          authorName: (name != null && name.isNotEmpty) ? name : _posts[i].authorName,
          authorUsername: (username != null && username.isNotEmpty) ? username : _posts[i].authorUsername,
          authorAvatar: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : _posts[i].authorAvatar,
        );
      }
    }
    notifyListeners();
  }

  void setActivePostIndex(int index) {
    _activePostIndex = index;
    notifyListeners();
  }

  Future<PostEntity?> toggleLike(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final post = _posts[index];
    final newIsLiked = !post.isLiked;
    final newCount = newIsLiked ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);

    final updated = post.copyWith(isLiked: newIsLiked, likesCount: newCount);
    _posts[index] = updated;
    notifyListeners();

    try {
      await postRepository.toggleLike(postId, post.isLiked);
    } catch (e) {
      _posts[index] = post;
      notifyListeners();
      return null;
    }
    return updated;
  }

  Future<PostEntity?> toggleBookmark(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final post = _posts[index];
    final newIsBookmarked = !post.isBookmarked;
    final newCount = newIsBookmarked ? post.bookmarksCount + 1 : (post.bookmarksCount > 0 ? post.bookmarksCount - 1 : 0);

    final updated = post.copyWith(isBookmarked: newIsBookmarked, bookmarksCount: newCount);
    _posts[index] = updated;
    notifyListeners();

    try {
      await postRepository.toggleBookmark(postId, post.isBookmarked);
    } catch (e) {
      _posts[index] = post;
      notifyListeners();
      return null;
    }
    return updated;
  }

  Future<PostEntity?> toggleRepost(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final post = _posts[index];
    final newIsReposted = !post.isReposted;
    final newCount = newIsReposted ? post.sharesCount + 1 : (post.sharesCount > 0 ? post.sharesCount - 1 : 0);

    final updated = post.copyWith(isReposted: newIsReposted, sharesCount: newCount);
    _posts[index] = updated;
    notifyListeners();

    try {
      await postRepository.toggleRepost(postId, post.isReposted);
    } catch (e) {
      _posts[index] = post;
      notifyListeners();
      return null;
    }
    return updated;
  }

  Future<PostEntity?> togglePrivate(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return null;

    final post = _posts[index];
    final newIsPrivate = !post.isPrivate;

    final updated = post.copyWith(isPrivate: newIsPrivate);
    _posts[index] = updated;
    notifyListeners();

    try {
      await postRepository.togglePrivate(postId, post.isPrivate);
    } catch (e) {
      _posts[index] = post;
      notifyListeners();
      return null;
    }
    return updated;
  }

  Future<void> loadComments(int postId) async {
    _isLoadingComments = true;
    notifyListeners();
    try {
      var list = await postRepository.getComments(postId);
      if (list.isEmpty) {
        // Pre-populate with realistic AI generated community comments
        final sampleComments = [
          'Keren banget videonya bang! Vibesnya dapet banget 😍✨',
          'Aesthetic parah! Spill lokasinya dong bang 🔥🙌',
          'MasyaAllah seru banget, auto like and follow bang pei 🚀',
          'Gak pernah gagal kalau bikin video haha! FYP terus ya bang! ❤️👏',
          'Bagus banget angle videonya, smooth pol! ✨',
          'Wah viral nih lewat beranda jam segini rame bgt 🔥',
        ];
        final commenters = [
          'aurelie.hermansyah',
          'ei.kaa',
          's_anime',
          'angsuran17',
          'annisasabila13',
        ];

        for (int i = 0; i < commenters.length; i++) {
          final u = commenters[i];
          final text = sampleComments[i % sampleComments.length];
          try {
            await postRepository.addComment(postId, u, text);
          } catch (_) {}
        }
        list = await postRepository.getComments(postId);
      }
      _currentComments = list;
    } catch (e) {
      _currentComments = [];
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<void> addComment(int postId, String username, String text) async {
    if (text.trim().isEmpty) return;
    try {
      final comment = await postRepository.addComment(postId, username, text.trim());
      _currentComments.insert(0, comment);

      // Increment comments count on post
      final pIndex = _posts.indexWhere((p) => p.id == postId);
      if (pIndex != -1) {
        final p = _posts[pIndex];
        _posts[pIndex] = p.copyWith(commentsCount: p.commentsCount + 1);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }
}
