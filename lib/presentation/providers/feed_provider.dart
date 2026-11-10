import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_assets.dart';
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
  }

  List<PostEntity> get posts => _posts;
  bool get isLoading => _isLoading;
  int get activePostIndex => _activePostIndex;
  List<CommentEntity> get currentComments => _currentComments;
  bool get isLoadingComments => _isLoadingComments;
  bool get isFeedActive => _isFeedActive;

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
      if (loaded.isNotEmpty) {
        _posts = loaded;
      }
    } catch (e) {
      debugPrint('Error loading feed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPostToFeed(PostEntity post, {bool saveToDb = false}) async {
    _posts.insert(0, post);
    _activePostIndex = 0;
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
      _currentComments = await postRepository.getComments(postId);
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
