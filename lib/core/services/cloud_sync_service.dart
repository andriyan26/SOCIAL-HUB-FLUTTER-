import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
          return Map<String, dynamic>.from(jsonResponse['data']);
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
      final payload = jsonEncode({
        'name': 'SocialHub_Andrian_Profile',
        'data': {
          'name': name,
          'username': username,
          'bio': bio,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
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
}
