// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:indexed_db' as idb;
import 'package:flutter/foundation.dart';

class WebMediaStore {
  static const String _dbName = 'social_hub_storage_v1';
  static const String _storeName = 'uploaded_videos';
  static const int _dbVersion = 1;

  static html.Blob? _cachedSelectedVideoBlob;
  static final Map<String, String> _inMemoryBlobUrls = {};

  static void cacheSelectedVideoBlob(dynamic blob) {
    if (blob is html.Blob) {
      _cachedSelectedVideoBlob = blob;
    }
  }

  static dynamic getCachedSelectedVideoBlob() {
    return _cachedSelectedVideoBlob;
  }

  static void registerActiveBlobUrl(String key, String blobUrl) {
    if (key.isNotEmpty && blobUrl.isNotEmpty) {
      _inMemoryBlobUrls[key] = blobUrl;
    }
  }

  static String? getActiveBlobUrl(String key) {
    if (key.isEmpty) return null;
    return _inMemoryBlobUrls[key];
  }

  static Future<idb.Database?> _openDb() async {
    try {
      if (html.window.indexedDB == null) return null;
      return await html.window.indexedDB!.open(
        _dbName,
        version: _dbVersion,
        onUpgradeNeeded: (e) {
          final db = (e.target as idb.OpenDBRequest).result as idb.Database;
          if (!db.objectStoreNames!.contains(_storeName)) {
            db.createObjectStore(_storeName);
          }
        },
      );
    } catch (e) {
      debugPrint('IndexedDB open notice: $e');
      return null;
    }
  }

  /// Save uploaded video blob to persistent IndexedDB
  static Future<void> savePostVideo(int postId, dynamic blob) async {
    try {
      final effectiveBlob = (blob is html.Blob) ? blob : _cachedSelectedVideoBlob;
      if (effectiveBlob == null) return;

      final db = await _openDb();
      if (db == null) return;

      final tx = db.transaction(_storeName, 'readwrite');
      final store = tx.objectStore(_storeName);
      await store.put(effectiveBlob, postId.toString());
      await tx.completed;
      db.close();
      debugPrint('WebMediaStore: Saved video for post $postId to IndexedDB');
    } catch (e) {
      debugPrint('WebMediaStore: Error saving video: $e');
    }
  }

  /// Retrieve fresh playable blob URL for a post from IndexedDB
  static Future<String?> getPostVideoUrl(int postId) async {
    try {
      final db = await _openDb();
      if (db == null) return null;

      final tx = db.transaction(_storeName, 'readonly');
      final store = tx.objectStore(_storeName);
      final blob = await store.getObject(postId.toString());
      db.close();

      if (blob != null && blob is html.Blob) {
        final url = html.Url.createObjectUrl(blob);
        debugPrint('WebMediaStore: Generated fresh object URL for post $postId');
        return url;
      }
    } catch (e) {
      debugPrint('WebMediaStore: Error loading video for post $postId: $e');
    }
    return null;
  }

  /// Delete video from IndexedDB when user deletes post
  static Future<void> deletePostVideo(int postId) async {
    try {
      final db = await _openDb();
      if (db == null) return;

      final tx = db.transaction(_storeName, 'readwrite');
      final store = tx.objectStore(_storeName);
      await store.delete(postId.toString());
      await tx.completed;
      db.close();
      debugPrint('WebMediaStore: Deleted video for post $postId from IndexedDB');
    } catch (e) {
      debugPrint('WebMediaStore: Error deleting video: $e');
    }

    try {
      html.window.localStorage.remove('socialhub_thumb_$postId');
    } catch (_) {}
  }

  /// Persistent avatar storage in localStorage
  static void saveCustomAvatar(String avatarData) {
    try {
      if (avatarData.isNotEmpty) {
        html.window.localStorage['socialhub_active_user_avatar'] = avatarData;
      }
    } catch (_) {}
  }

  static String? getCustomAvatar() {
    try {
      return html.window.localStorage['socialhub_active_user_avatar'];
    } catch (_) {
      return null;
    }
  }

  /// Persistent thumbnail storage in localStorage
  static void savePostThumbnail(int postId, String thumbnailData) {
    try {
      if (thumbnailData.isNotEmpty && thumbnailData.length < 300000) {
        html.window.localStorage['socialhub_thumb_$postId'] = thumbnailData;
      }
    } catch (_) {}
  }

  static String? getPostThumbnail(int postId) {
    try {
      return html.window.localStorage['socialhub_thumb_$postId'];
    } catch (_) {
      return null;
    }
  }
}

