import 'package:flutter/material.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';

class FeedProvider extends ChangeNotifier {
  final PostRepository postRepository;

  FeedProvider({required this.postRepository});

  List<PostEntity> _posts = [];
  bool _isLoading = false;
  int _activePostIndex = 0;
  List<CommentEntity> _currentComments = [];
  bool _isLoadingComments = false;

  List<PostEntity> get posts => _posts;
  bool get isLoading => _isLoading;
  int get activePostIndex => _activePostIndex;
  List<CommentEntity> get currentComments => _currentComments;
  bool get isLoadingComments => _isLoadingComments;

  Future<void> loadFeed() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await postRepository.getFeedPosts();
    } catch (e) {
      debugPrint('Error loading feed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActivePostIndex(int index) {
    _activePostIndex = index;
    notifyListeners();
  }

  Future<void> toggleLike(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final newIsLiked = !post.isLiked;
    final newCount = newIsLiked ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);

    // Optimistic UI update
    _posts[index] = post.copyWith(isLiked: newIsLiked, likesCount: newCount);
    notifyListeners();

    try {
      await postRepository.toggleLike(postId, post.isLiked);
    } catch (e) {
      // Revert on error
      _posts[index] = post;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final newIsBookmarked = !post.isBookmarked;
    final newCount = newIsBookmarked ? post.bookmarksCount + 1 : (post.bookmarksCount > 0 ? post.bookmarksCount - 1 : 0);

    _posts[index] = post.copyWith(isBookmarked: newIsBookmarked, bookmarksCount: newCount);
    notifyListeners();

    try {
      await postRepository.toggleBookmark(postId, post.isBookmarked);
    } catch (e) {
      _posts[index] = post;
      notifyListeners();
    }
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

