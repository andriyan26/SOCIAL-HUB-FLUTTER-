import 'package:social_hub/domain/entities/friend_entity.dart';
import 'package:social_hub/domain/repositories/friend_repository.dart';
import 'package:social_hub/data/datasources/local_data_source.dart';

class FriendRepositoryImpl implements FriendRepository {
  final LocalDataSource localDataSource;

  FriendRepositoryImpl({required this.localDataSource});

  @override
  Future<List<FriendEntity>> getSuggestedFriends() async {
    return await localDataSource.getFriends();
  }

  @override
  Future<void> toggleFollow(int friendId, bool currentFollowState) async {
    await localDataSource.updateFriendFollow(friendId, !currentFollowState);
  }

  @override
  Future<void> removeFriend(int friendId) async {
    await localDataSource.deleteFriend(friendId);
  }

  @override
  Future<List<FriendEntity>> searchFriends(String query) async {
    final friends = await localDataSource.getFriends();
    if (query.trim().isEmpty) return friends;
    return friends.where((f) =>
      f.name.toLowerCase().contains(query.toLowerCase()) ||
      f.username.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

