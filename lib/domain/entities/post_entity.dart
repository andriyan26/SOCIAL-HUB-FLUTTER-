class PostEntity {
  final int id;
  final int userId;
  final String authorName;
  final String authorUsername;
  final String authorAvatar;
  final String videoUrl;
  final String caption;
  final String musicTitle;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int bookmarksCount;
  final bool isLiked;
  final bool isBookmarked;
  final int viewCount;
  final String thumbnailPath;
  final String createdAt;

  PostEntity({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    required this.videoUrl,
    required this.caption,
    required this.musicTitle,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.bookmarksCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.viewCount = 0,
    required this.thumbnailPath,
    required this.createdAt,
  });

  PostEntity copyWith({
    int? id,
    int? userId,
    String? authorName,
    String? authorUsername,
    String? authorAvatar,
    String? videoUrl,
    String? caption,
    String? musicTitle,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? bookmarksCount,
    bool? isLiked,
    bool? isBookmarked,
    int? viewCount,
    String? thumbnailPath,
    String? createdAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      musicTitle: musicTitle ?? this.musicTitle,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      viewCount: viewCount ?? this.viewCount,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommentEntity {
  final int id;
  final int postId;
  final String username;
  final String userAvatar;
  final String text;
  final int likesCount;
  final String createdAt;

  CommentEntity({
    required this.id,
    required this.postId,
    required this.username,
    required this.userAvatar,
    required this.text,
    this.likesCount = 0,
    required this.createdAt,
  });
}
