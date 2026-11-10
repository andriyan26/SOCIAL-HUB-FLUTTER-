import 'package:social_hub/core/database/app_database.dart';
import 'package:social_hub/data/models/user_model.dart';
import 'package:social_hub/data/models/post_model.dart';
import 'package:social_hub/data/models/notification_model.dart';
import 'package:social_hub/data/models/friend_model.dart';

class LocalDataSource {
  final AppDatabase db = AppDatabase.instance;

  // --- USER AUTH & PROFILE ---
  Future<UserModel?> login(String identifier, String password) async {
    final clean = identifier.trim();
    final cleanPass = password.trim();

    // Query with case-insensitive check for mobile keyboard autocapitalization
    final results = await db.query(
      'users',
      where: 'LOWER(username) = ? OR LOWER(email) = ?',
      whereArgs: [clean.toLowerCase(), clean.toLowerCase()],
    );

    if (results.isEmpty) {
      // Fallback direct query
      final fallbackResults = await db.query(
        'users',
        where: 'username = ? OR email = ?',
        whereArgs: [clean, clean],
      );
      if (fallbackResults.isNotEmpty && fallbackResults.first['password'] == cleanPass) {
        return UserModel.fromMap(fallbackResults.first);
      }
      return null;
    }

    final userMap = results.first;
    if (userMap['password'] == cleanPass) {
      return UserModel.fromMap(userMap);
    }
    return null;
  }

  Future<UserModel> register(Map<String, dynamic> userData) async {
    final id = await db.insert('users', userData);
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return UserModel.fromMap({...userData, 'id': id});
  }

  Future<UserModel?> getUserById(int id) async {
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final updated = await db.update('users', data, where: 'id = ?', whereArgs: [id]);
    final postUpdates = <String, dynamic>{};
    if (data.containsKey('avatar_url')) postUpdates['author_avatar'] = data['avatar_url'];
    if (data.containsKey('name')) postUpdates['author_name'] = data['name'];
    if (data.containsKey('username')) postUpdates['author_username'] = data['username'];

    if (postUpdates.isNotEmpty) {
      await db.update('posts', postUpdates, where: 'user_id = ?', whereArgs: [id]);
    }
    return updated > 0;
  }

  // --- POSTS ---
  Future<List<PostModel>> getFeedPosts() async {
    final results = await db.query('posts', orderBy: 'id DESC');
    return results.map((m) => PostModel.fromMap(m)).toList();
  }

  Future<List<PostModel>> getUserPosts(int userId) async {
    final results = await db.query('posts', where: 'user_id = ?', whereArgs: [userId], orderBy: 'id DESC');
    return results.map((m) => PostModel.fromMap(m)).toList();
  }

  Future<void> updatePostLike(int postId, bool isLiked, int newLikesCount) async {
    await db.update(
      'posts',
      {'is_liked': isLiked ? 1 : 0, 'likes_count': newLikesCount},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<void> updatePostBookmark(int postId, bool isBookmarked, int newBookmarkCount) async {
    await db.update(
      'posts',
      {'is_bookmarked': isBookmarked ? 1 : 0, 'bookmarks_count': newBookmarkCount},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<PostModel> insertPost(Map<String, dynamic> postData) async {
    final id = await db.insert('posts', postData);
    final results = await db.query('posts', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return PostModel.fromMap(results.first);
    }
    return PostModel.fromMap({...postData, 'id': id});
  }

  // --- COMMENTS ---
  Future<List<CommentModel>> getComments(int postId) async {
    final results = await db.query('comments', where: 'post_id = ?', whereArgs: [postId]);
    return results.map((m) => CommentModel.fromMap(m)).toList();
  }

  Future<CommentModel> addComment(Map<String, dynamic> commentData) async {
    final id = await db.insert('comments', commentData);
    return CommentModel.fromMap({...commentData, 'id': id});
  }

  // --- NOTIFICATIONS ---
  Future<List<NotificationModel>> getNotifications(int userId) async {
    final results = await db.query('notifications', where: 'user_id = ?', whereArgs: [userId]);
    return results.map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await db.update('notifications', {'is_read': 1}, where: 'id = ?', whereArgs: [notificationId]);
  }

  // --- FRIENDS / COMMUNITY ---
  Future<List<FriendModel>> getFriends() async {
    final results = await db.query('friends');
    return results.map((m) => FriendModel.fromMap(m)).toList();
  }

  Future<void> updateFriendFollow(int friendId, bool isFollowing) async {
    await db.update('friends', {'is_following': isFollowing ? 1 : 0}, where: 'id = ?', whereArgs: [friendId]);
  }

  Future<void> deleteFriend(int friendId) async {
    await db.delete('friends', where: 'id = ?', whereArgs: [friendId]);
  }
}

