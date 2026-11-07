class UserEntity {
  final int id;
  final String username;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  final int followingCount;
  final int followersCount;
  final int likesCount;
  final String createdAt;

  UserEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    this.followingCount = 0,
    this.followersCount = 0,
    this.likesCount = 0,
    required this.createdAt,
  });
}
