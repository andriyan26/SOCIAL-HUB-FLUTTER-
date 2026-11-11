import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/cloud_sync_service.dart';
import 'package:social_hub/core/services/media_store/web_media_store.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/domain/repositories/post_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final PostRepository postRepository;

  ProfileProvider({required this.postRepository});

  List<PostEntity> _userPosts = [];
  List<PostEntity> _privatePosts = [];
  List<PostEntity> _repostedPosts = [];
  List<PostEntity> _bookmarkedPosts = [];
  List<PostEntity> _likedPosts = [];

  bool _isLoading = false;
  int _selectedSubTab = 0; // 0: Grid posts, 1: Lock, 2: Repost, 3: Bookmark, 4: Heart

  List<PostEntity> get userPosts => _userPosts;
  List<PostEntity> get privatePosts => _privatePosts;
  List<PostEntity> get repostedPosts => _repostedPosts;
  List<PostEntity> get bookmarkedPosts => _bookmarkedPosts;
  List<PostEntity> get likedPosts => _likedPosts;

  bool get isLoading => _isLoading;
  int get selectedSubTab => _selectedSubTab;

  void setSelectedSubTab(int index) {
    _selectedSubTab = index;
    notifyListeners();
  }

  Future<void> loadProfileData(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final allUserPosts = await postRepository.getUserPosts(userId);
      PostEntity restoreThumb(PostEntity p) {
        final localThumb = WebMediaStore.getPostThumbnail(p.id);
        if (localThumb != null && localThumb.isNotEmpty) {
          return p.copyWith(thumbnailPath: localThumb);
        }
        return p;
      }
      _userPosts = allUserPosts.where((p) => !p.isPrivate).map(restoreThumb).toList();
      _privatePosts = allUserPosts.where((p) => p.isPrivate).map(restoreThumb).toList();
      _likedPosts = (await postRepository.getLikedPosts()).map(restoreThumb).toList();
      _bookmarkedPosts = (await postRepository.getBookmarkedPosts()).map(restoreThumb).toList();
      _repostedPosts = (await postRepository.getRepostedPosts()).map(restoreThumb).toList();
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Real-time cloud sync to seamlessly pull posts across HP and Laptop
    Future.microtask(() async {
      try {
        final cloudPosts = await CloudSyncService.fetchCloudPosts();
        bool hasNew = false;
        for (final map in cloudPosts) {
          final pid = map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString()) ?? 0;
          final pUserId = map['user_id'] is int ? map['user_id'] as int : int.tryParse(map['user_id'].toString()) ?? 1;
          final vUrl = map['video_url']?.toString() ?? '';

          // ONLY include posts belonging to THIS profile user
          if (pUserId != userId) continue;

          // Prevent duplicate video entries by checking both post ID and video URL
          final alreadyExists = _userPosts.any((p) => p.id == pid || (vUrl.isNotEmpty && p.videoUrl == vUrl)) ||
                                _privatePosts.any((p) => p.id == pid || (vUrl.isNotEmpty && p.videoUrl == vUrl));

          if (pid != 0 && !alreadyExists) {
            final newPost = PostEntity(
              id: pid,
              userId: pUserId,
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
              thumbnailPath: map['thumbnail_path']?.toString() ?? AppAssets.imgFeed,
              createdAt: map['created_at']?.toString() ?? 'Baru saja',
            );

            if (newPost.isPrivate) {
              _privatePosts.insert(0, newPost);
            } else {
              _userPosts.insert(0, newPost);
            }
            if (newPost.isLiked && _likedPosts.every((p) => p.id != pid)) {
              _likedPosts.insert(0, newPost);
            }
            hasNew = true;
          }
        }
        if (hasNew) {
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Cloud posts sync notice: $e');
      }
    });
  }

  Future<void> loadUserPosts(int userId) => loadProfileData(userId);

  void syncPostState(PostEntity post) {
    // 1. Liked tab sync
    if (post.isLiked) {
      final idx = _likedPosts.indexWhere((p) => p.id == post.id);
      if (idx == -1) {
        _likedPosts.insert(0, post);
      } else {
        _likedPosts[idx] = post;
      }
    } else {
      _likedPosts.removeWhere((p) => p.id == post.id);
    }

    // 2. Bookmarked tab sync
    if (post.isBookmarked) {
      final idx = _bookmarkedPosts.indexWhere((p) => p.id == post.id);
      if (idx == -1) {
        _bookmarkedPosts.insert(0, post);
      } else {
        _bookmarkedPosts[idx] = post;
      }
    } else {
      _bookmarkedPosts.removeWhere((p) => p.id == post.id);
    }

    // 3. Reposted tab sync
    if (post.isReposted) {
      final idx = _repostedPosts.indexWhere((p) => p.id == post.id);
      if (idx == -1) {
        _repostedPosts.insert(0, post);
      } else {
        _repostedPosts[idx] = post;
      }
    } else {
      _repostedPosts.removeWhere((p) => p.id == post.id);
    }

    // 4. Private vs Public tab sync
    if (post.isPrivate) {
      _userPosts.removeWhere((p) => p.id == post.id);
      final idx = _privatePosts.indexWhere((p) => p.id == post.id);
      if (idx == -1) {
        _privatePosts.insert(0, post);
      } else {
        _privatePosts[idx] = post;
      }
    } else {
      _privatePosts.removeWhere((p) => p.id == post.id);
      final idx = _userPosts.indexWhere((p) => p.id == post.id);
      if (idx != -1) {
        _userPosts[idx] = post;
      } else if (post.userId == 1) {
        _userPosts.insert(0, post);
      }
    }

    notifyListeners();
  }

  Future<void> toggleLike(int postId) async {
    final all = [..._userPosts, ..._privatePosts, ..._likedPosts, ..._bookmarkedPosts, ..._repostedPosts];
    final match = all.firstWhere((p) => p.id == postId, orElse: () => _likedPosts.isNotEmpty ? _likedPosts.first : _userPosts.first);
    final newLiked = !match.isLiked;
    final updated = match.copyWith(
      isLiked: newLiked,
      likesCount: newLiked ? match.likesCount + 1 : (match.likesCount > 0 ? match.likesCount - 1 : 0),
    );
    syncPostState(updated);
    try {
      await postRepository.toggleLike(postId, match.isLiked);
    } catch (_) {}
  }

  Future<void> toggleBookmark(int postId) async {
    final all = [..._userPosts, ..._privatePosts, ..._likedPosts, ..._bookmarkedPosts, ..._repostedPosts];
    final match = all.firstWhere((p) => p.id == postId, orElse: () => _bookmarkedPosts.isNotEmpty ? _bookmarkedPosts.first : _userPosts.first);
    final newBookmarked = !match.isBookmarked;
    final updated = match.copyWith(
      isBookmarked: newBookmarked,
      bookmarksCount: newBookmarked ? match.bookmarksCount + 1 : (match.bookmarksCount > 0 ? match.bookmarksCount - 1 : 0),
    );
    syncPostState(updated);
    try {
      await postRepository.toggleBookmark(postId, match.isBookmarked);
    } catch (_) {}
  }

  Future<void> toggleRepost(int postId) async {
    final all = [..._userPosts, ..._privatePosts, ..._likedPosts, ..._bookmarkedPosts, ..._repostedPosts];
    final match = all.firstWhere((p) => p.id == postId, orElse: () => _repostedPosts.isNotEmpty ? _repostedPosts.first : _userPosts.first);
    final newReposted = !match.isReposted;
    final updated = match.copyWith(
      isReposted: newReposted,
      sharesCount: newReposted ? match.sharesCount + 1 : (match.sharesCount > 0 ? match.sharesCount - 1 : 0),
    );
    syncPostState(updated);
    try {
      await postRepository.toggleRepost(postId, match.isReposted);
    } catch (_) {}
  }

  Future<void> togglePrivate(int postId) async {
    final all = [..._userPosts, ..._privatePosts, ..._likedPosts, ..._bookmarkedPosts, ..._repostedPosts];
    final match = all.firstWhere((p) => p.id == postId, orElse: () => _privatePosts.isNotEmpty ? _privatePosts.first : _userPosts.first);
    final newPrivate = !match.isPrivate;
    final updated = match.copyWith(isPrivate: newPrivate);
    syncPostState(updated);
    try {
      await postRepository.togglePrivate(postId, match.isPrivate);
    } catch (_) {}
  }

  void updateAuthorAvatar(int userId, String newAvatar) {
    updateAuthorProfile(userId, avatarUrl: newAvatar);
  }

  void updateAuthorProfile(int userId, {String? name, String? username, String? avatarUrl}) {
    for (int i = 0; i < _userPosts.length; i++) {
      if (_userPosts[i].userId == userId || _userPosts[i].authorUsername.toLowerCase() == 'andrianpei') {
        _userPosts[i] = _userPosts[i].copyWith(
          authorName: (name != null && name.isNotEmpty) ? name : _userPosts[i].authorName,
          authorUsername: (username != null && username.isNotEmpty) ? username : _userPosts[i].authorUsername,
          authorAvatar: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : _userPosts[i].authorAvatar,
        );
      }
    }
    notifyListeners();
  }

  Future<PostEntity> createNewPost({
    required int userId,
    required String authorName,
    required String authorUsername,
    required String authorAvatar,
    required String videoUrl,
    required String caption,
    required String musicTitle,
    required String thumbnailPath,
    int likesCount = 0,
    int commentsCount = 0,
    int sharesCount = 0,
    int bookmarksCount = 0,
    int viewCount = 0,
    bool isLiked = false,
  }) async {
    final newPost = await postRepository.createPost(
      userId: userId,
      authorName: authorName,
      authorUsername: authorUsername,
      authorAvatar: authorAvatar,
      videoUrl: videoUrl,
      caption: caption,
      musicTitle: musicTitle,
      thumbnailPath: thumbnailPath,
      likesCount: likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      bookmarksCount: bookmarksCount,
      viewCount: viewCount,
      isLiked: isLiked,
    );
    _userPosts.insert(0, newPost);
    notifyListeners();
    CloudSyncService.syncPostToCloud(newPost);
    return newPost;
  }

  Future<void> deletePost(int postId) async {
    _userPosts.removeWhere((p) => p.id == postId);
    _privatePosts.removeWhere((p) => p.id == postId);
    _likedPosts.removeWhere((p) => p.id == postId);
    _bookmarkedPosts.removeWhere((p) => p.id == postId);
    _repostedPosts.removeWhere((p) => p.id == postId);
    notifyListeners();

    try {
      await postRepository.deletePost(postId);
    } catch (_) {}
    CloudSyncService.deleteCloudPost(postId);
    WebMediaStore.deletePostVideo(postId);
  }
}
