import '../../domain/entities/friend_entity.dart';

class FriendModel extends FriendEntity {
  FriendModel({
    required super.id,
    required super.username,
    required super.name,
    required super.avatarUrl,
    required super.subtitle,
    required super.isFollowing,
  });

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 1,
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      subtitle: map['subtitle'] ?? '',
      isFollowing: (map['is_following'] == 1 || map['is_following'] == true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatar_url': avatarUrl,
      'subtitle': subtitle,
      'is_following': isFollowing ? 1 : 0,
    };
  }
}
