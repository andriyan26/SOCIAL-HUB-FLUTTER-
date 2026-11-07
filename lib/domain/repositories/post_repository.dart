import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getFeedPosts();
  Future<List<PostEntity>> getUserPosts(int userId);
  Future<void> toggleLike(int postId, bool currentLiked);
  Future<void> toggleBookmark(int postId, bool currentBookmarked);
  Future<List<CommentEntity>> getComments(int postId);
  Future<CommentEntity> addComment(int postId, String username, String text);
  Future<PostEntity> createPost({
    required int userId,
    required String authorName,
    required String authorUsername,
    required String authorAvatar,
    required String videoUrl,
    required String caption,
    required String musicTitle,
    required String thumbnailPath,
  });
}
