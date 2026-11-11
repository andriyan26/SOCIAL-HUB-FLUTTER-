class WebMediaStore {
  static void cacheSelectedVideoBlob(dynamic blob) {}
  static dynamic getCachedSelectedVideoBlob() => null;
  static void registerActiveBlobUrl(String key, String blobUrl) {}
  static String? getActiveBlobUrl(String key) => null;
  static Future<void> savePostVideo(int postId, dynamic blob) async {}
  static Future<String?> getPostVideoUrl(int postId) async => null;
  static Future<void> deletePostVideo(int postId) async {}
  static void saveCustomAvatar(String avatarData) {}
  static String? getCustomAvatar() => null;
  static void savePostThumbnail(int postId, String thumbnailData) {}
  static String? getPostThumbnail(int postId) => null;
}

