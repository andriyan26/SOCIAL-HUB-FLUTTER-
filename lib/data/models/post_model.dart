import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  PostModel({
    required super.id,
    required super.userId,
    required super.authorName,
    required super.authorUsername,
    required super.authorAvatar,
    required super.videoUrl,
    required super.caption,
    required super.musicTitle,
    super.likesCount,
    super.commentsCount,
    super.sharesCount,
    super.bookmarksCount,
    super.isLiked,
    super.isBookmarked,
    super.viewCount,
    required super.thumbnailPath,
    required super.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 1,
      userId: map['user_id'] is int ? map['user_id'] : int.tryParse(map['user_id'].toString()) ?? 1,
      authorName: map['author_name'] ?? '',
      authorUsername: map['author_username'] ?? '',
      authorAvatar: map['author_avatar'] ?? '',
      videoUrl: map['video_url'] ?? '',
      caption: map['caption'] ?? '',
      musicTitle: map['music_title'] ?? '',
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      sharesCount: map['shares_count'] ?? 0,
      bookmarksCount: map['bookmarks_count'] ?? 0,
      isLiked: (map['is_liked'] == 1 || map['is_liked'] == true),
      isBookmarked: (map['is_bookmarked'] == 1 || map['is_bookmarked'] == true),
      viewCount: map['view_count'] ?? 0,
      thumbnailPath: map['thumbnail_path'] ?? '',
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_avatar': authorAvatar,
      'video_url': videoUrl,
      'caption': caption,
      'music_title': musicTitle,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'bookmarks_count': bookmarksCount,
      'is_liked': isLiked ? 1 : 0,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'view_count': viewCount,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt,
    };
  }
}

class CommentModel extends CommentEntity {
  CommentModel({
    required super.id,
    required super.postId,
    required super.username,
    required super.userAvatar,
    required super.text,
    super.likesCount,
    required super.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 1,
      postId: map['post_id'] is int ? map['post_id'] : int.tryParse(map['post_id'].toString()) ?? 1,
      username: map['username'] ?? '',
      userAvatar: map['user_avatar'] ?? '',
      text: map['text'] ?? '',
      likesCount: map['likes_count'] ?? 0,
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'username': username,
      'user_avatar': userAvatar,
      'text': text,
      'likes_count': likesCount,
      'created_at': createdAt,
    };
  }
}

