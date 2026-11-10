import 'dart:async';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static final Map<String, List<Map<String, dynamic>>> _webInMemoryDb = {};
  static int _autoIdCounter = 100;
  static bool _isSeeded = false;

  AppDatabase._init() {
    _initWebData();
  }

  void _initWebData() {
    if (_isSeeded) return;
    _isSeeded = true;
    final now = DateTime.now().toIso8601String();

    // 1. Users
    _webInMemoryDb['users'] = [
      {
        'id': 1,
        'username': 'andrianpei',
        'name': 'Andrian Pei',
        'email': 'andriandowehz123@gmail.com',
        'password': 'password123',
        'avatar_url': 'assets/images/andrian_feed_poster.jpg',
        'bio': 'Taken 🤍',
        'following_count': 0,
        'followers_count': 0,
        'likes_count': 0,
        'created_at': now,
      },
      {
        'id': 2,
        'username': 'aurelie.hermansyah',
        'name': 'Aurelie Hermansyah',
        'email': 'aurel@socialhub.com',
        'password': 'password123',
        'avatar_url': 'assets/images/img_8664.jpg',
        'bio': 'Content Creator & Musician ✨',
        'following_count': 234,
        'followers_count': 844000,
        'likes_count': 3200000,
        'created_at': now,
      }
    ];

    // 2. Posts (Feed posts + Profile grid posts)
    _webInMemoryDb['posts'] = [
      {
        'id': 1,
        'user_id': 1,
        'author_name': 'Andrian Pei',
        'author_username': 'andrianpei',
        'author_avatar': 'assets/images/andrian_feed_poster.jpg',
        'video_url': 'assets/videos/andrian_feed.mp4',
        'caption': 'Wisuda Sarjana Teknik Informatika S1 🎓 IPK 3.73 Wisudawan Terbaik! Terima kasih untuk semua dukungannya ✨ #wisuda #unpam #informatika #fyp',
        'music_title': '♫ Berisi: Sound Wisuda Bangga (Original) - andrianpei',
        'likes_count': 844300,
        'comments_count': 3322,
        'shares_count': 12300,
        'bookmarks_count': 17100,
        'is_liked': 0,
        'is_bookmarked': 0,
        'view_count': 182000,
        'thumbnail_path': 'assets/images/andrian_feed_poster.jpg',
        'created_at': now,
      },
      {
        'id': 2,
        'user_id': 2,
        'author_name': 'Aurelie Hermansyah',
        'author_username': 'aurelie.hermansyah',
        'author_avatar': 'assets/images/img_8664.jpg',
        'video_url': 'assets/videos/konsep_sebelum_login.mp4',
        'caption': 'Kalo ini sama kembaran aku👯‍♀️',
        'music_title': '♫ Berisi: Anak Kampung (T...',
        'likes_count': 844300,
        'comments_count': 3322,
        'shares_count': 12300,
        'bookmarks_count': 17100,
        'is_liked': 0,
        'is_bookmarked': 0,
        'view_count': 1520000,
        'thumbnail_path': 'assets/images/img_8664.jpg',
        'created_at': now,
      },
      {
        'id': 3,
        'user_id': 3,
        'author_name': 'ei.kaa🍭',
        'author_username': 'ei.kaa',
        'author_avatar': 'assets/images/img_8665.jpg',
        'video_url': 'assets/videos/konsep_sebelum_login.mp4',
        'caption': 'Seru banget jalan-jalan sore bareng bestie! Jangan lupa follow dan like ya guys ✨ #friends #vlog',
        'music_title': '♫ Beat Aesthetic Viral 2026',
        'likes_count': 95400,
        'comments_count': 890,
        'shares_count': 2800,
        'bookmarks_count': 5600,
        'is_liked': 0,
        'is_bookmarked': 0,
        'view_count': 280000,
        'thumbnail_path': 'assets/images/img_8665.jpg',
        'created_at': now,
      },
    ];

    // 3. Friends
    _webInMemoryDb['friends'] = [
      {'id': 1, 'username': 'ei.kaa', 'name': 'ei.kaa🍭', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
      {'id': 2, 'username': 's_anime', 'name': 's', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
      {'id': 3, 'username': 'angsuran17', 'name': 'Angsuran17', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
      {'id': 4, 'username': 'annisasabila13', 'name': 'annisasabila13', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
      {'id': 5, 'username': 'gasss', 'name': 'gasss', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
    ];

    // 4. Notifications
    _webInMemoryDb['notifications'] = [
      {
        'id': 1,
        'user_id': 1,
        'type': 'activity',
        'title': 'Aktivitas dan pengikut baru',
        'message': 'MPL Indonesia mengundangmu unt...',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 1,
        'timestamp_label': '1 j',
        'created_at': now,
      },
      {
        'id': 2,
        'user_id': 1,
        'type': 'system',
        'title': 'Notifikasi sistem',
        'message': 'Asisten transaksi: Saldo akan...',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 0,
        'timestamp_label': '21 j',
        'created_at': now,
      },
      {
        'id': 3,
        'user_id': 1,
        'type': 'bot',
        'title': 'TikTok Tako',
        'message': 'Mulainya dari mana?',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 1,
        'timestamp_label': '2 h',
        'created_at': now,
      },
      {
        'id': 4,
        'user_id': 1,
        'type': 'shop',
        'title': 'Pesan toko',
        'message': '5 pembaruan toko dan 14...',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 0,
        'timestamp_label': '25 Okt',
        'created_at': now,
      },
      {
        'id': 5,
        'user_id': 1,
        'type': 'direct_message',
        'title': 'andrianpei',
        'message': 'Terkirim',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 1,
        'timestamp_label': 'Kemarin',
        'created_at': now,
      },
    ];

    // 5. Comments
    _webInMemoryDb['comments'] = [
      {'id': 1, 'post_id': 1, 'username': 'budi_santoso', 'user_avatar': 'assets/images/img_8665.jpg', 'text': 'Keren banget videonya kak! 🔥', 'likes_count': 142, 'created_at': now},
      {'id': 2, 'post_id': 1, 'username': 'siti_rahma', 'user_avatar': 'assets/images/img_8667.jpg', 'text': 'Kembarannya lucu banget ya ampun gemeshh 😍', 'likes_count': 89, 'created_at': now},
      {'id': 3, 'post_id': 1, 'username': 'rizky_gaming', 'user_avatar': 'assets/images/img_8666.jpg', 'text': 'Sound nya nostalgia banget wkwk 🎶', 'likes_count': 45, 'created_at': now},
    ];
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    _initWebData();
    final list = _webInMemoryDb[table] ?? [];
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      if (where.toLowerCase().contains('username') || where.toLowerCase().contains('email')) {
        final queryVal = whereArgs.first.toString().toLowerCase();
        return list.where((row) {
          final u = (row['username'] ?? '').toString().toLowerCase();
          final e = (row['email'] ?? '').toString().toLowerCase();
          return u == queryVal || e == queryVal;
        }).toList();
      }
      if (where.contains('user_id = ?')) {
        final targetUserId = whereArgs.first;
        return list.where((row) => row['user_id'] == targetUserId).toList();
      }
      if (where.contains('post_id = ?')) {
        final targetPostId = whereArgs.first;
        return list.where((row) => row['post_id'] == targetPostId).toList();
      }
      if (where.contains('id = ?')) {
        final targetId = whereArgs.first;
        return list.where((row) => row['id'] == targetId).toList();
      }
    }
    return List<Map<String, dynamic>>.from(list);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    _initWebData();
    final mutable = Map<String, dynamic>.from(data);
    if (!mutable.containsKey('id') || mutable['id'] == null) {
      mutable['id'] = ++_autoIdCounter;
    }
    _webInMemoryDb.putIfAbsent(table, () => []).add(mutable);
    return mutable['id'] as int;
  }

  Future<int> update(String table, Map<String, dynamic> data, {required String where, required List<dynamic> whereArgs}) async {
    _initWebData();
    final list = _webInMemoryDb[table] ?? [];
    int count = 0;
    if (where.contains('user_id = ?')) {
      final userId = whereArgs.first;
      for (int i = 0; i < list.length; i++) {
        if (list[i]['user_id'] == userId) {
          list[i] = {...list[i], ...data};
          count++;
        }
      }
    } else if (where.contains('post_id = ?')) {
      final postId = whereArgs.first;
      for (int i = 0; i < list.length; i++) {
        if (list[i]['post_id'] == postId) {
          list[i] = {...list[i], ...data};
          count++;
        }
      }
    } else if (where.contains('username = ?')) {
      final username = whereArgs.first.toString().toLowerCase();
      for (int i = 0; i < list.length; i++) {
        if ((list[i]['username'] ?? '').toString().toLowerCase() == username) {
          list[i] = {...list[i], ...data};
          count++;
        }
      }
    } else if (where.contains('id = ?')) {
      final id = whereArgs.first;
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == id) {
          list[i] = {...list[i], ...data};
          count++;
        }
      }
    }
    return count;
  }

  Future<int> delete(String table, {required String where, required List<dynamic> whereArgs}) async {
    _initWebData();
    final list = _webInMemoryDb[table] ?? [];
    int before = list.length;
    if (where.contains('user_id = ?')) {
      final userId = whereArgs.first;
      list.removeWhere((item) => item['user_id'] == userId);
    } else if (where.contains('post_id = ?')) {
      final postId = whereArgs.first;
      list.removeWhere((item) => item['post_id'] == postId);
    } else if (where.contains('id = ?')) {
      final id = whereArgs.first;
      list.removeWhere((item) => item['id'] == id);
    }
    return before - list.length;
  }
}

