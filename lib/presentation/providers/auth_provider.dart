import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;

  Future<void> checkAuthSession() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cinematic brief delay to match login concept animation
      await Future.delayed(const Duration(milliseconds: 900));

      final user = await authRepository.login(usernameOrEmail, password);
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Username/email atau kata sandi salah.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 900));
      final user = await authRepository.register(
        username: username,
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mendaftar: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({required String name, required String bio, String? avatarUrl}) async {
    if (_currentUser == null) return;
    final success = await authRepository.updateProfile(
      id: _currentUser!.id,
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
    );
    if (success) {
      _currentUser = UserEntity(
        id: _currentUser!.id,
        username: _currentUser!.username,
        name: name,
        email: _currentUser!.email,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        bio: bio,
        followingCount: _currentUser!.followingCount,
        followersCount: _currentUser!.followersCount,
        likesCount: _currentUser!.likesCount,
        createdAt: _currentUser!.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

