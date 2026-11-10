import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/domain/entities/post_entity.dart';

class CloudSyncService {
  static const String _cloudEndpoint = 'https://api.restful-api.dev/objects/ff808181a09d98f701a1c54607417d35';

  /// Fetch user profile from cloud database
  static Future<Map<String, dynamic>?> fetchCloudUser() async {
    try {
      final response = await http.get(
        Uri.parse(_cloudEndpoint),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null) {
          final data = Map<String, dynamic>.from(jsonResponse['data']);
          final avatar = data['avatar_url']?.toString() ?? '';
          // Ensure avatar is never a dead blob URL or purple initial
          if (avatar.startsWith('blob:') || avatar.isEmpty || avatar == 'purple_a') {
            data['avatar_url'] = AppAssets.imgProfile;
          }
          return data;
        }
      }
    } catch (e) {
      debugPrint('Notice fetching cloud profile: $e');
    }
    return null;
  }

  /// Sync updated profile to cloud database so changes immediately propagate across Web & Mobile
  static Future<bool> syncProfileToCloud({
    required String name,
    required String username,
    required String bio,
    required String avatarUrl,
  }) async {
    try {
      // 1. Get current data to preserve existing posts
      List<dynamic> existingPosts = [];
      try {
        final current = await http.get(Uri.parse(_cloudEndpoint)).timeout(const Duration(seconds: 5));
        if (current.statusCode == 200) {
          final decoded = jsonDecode(current.body);
          if (decoded['data'] != null && decoded['data']['posts'] is List) {
            existingPosts = decoded['data']['posts'];
          }
        }
      } catch (_) {}

      // Clean avatar to ensure safe fallback
      final safeAvatar = (avatarUrl.startsWith('blob:') || avatarUrl.isEmpty || avatarUrl == 'purple_a')
          ? AppAssets.imgProfile
          : avatarUrl;

      final payload = jsonEncode({
        'name': 'SocialHub_Andrian_Profile',
        'data': {
          'name': name,
          'username': username,
          'bio': bio,
          'avatar_url': safeAvatar,
          'updated_at': DateTime.now().toIso8601String(),
          'posts': existingPosts,
        }
      });

      final response = await http.put(
        Uri.parse(_cloudEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Notice syncing profile to cloud: $e');
      return false;
    }
  }

  /// Fetch posts from cloud database
  static Future<List<Map<String, dynamic>>> fetchCloudPosts() async {
    try {
      final response = await http.get(
        Uri.parse(_cloudEndpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data']['posts'] is List) {
          final list = (jsonResponse['data']['posts'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          return list;
        }
      }
    } catch (e) {
      debugPrint('Notice fetching cloud posts: $e');
    }
    return [];
  }

  /// Sync newly published post to cloud database
  static Future<bool> syncPostToCloud(PostEntity post) async {
    try {
      // 1. Get existing data
      Map<String, dynamic> currentData = {
        'name': 'Andrian',
        'username': 'andrianpei',
        'bio': 'Ya Sudahlah aku yaaa ah jangan ya ini mah !',
        'avatar_url': AppAssets.imgProfile,
        'posts': [],
      };

      try {
        final current = await http.get(Uri.parse(_cloudEndpoint)).timeout(const Duration(seconds: 5));
        if (current.statusCode == 200) {
          final decoded = jsonDecode(current.body);
          if (decoded['data'] != null) {
            currentData = Map<String, dynamic>.from(decoded['data']);
          }
        }
      } catch (_) {}

      final List<dynamic> existingPosts = (currentData['posts'] is List) ? List.from(currentData['posts']) : [];

      // Avoid duplicate post IDs
      final postMap = {
        'id': post.id,
        'user_id': post.userId,
        'author_name': post.authorName,
        'author_username': post.authorUsername,
        'author_avatar': post.authorAvatar,
        'video_url': post.videoUrl.isNotEmpty ? post.videoUrl : AppAssets.videoLanding,
        'caption': post.caption,
        'music_title': post.musicTitle,
        'likes_count': post.likesCount,
        'comments_count': post.commentsCount,
        'shares_count': post.sharesCount,
        'bookmarks_count': post.bookmarksCount,
        'is_liked': post.isLiked ? 1 : 0,
        'is_bookmarked': post.isBookmarked ? 1 : 0,
        'is_reposted': post.isReposted ? 1 : 0,
        'is_private': post.isPrivate ? 1 : 0,
        'view_count': post.viewCount,
        'thumbnail_path': post.thumbnailPath.isNotEmpty ? post.thumbnailPath : AppAssets.imgFeed,
        'created_at': post.createdAt,
      };

      existingPosts.removeWhere((p) => p['id'] == post.id);
      existingPosts.insert(0, postMap);
      currentData['posts'] = existingPosts;
      currentData['updated_at'] = DateTime.now().toIso8601String();

      final payload = jsonEncode({
        'name': 'SocialHub_Andrian_Profile',
        'data': currentData,
      });

      final response = await http.put(
        Uri.parse(_cloudEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Notice syncing post to cloud: $e');
      return false;
    }
  }
}
