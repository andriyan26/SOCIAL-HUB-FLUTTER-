import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static final Map<String, List<Map<String, dynamic>>> _webInMemoryDb = {};
  static int _autoIdCounter = 500;
  static bool _isInitialized = false;

  AppDatabase._init() {
    _initWebData();
  }

  void _saveTableToStorage(String table) {
    try {
      final list = _webInMemoryDb[table];
      if (list != null) {
        // Strip out massive blobs exceeding 1MB if any to prevent localStorage quota crash
        final safeList = list.map((item) {
          final copy = Map<String, dynamic>.from(item);
          copy.forEach((k, v) {
            if (v is String && v.length > 800000 && v.startsWith('data:')) {
              if (k == 'avatar_url' || k == 'author_avatar') {
                copy[k] = 'assets/images/img_8668.jpg';
              } else {
                copy[k] = 'assets/images/img_feed.jpg';
              }
            }
          });
          return copy;
        }).toList();

        html.window.localStorage['socialhub_db_$table'] = jsonEncode(safeList);
      }
    } catch (e) {
      // Storage quota or private browsing safety
    }
  }

  void _initWebData() {
    if (_isInitialized) return;
    _isInitialized = true;
    final now = DateTime.now().toIso8601String();

    final tables = ['users', 'posts', 'friends', 'notifications', 'comments'];

    for (final table in tables) {
      try {
        final savedJson = html.window.localStorage['socialhub_db_$table'];
        if (savedJson != null && savedJson.isNotEmpty) {
          final decoded = jsonDecode(savedJson);
          if (decoded is List) {
            _webInMemoryDb[table] = decoded
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
            continue;
          }
        }
      } catch (_) {}
      // If table not in localStorage, seed with defaults
      _seedDefaultTable(table, now);
      _saveTableToStorage(table);
    }

    // Restore persistent active avatar if saved by user
    try {
      final activeAvatar = html.window.localStorage['socialhub_active_user_avatar'];
      if (activeAvatar != null && activeAvatar.isNotEmpty && _webInMemoryDb['users'] != null) {
        for (final u in _webInMemoryDb['users']!) {
          if (u['id'] == 1 || (u['username'] ?? '').toString().toLowerCase() == 'andrianpei') {
            u['avatar_url'] = activeAvatar;
          }
        }
        if (_webInMemoryDb['posts'] != null) {
          for (final p in _webInMemoryDb['posts']!) {
            if (p['user_id'] == 1 || (p['author_username'] ?? '').toString().toLowerCase() == 'andrianpei') {
              p['author_avatar'] = activeAvatar;
            }
          }
        }
      }
    } catch (_) {}
  }

  void _seedDefaultTable(String table, String now) {
    switch (table) {
      case 'users':
        _webInMemoryDb['users'] = [
          {
            'id': 1,
            'username': 'andrianpei',
            'name': 'Andrian',
            'email': 'andriandowehz123@gmail.com',
            'password': 'password123',
            'avatar_url': 'assets/images/img_8668.jpg',
            'bio': 'Ya Sudahilah',
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
        break;

      case 'posts':
        _webInMemoryDb['posts'] = [
          {
            'id': 1,
            'user_id': 1,
            'author_name': 'Andrian',
            'author_username': 'andrianpei',
            'author_avatar': 'assets/images/img_8668.jpg',
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
        break;

      case 'friends':
        _webInMemoryDb['friends'] = [
          {'id': 1, 'username': 'ei.kaa', 'name': 'ei.kaa🍭', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
          {'id': 2, 'username': 's_anime', 'name': 's', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
          {'id': 3, 'username': 'angsuran17', 'name': 'Angsuran17', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
          {'id': 4, 'username': 'annisasabila13', 'name': 'annisasabila13', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
          {'id': 5, 'username': 'gasss', 'name': 'gasss', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
        ];
        break;

      case 'notifications':
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
        break;

      case 'comments':
        _webInMemoryDb['comments'] = [
          {'id': 1, 'post_id': 1, 'username': 'budi_santoso', 'user_avatar': 'assets/images/img_8665.jpg', 'text': 'Keren banget videonya kak! 🔥', 'likes_count': 142, 'created_at': now},
          {'id': 2, 'post_id': 1, 'username': 'siti_rahma', 'user_avatar': 'assets/images/img_8667.jpg', 'text': 'Kembarannya lucu banget ya ampun gemeshh 😍', 'likes_count': 89, 'created_at': now},
          {'id': 3, 'post_id': 1, 'username': 'rizky_gaming', 'user_avatar': 'assets/images/img_8666.jpg', 'text': 'Sound nya nostalgia banget wkwk 🎶', 'likes_count': 45, 'created_at': now},
        ];
        break;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    _initWebData();
    List<Map<String, dynamic>> list = _webInMemoryDb[table] ?? [];

    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      if (where.toLowerCase().contains('username') || where.toLowerCase().contains('email')) {
        final queryVal = whereArgs.first.toString().toLowerCase();
        list = list.where((row) {
          final u = (row['username'] ?? '').toString().toLowerCase();
          final e = (row['email'] ?? '').toString().toLowerCase();
          return u == queryVal || e == queryVal;
        }).toList();
      } else if (where.contains('is_liked = ?')) {
        final target = whereArgs.first.toString();
        list = list.where((row) => (row['is_liked'] ?? 0).toString() == target || (target == '1' && row['is_liked'] == true)).toList();
      } else if (where.contains('is_bookmarked = ?')) {
        final target = whereArgs.first.toString();
        list = list.where((row) => (row['is_bookmarked'] ?? 0).toString() == target || (target == '1' && row['is_bookmarked'] == true)).toList();
      } else if (where.contains('is_reposted = ?')) {
        final target = whereArgs.first.toString();
        list = list.where((row) => (row['is_reposted'] ?? 0).toString() == target || (target == '1' && row['is_reposted'] == true)).toList();
      } else if (where.contains('user_id = ? AND is_private = ?') && whereArgs.length >= 2) {
        final targetUserId = whereArgs[0].toString();
        final targetPrivate = whereArgs[1].toString();
        list = list.where((row) =>
          (row['user_id'] ?? '').toString() == targetUserId &&
          ((row['is_private'] ?? 0).toString() == targetPrivate || (targetPrivate == '1' && row['is_private'] == true))
        ).toList();
      } else if (where.contains('user_id = ?')) {
        final targetUserId = whereArgs.first.toString();
        list = list.where((row) => (row['user_id'] ?? '').toString() == targetUserId).toList();
      } else if (where.contains('post_id = ?')) {
        final targetPostId = whereArgs.first.toString();
        list = list.where((row) => (row['post_id'] ?? '').toString() == targetPostId).toList();
      } else if (where.contains('id = ?')) {
        final targetId = whereArgs.first.toString();
        list = list.where((row) => (row['id'] ?? '').toString() == targetId).toList();
      }
    }

    final result = list.map((m) => Map<String, dynamic>.from(m)).toList();

    // Order By support (e.g. 'id DESC', 'id ASC')
    if (orderBy != null) {
      final isDesc = orderBy.toUpperCase().contains('DESC');
      result.sort((a, b) {
        final idA = (a['id'] is num) ? (a['id'] as num) : int.tryParse(a['id'].toString()) ?? 0;
        final idB = (b['id'] is num) ? (b['id'] as num) : int.tryParse(b['id'].toString()) ?? 0;
        return isDesc ? idB.compareTo(idA) : idA.compareTo(idB);
      });
    }

    return result;
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    _initWebData();
    final mutable = Map<String, dynamic>.from(data);
    if (!mutable.containsKey('id') || mutable['id'] == null) {
      mutable['id'] = DateTime.now().millisecondsSinceEpoch;
    }
    _webInMemoryDb.putIfAbsent(table, () => []).add(mutable);
    _saveTableToStorage(table);
    return mutable['id'] as int;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    _initWebData();
    final list = _webInMemoryDb[table] ?? [];
    int count = 0;

    if (where.contains('user_id = ?')) {
      final userId = whereArgs.first.toString();
      for (int i = 0; i < list.length; i++) {
        if ((list[i]['user_id'] ?? '').toString() == userId) {
          list[i] = {...list[i], ...data};
          count++;
        }
      }
    } else if (where.contains('post_id = ?')) {
      final postId = whereArgs.first.toString();
      for (int i = 0; i < list.length; i++) {
        if ((list[i]['post_id'] ?? '').toString() == postId) {
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
      final id = whereArgs.first.toString();
      for (int i = 0; i < list.length; i++) {
        if ((list[i]['id'] ?? '').toString() == id) {
          list[i] = {...list[i], ...data};
          count++;
        }
      }
    }

    // Save updated table to localStorage
    _saveTableToStorage(table);

    // If users table is updated, cascade author changes into posts table
    if (table == 'users') {
      final posts = _webInMemoryDb['posts'];
      if (posts != null) {
        final targetUserId = whereArgs.isNotEmpty ? whereArgs.first.toString() : '1';
        for (int i = 0; i < posts.length; i++) {
          if ((posts[i]['user_id'] ?? '').toString() == targetUserId ||
              (posts[i]['author_username'] ?? '').toString().toLowerCase() == 'andrianpei') {
            final updatedPost = Map<String, dynamic>.from(posts[i]);
            if (data.containsKey('name')) updatedPost['author_name'] = data['name'];
            if (data.containsKey('username')) updatedPost['author_username'] = data['username'];
            if (data.containsKey('avatar_url')) updatedPost['author_avatar'] = data['avatar_url'];
            posts[i] = updatedPost;
          }
        }
        _saveTableToStorage('posts');
      }
    }

    return count;
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    _initWebData();
    final list = _webInMemoryDb[table] ?? [];
    int before = list.length;

    if (where.contains('user_id = ?')) {
      final userId = whereArgs.first.toString();
      list.removeWhere((item) => (item['user_id'] ?? '').toString() == userId);
    } else if (where.contains('post_id = ?')) {
      final postId = whereArgs.first.toString();
      list.removeWhere((item) => (item['post_id'] ?? '').toString() == postId);
    } else if (where.contains('id = ?')) {
      final id = whereArgs.first.toString();
      list.removeWhere((item) => (item['id'] ?? '').toString() == id);
    }

    _saveTableToStorage(table);
    return before - list.length;
  }
}
