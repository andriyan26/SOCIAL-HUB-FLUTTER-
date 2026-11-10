import 'package:flutter/material.dart';
import 'package:social_hub/domain/entities/user_entity.dart';
import 'package:social_hub/domain/repositories/auth_repository.dart';

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

  Future<void> updateProfile({required String name, String? username, required String bio, String? avatarUrl}) async {
    final id = _currentUser?.id ?? 1;
    final finalUsername = (username != null && username.isNotEmpty)
        ? username
        : (_currentUser?.username ?? 'andrianpei');
    final email = _currentUser?.email ?? 'andriandowehz123@gmail.com';
    final newAvatar = (avatarUrl != null && avatarUrl.isNotEmpty)
        ? avatarUrl
        : (_currentUser?.avatarUrl ?? '');

    // 1. Optimistic immediate state update so all screens (Profile, Beranda, etc.) update with 0ms delay
    _currentUser = UserEntity(
      id: id,
      username: finalUsername,
      name: name.isNotEmpty ? name : (_currentUser?.name ?? 'Andrian Pei'),
      email: email,
      avatarUrl: newAvatar,
      bio: bio.isNotEmpty ? bio : (_currentUser?.bio ?? 'Taken 🤍'),
      followingCount: _currentUser?.followingCount ?? 0,
      followersCount: _currentUser?.followersCount ?? 0,
      likesCount: _currentUser?.likesCount ?? 0,
      createdAt: _currentUser?.createdAt ?? DateTime.now().toIso8601String(),
    );
    notifyListeners();

    // 2. Persist in local SQLite / web database
    try {
      await authRepository.updateProfile(
        id: id,
        name: _currentUser!.name,
        username: _currentUser!.username,
        bio: _currentUser!.bio,
        avatarUrl: _currentUser!.avatarUrl,
      );
    } catch (e) {
      debugPrint('Notice saving profile updates to database: $e');
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

