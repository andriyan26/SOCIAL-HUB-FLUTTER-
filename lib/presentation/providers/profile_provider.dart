import 'package:flutter/material.dart';
import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/domain/repositories/post_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final PostRepository postRepository;

  ProfileProvider({required this.postRepository});

  List<PostEntity> _userPosts = [];
  bool _isLoading = false;
  int _selectedSubTab = 0; // 0: Grid posts, 1: Lock, 2: Repost, 3: Bookmark, 4: Heart

  List<PostEntity> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  int get selectedSubTab => _selectedSubTab;

  void setSelectedSubTab(int index) {
    _selectedSubTab = index;
    notifyListeners();
  }

  Future<void> loadUserPosts(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userPosts = await postRepository.getUserPosts(userId);
    } catch (e) {
      debugPrint('Error loading user posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    );
    _userPosts.insert(0, newPost);
    notifyListeners();
    return newPost;
  }
}
