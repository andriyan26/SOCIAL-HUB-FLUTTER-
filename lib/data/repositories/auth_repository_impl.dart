import 'package:social_hub/core/services/session_service.dart';
import 'package:social_hub/domain/entities/user_entity.dart';
import 'package:social_hub/domain/repositories/auth_repository.dart';
import 'package:social_hub/data/datasources/local_data_source.dart';
import 'package:social_hub/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity?> login(String usernameOrEmail, String password) async {
    final user = await localDataSource.login(usernameOrEmail, password);
    if (user != null) {
      await SessionService.saveUserSession(
        id: user.id,
        username: user.username,
        email: user.email,
        name: user.name,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      );
    }
    return user;
  }

  @override
  Future<UserEntity> register({
    required String username,
    required String name,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    final now = DateTime.now().toIso8601String();
    final userMap = {
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'avatar_url': avatarUrl ?? 'assets/images/img_8668.jpg',
      'bio': 'Pengguna baru di Social Hub ✨',
      'following_count': 0,
      'followers_count': 0,
      'likes_count': 0,
      'created_at': now,
    };

    final user = await localDataSource.register(userMap);
    await SessionService.saveUserSession(
      id: user.id,
      username: user.username,
      email: user.email,
      name: user.name,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
    );
    return user;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final session = await SessionService.getSessionUser();
    if (session == null) return null;
    final user = await localDataSource.getUserById(session['id']);
    if (user != null) return user;
    return UserModel(
      id: session['id'],
      username: session['username'],
      name: session['name'],
      email: session['email'],
      avatarUrl: session['avatar_url'],
      bio: session['bio'],
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> logout() async {
    await SessionService.clearSession();
  }

  @override
  Future<bool> updateProfile({
    required int id,
    required String name,
    String? username,
    required String bio,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'bio': bio,
    };
    if (username != null && username.isNotEmpty) data['username'] = username;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    final success = await localDataSource.updateUser(id, data);
    if (success) {
      final updated = await localDataSource.getUserById(id);
      if (updated != null) {
        await SessionService.saveUserSession(
          id: updated.id,
          username: updated.username,
          email: updated.email,
          name: updated.name,
          avatarUrl: updated.avatarUrl,
          bio: updated.bio,
        );
      }
    }
    return success;
  }
}

