import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.bio,
    super.followingCount,
    super.followersCount,
    super.likesCount,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 1,
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      bio: map['bio'] ?? '',
      followingCount: map['following_count'] ?? 0,
      followersCount: map['followers_count'] ?? 0,
      likesCount: map['likes_count'] ?? 0,
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'following_count': followingCount,
      'followers_count': followersCount,
      'likes_count': likesCount,
      'created_at': createdAt,
    };
  }
}

