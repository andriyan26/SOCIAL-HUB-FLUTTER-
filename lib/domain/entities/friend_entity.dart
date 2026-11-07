class FriendEntity {
  final int id;
  final String username;
  final String name;
  final String avatarUrl;
  final String subtitle;
  final bool isFollowing;

  FriendEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarUrl,
    required this.subtitle,
    required this.isFollowing,
  });

  FriendEntity copyWith({
    int? id,
    String? username,
    String? name,
    String? avatarUrl,
    String? subtitle,
    bool? isFollowing,
  }) {
    return FriendEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subtitle: subtitle ?? this.subtitle,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
