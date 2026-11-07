import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String usernameOrEmail, String password);
  Future<UserEntity> register({
    required String username,
    required String name,
    required String email,
    required String password,
    String? avatarUrl,
  });
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<bool> updateProfile({
    required int id,
    required String name,
    required String bio,
    String? avatarUrl,
  });
}

