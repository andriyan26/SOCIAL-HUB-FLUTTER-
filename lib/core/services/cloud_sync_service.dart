import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:social_hub/core/constants/app_assets.dart';
import 'package:social_hub/domain/entities/post_entity.dart';

class CloudSyncService {
  static const String _fallbackCloudEndpoint = 'https://api.restful-api.dev/objects/ff808181a09d98f701a1c54607417d35';

  static String get _hostingerSyncEndpoint {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (!origin.contains('github.io') && (origin.startsWith('http://') || origin.startsWith('https://'))) {
          return '$origin/api/sync.php';
        }
      } catch (_) {}
    }
    return '';
  }

  static String get _hostingerPostsEndpoint {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (!origin.contains('github.io') && (origin.startsWith('http://') || origin.startsWith('https://'))) {
          return '$origin/api/posts.php';
        }
      } catch (_) {}
    }
    return '';
  }

  /// Fetch user profile from cloud database (Hostinger MySQL priority with cloud fallback)
  static Future<Map<String, dynamic>?> fetchCloudUser() async {
    // 1. Try Hostinger API first if hosted on Hostinger
    final hostingerUrl = _hostingerSyncEndpoint;
    if (hostingerUrl.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(hostingerUrl),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['data'] != null) {
            final data = Map<String, dynamic>.from(jsonResponse['data']);
            final avatar = data['avatar_url']?.toString() ?? '';
            if (avatar == 'custom_avatar') {
              data.remove('avatar_url');
            } else if (avatar.startsWith('blob:') || avatar.isEmpty) {
              data['avatar_url'] = AppAssets.imgProfile;
            }
            return data;
          }
        }
      } catch (e) {
        debugPrint('Hostinger sync fetch notice: $e');
      }
    }

    // 2. Fallback to secondary cloud endpoint
    try {
      final response = await http.get(
        Uri.parse(_fallbackCloudEndpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null) {
          final data = Map<String, dynamic>.from(jsonResponse['data']);
          final avatar = data['avatar_url']?.toString() ?? '';
          
          if (avatar == 'custom_avatar') {
            data.remove('avatar_url');
          } else if (avatar.startsWith('blob:') || avatar.isEmpty) {
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
    final safeAvatar = (avatarUrl.startsWith('data:') || avatarUrl.length > 500)
        ? 'custom_avatar'
        : (avatarUrl.startsWith('blob:') || avatarUrl.isEmpty)
            ? AppAssets.imgProfile
            : avatarUrl;

    // 1. Hostinger sync
    final hostingerUrl = _hostingerSyncEndpoint;
    if (hostingerUrl.isNotEmpty) {
      try {
        await http.post(
          Uri.parse(hostingerUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'username': username,
            'bio': bio,
            'avatar_url': safeAvatar,
          }),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    // 2. Fallback cloud sync
    try {
      List<dynamic> existingPosts = [];
      try {
        final current = await http.get(Uri.parse(_fallbackCloudEndpoint)).timeout(const Duration(seconds: 4));
        if (current.statusCode == 200) {
          final decoded = jsonDecode(current.body);
          if (decoded['data'] != null && decoded['data']['posts'] is List) {
            existingPosts = decoded['data']['posts'];
          }
        }
      } catch (_) {}

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
        Uri.parse(_fallbackCloudEndpoint),
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
    // 1. Try Hostinger API first
    final hostingerUrl = _hostingerSyncEndpoint;
    if (hostingerUrl.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(hostingerUrl),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 4));

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
        debugPrint('Hostinger posts fetch notice: $e');
      }
    }

    // 2. Fallback cloud endpoint
    try {
      final response = await http.get(
        Uri.parse(_fallbackCloudEndpoint),
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
    final safeThumbnail = (post.thumbnailPath.startsWith('data:') || post.thumbnailPath.length > 500)
        ? AppAssets.imgFeed
        : (post.thumbnailPath.isNotEmpty ? post.thumbnailPath : AppAssets.imgFeed);

    final safeVideo = (post.videoUrl.startsWith('blob:') || post.videoUrl.isEmpty)
        ? AppAssets.videoLanding
        : post.videoUrl;

    final postMap = {
      'id': post.id,
      'user_id': post.userId,
      'author_name': post.authorName,
      'author_username': post.authorUsername,
      'author_avatar': post.authorAvatar.length > 500 ? AppAssets.imgProfile : post.authorAvatar,
      'video_url': safeVideo,
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
      'thumbnail_path': safeThumbnail,
      'created_at': post.createdAt,
    };

    // 1. Sync to Hostinger MySQL
    final hostingerUrl = _hostingerSyncEndpoint;
    if (hostingerUrl.isNotEmpty) {
      try {
        await http.post(
          Uri.parse(hostingerUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'posts': [postMap]
          }),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    // 2. Sync to fallback cloud
    try {
      Map<String, dynamic> currentData = {
        'name': 'Andrian',
        'username': 'andrianpei',
        'bio': 'Ya Sudahlah aku yaaa ah jangan ya ini mah !',
        'avatar_url': AppAssets.imgProfile,
        'posts': [],
      };

      try {
        final current = await http.get(Uri.parse(_fallbackCloudEndpoint)).timeout(const Duration(seconds: 4));
        if (current.statusCode == 200) {
          final decoded = jsonDecode(current.body);
          if (decoded['data'] != null) {
            currentData = Map<String, dynamic>.from(decoded['data']);
          }
        }
      } catch (_) {}

      final List<dynamic> existingPosts = (currentData['posts'] is List) ? List.from(currentData['posts']) : [];
      existingPosts.removeWhere((p) => p['id'] == post.id);
      existingPosts.insert(0, postMap);
      currentData['posts'] = existingPosts;
      currentData['updated_at'] = DateTime.now().toIso8601String();

      final payload = jsonEncode({
        'name': 'SocialHub_Andrian_Profile',
        'data': currentData,
      });

      final response = await http.put(
        Uri.parse(_fallbackCloudEndpoint),
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

  /// Delete post from cloud database so it disappears across all devices
  static Future<bool> deleteCloudPost(int postId) async {
    // 1. Delete on Hostinger MySQL
    final hostingerPostsUrl = _hostingerPostsEndpoint;
    if (hostingerPostsUrl.isNotEmpty) {
      try {
        await http.delete(
          Uri.parse('$hostingerPostsUrl?id=$postId'),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    // 2. Delete on fallback cloud
    try {
      final current = await http.get(Uri.parse(_fallbackCloudEndpoint)).timeout(const Duration(seconds: 4));
      if (current.statusCode != 200) return false;

      final decoded = jsonDecode(current.body);
      if (decoded['data'] == null) return false;

      final currentData = Map<String, dynamic>.from(decoded['data']);
      final List<dynamic> existingPosts = (currentData['posts'] is List) ? List.from(currentData['posts']) : [];

      existingPosts.removeWhere((p) {
        final pid = p['id'] is int ? p['id'] as int : int.tryParse(p['id'].toString()) ?? 0;
        return pid == postId;
      });

      currentData['posts'] = existingPosts;
      currentData['updated_at'] = DateTime.now().toIso8601String();

      final payload = jsonEncode({
        'name': 'SocialHub_Andrian_Profile',
        'data': currentData,
      });

      final response = await http.put(
        Uri.parse(_fallbackCloudEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Notice deleting cloud post: $e');
      return false;
    }
  }
}
