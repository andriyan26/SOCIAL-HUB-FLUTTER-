import 'package:flutter/material.dart';
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/core/services/cloud_sync_service.dart';
import 'package:social_hub/core/services/media_store/web_media_store.dart';
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
        final customAvatar = WebMediaStore.getCustomAvatar();
        final effectiveAvatar = (customAvatar != null && customAvatar.isNotEmpty)
            ? customAvatar
            : user.avatarUrl;
        _currentUser = user.copyWith(avatarUrl: effectiveAvatar);
        _status = AuthStatus.authenticated;
        _syncFromCloudBackground();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _syncFromCloudBackground() {
    Future.microtask(() async {
      try {
        final cloudUser = await CloudSyncService.fetchCloudUser();
        if (cloudUser != null && _currentUser != null) {
          final cloudName = cloudUser['name']?.toString() ?? '';
          final cloudUsername = cloudUser['username']?.toString() ?? '';
          final cloudBio = cloudUser['bio']?.toString() ?? '';
          final cloudAvatar = cloudUser['avatar_url']?.toString() ?? '';

          bool needsUpdate = false;
          if (cloudName.isNotEmpty && cloudName != _currentUser!.name) needsUpdate = true;
          if (cloudBio.isNotEmpty && cloudBio != _currentUser!.bio) needsUpdate = true;
          if (cloudUsername.isNotEmpty && cloudUsername != _currentUser!.username) needsUpdate = true;

          // Never overwrite a custom base64 avatar with default cloud asset!
          String effectiveAvatar = _currentUser!.avatarUrl;
          if (cloudAvatar.isNotEmpty && cloudAvatar != _currentUser!.avatarUrl) {
            final isLocalCustom = _currentUser!.avatarUrl.startsWith('data:');
            final isCloudDefault = (cloudAvatar == AppAssets.imgProfile || cloudAvatar.isEmpty);
            if (!isLocalCustom && !isCloudDefault) {
              effectiveAvatar = cloudAvatar;
              needsUpdate = true;
            }
          }

          if (needsUpdate) {
            _currentUser = _currentUser!.copyWith(
              name: cloudName.isNotEmpty ? cloudName : _currentUser!.name,
              username: cloudUsername.isNotEmpty ? cloudUsername : _currentUser!.username,
              bio: cloudBio.isNotEmpty ? cloudBio : _currentUser!.bio,
              avatarUrl: effectiveAvatar,
            );
            notifyListeners();
            await authRepository.updateProfile(
              id: _currentUser!.id,
              name: _currentUser!.name,
              username: _currentUser!.username,
              bio: _currentUser!.bio,
              avatarUrl: _currentUser!.avatarUrl,
            );
          }
        }
      } catch (e) {
        debugPrint('Cloud sync notice: $e');
      }
    });
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
        final customAvatar = WebMediaStore.getCustomAvatar();
        final effectiveAvatar = (customAvatar != null && customAvatar.isNotEmpty)
            ? customAvatar
            : user.avatarUrl;
        _currentUser = user.copyWith(avatarUrl: effectiveAvatar);
        _status = AuthStatus.authenticated;
        notifyListeners();
        _syncFromCloudBackground();
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

    // Persist custom avatar to WebMediaStore / localStorage
    if (newAvatar.isNotEmpty) {
      WebMediaStore.saveCustomAvatar(newAvatar);
    }

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
      // 3. Sync to Cloud Gist database so changes immediately propagate across Web & Mobile
      CloudSyncService.syncProfileToCloud(
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

