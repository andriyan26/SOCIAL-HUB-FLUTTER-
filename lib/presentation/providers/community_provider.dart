import 'package:flutter/material.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/repositories/friend_repository.dart';

class CommunityProvider extends ChangeNotifier {
  final FriendRepository friendRepository;

  CommunityProvider({required this.friendRepository});

  List<FriendEntity> _friends = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<FriendEntity> get friends => _friends;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();
    try {
      _friends = await friendRepository.getSuggestedFriends();
    } catch (e) {
      debugPrint('Error loading friends: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();
    try {
      _friends = await friendRepository.searchFriends(query);
    } catch (e) {
      debugPrint('Error searching friends: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow(int friendId) async {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index == -1) return;

    final friend = _friends[index];
    final newFollow = !friend.isFollowing;

    // Optimistic update
    _friends[index] = friend.copyWith(isFollowing: newFollow);
    notifyListeners();

    try {
      await friendRepository.toggleFollow(friendId, friend.isFollowing);
    } catch (e) {
      _friends[index] = friend;
      notifyListeners();
    }
  }

  Future<void> removeFriend(int friendId) async {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index == -1) return;

    final friend = _friends.removeAt(index);
    notifyListeners();

    try {
      await friendRepository.removeFriend(friendId);
    } catch (e) {
      _friends.insert(index, friend);
      notifyListeners();
    }
  }
}

