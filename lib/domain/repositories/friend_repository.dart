import '../entities/friend_entity.dart';

abstract class FriendRepository {
  Future<List<FriendEntity>> getSuggestedFriends();
  Future<void> toggleFollow(int friendId, bool currentFollowState);
  Future<void> removeFriend(int friendId);
  Future<List<FriendEntity>> searchFriends(String query);
}
