import 'package:social_hub/domain/entities/post_entity.dart';
import 'package:social_hub/domain/repositories/post_repository.dart';
import 'package:social_hub/data/datasources/local_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final LocalDataSource localDataSource;

  PostRepositoryImpl({required this.localDataSource});

  @override
  Future<List<PostEntity>> getFeedPosts() async {
    return await localDataSource.getFeedPosts();
  }

  @override
  Future<List<PostEntity>> getUserPosts(int userId) async {
    return await localDataSource.getUserPosts(userId);
  }

  @override
  Future<void> toggleLike(int postId, bool currentLiked) async {
    final posts = await localDataSource.getFeedPosts();
    final post = posts.firstWhere((p) => p.id == postId, orElse: () => posts.first);
    final newLiked = !currentLiked;
    final newCount = newLiked ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);
    await localDataSource.updatePostLike(postId, newLiked, newCount);
  }

  @override
  Future<void> toggleBookmark(int postId, bool currentBookmarked) async {
    final posts = await localDataSource.getFeedPosts();
    final post = posts.firstWhere((p) => p.id == postId, orElse: () => posts.first);
    final newBookmarked = !currentBookmarked;
    final newCount = newBookmarked ? post.bookmarksCount + 1 : (post.bookmarksCount > 0 ? post.bookmarksCount - 1 : 0);
    await localDataSource.updatePostBookmark(postId, newBookmarked, newCount);
  }

  @override
  Future<List<CommentEntity>> getComments(int postId) async {
    return await localDataSource.getComments(postId);
  }

  @override
  Future<CommentEntity> addComment(int postId, String username, String text) async {
    final now = DateTime.now().toIso8601String();
    return await localDataSource.addComment({
      'post_id': postId,
      'username': username,
      'user_avatar': 'assets/images/img_8668.jpg',
      'text': text,
      'likes_count': 0,
      'created_at': now,
    });
  }

  @override
  Future<PostEntity> createPost({
    required int userId,
    required String authorName,
    required String authorUsername,
    required String authorAvatar,
    required String videoUrl,
    required String caption,
    required String musicTitle,
    required String thumbnailPath,
  }) async {
    final now = DateTime.now().toIso8601String();
    return await localDataSource.insertPost({
      'user_id': userId,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_avatar': authorAvatar,
      'video_url': videoUrl,
      'caption': caption,
      'music_title': musicTitle,
      'likes_count': 0,
      'comments_count': 0,
      'shares_count': 0,
      'bookmarks_count': 0,
      'is_liked': 0,
      'is_bookmarked': 0,
      'view_count': 0,
      'thumbnail_path': thumbnailPath,
      'created_at': now,
    });
  }
}

