import 'package:social_hub/domain/entities/user_entity.dart';

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
      followingCount: map['following_count'] is int ? map['following_count'] : (int.tryParse(map['following_count']?.toString() ?? '') ?? 0),
      followersCount: map['followers_count'] is int ? map['followers_count'] : (int.tryParse(map['followers_count']?.toString() ?? '') ?? 0),
      likesCount: map['likes_count'] is int ? map['likes_count'] : (int.tryParse(map['likes_count']?.toString() ?? '') ?? 0),
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

