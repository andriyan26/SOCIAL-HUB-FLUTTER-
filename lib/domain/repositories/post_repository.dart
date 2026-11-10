import 'package:social_hub/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getFeedPosts();
  Future<List<PostEntity>> getUserPosts(int userId);
  Future<List<PostEntity>> getLikedPosts();
  Future<List<PostEntity>> getBookmarkedPosts();
  Future<List<PostEntity>> getRepostedPosts();
  Future<List<PostEntity>> getPrivatePosts(int userId);
  Future<void> toggleLike(int postId, bool currentLiked);
  Future<void> toggleBookmark(int postId, bool currentBookmarked);
  Future<void> toggleRepost(int postId, bool currentReposted);
  Future<void> togglePrivate(int postId, bool currentPrivate);
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
  Future<void> deletePost(int postId);
}

