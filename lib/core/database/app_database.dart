import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  // In-memory fallback if platform (like Web) does not support native FFI
  static final Map<String, List<Map<String, dynamic>>> _webInMemoryDb = {};
  static int _autoIdCounter = 100;

  AppDatabase._init();

  Future<Database?> get database async {
    if (kIsWeb) {
      return null; // Handled seamlessly via Web fallback
    }
    if (_database != null) return _database!;
    _database = await _initDB('social_hub.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                    defaultTargetPlatform == TargetPlatform.linux || 
                    defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        avatar_url TEXT,
        bio TEXT,
        following_count INTEGER DEFAULT 0,
        followers_count INTEGER DEFAULT 0,
        likes_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Posts table
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        author_name TEXT NOT NULL,
        author_username TEXT NOT NULL,
        author_avatar TEXT,
        video_url TEXT,
        caption TEXT,
        music_title TEXT,
        likes_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        shares_count INTEGER DEFAULT 0,
        bookmarks_count INTEGER DEFAULT 0,
        is_liked INTEGER DEFAULT 0,
        is_bookmarked INTEGER DEFAULT 0,
        view_count INTEGER DEFAULT 0,
        thumbnail_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        avatar_url TEXT,
        is_read INTEGER DEFAULT 0,
        timestamp_label TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Friends table (Teman / Komunitas)
    await db.execute('''
      CREATE TABLE friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        name TEXT NOT NULL,
        avatar_url TEXT,
        subtitle TEXT,
        is_following INTEGER DEFAULT 0
      )
    ''');

    // 5. Comments table
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        user_avatar TEXT,
        text TEXT NOT NULL,
        likes_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed Initial Data
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Seed default main user: andrianpei (Matches IMG_8668)
    await db.insert('users', {
      'id': 1,
      'username': 'andrianpei',
      'name': 'Andrian Pei',
      'email': 'andriandowehz123@gmail.com',
      'password': 'password123',
      'avatar_url': 'assets/images/img_8668.jpg',
      'bio': 'Taken 🤍',
      'following_count': 0,
      'followers_count': 0,
      'likes_count': 0,
      'created_at': now,
    });

    // Seed demo secondary user (Aurelie Hermansyah - Matches IMG_8664)
    await db.insert('users', {
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
    });

    // Seed Feed Post (IMG_8664)
    await db.insert('posts', {
      'id': 1,
      'user_id': 2,
      'author_name': 'Aurelie Hermansyah',
      'author_username': 'aurelie.hermansyah',
      'author_avatar': 'assets/images/img_8664.jpg',
      'video_url': 'assets/videos/konsep_sebelum_login.mp4',
      'caption': 'Kalo ini sama kembaran aku👯',
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
    });

    // Seed Profile 3x3 Grid Posts for andrianpei (Matches IMG_8668)
    for (int i = 1; i <= 9; i++) {
      await db.insert('posts', {
        'id': i + 1,
        'user_id': 1,
        'author_name': 'Andrian Pei',
        'author_username': 'andrianpei',
        'author_avatar': 'assets/images/img_8668.jpg',
        'video_url': 'assets/videos/konsep_login.mp4',
        'caption': 'Vlog seru hari ini! Momen #$i 🚀',
        'music_title': '♫ Sound Asli - andrianpei',
        'likes_count': i * 14,
        'comments_count': i * 3,
        'shares_count': i,
        'bookmarks_count': i,
        'is_liked': 0,
        'is_bookmarked': 0,
        'view_count': (i - 1) * 12, // displays '▷ 0' or count
        'thumbnail_path': 'assets/images/img_8668.jpg',
        'created_at': now,
      });
    }

    // Seed Friends list (Matches IMG_8665)
    final friendsData = [
      {'username': 'ei.kaa', 'name': 'ei.kaa🍭', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
      {'username': 's_anime', 'name': 's', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
      {'username': 'angsuran17', 'name': 'Angsuran17', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
      {'username': 'annisasabila13', 'name': 'annisasabila13', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
      {'username': 'gasss', 'name': 'gasss', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
    ];

    for (var f in friendsData) {
      await db.insert('friends', {
        'username': f['username']!,
        'name': f['name']!,
        'avatar_url': 'assets/images/img_8665.jpg',
        'subtitle': f['subtitle']!,
        'is_following': f['is_following'] as int,
      });
    }

    // Seed Notifications (Matches IMG_8667)
    final notificationsData = [
      {
        'type': 'activity',
        'title': 'Aktivitas dan pengikut baru',
        'message': 'MPL Indonesia mengundangmu unt...',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 1,
        'timestamp_label': '1 j',
      },
      {
        'type': 'system',
        'title': 'Notifikasi sistem',
        'message': 'Asisten transaksi: Saldo akan...',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 0,
        'timestamp_label': '21 j',
      },
      {
        'type': 'bot',
        'title': 'TikTok Tako',
        'message': 'Mulainya dari mana?',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 1,
        'timestamp_label': '2 h',
      },
      {
        'type': 'shop',
        'title': 'Pesan toko',
        'message': '5 pembaruan toko dan 14...',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 0,
        'timestamp_label': '25 Okt',
      },
      {
        'type': 'direct_message',
        'title': 'andrianpei',
        'message': 'Terkirim',
        'avatar_url': 'assets/images/img_8667.jpg',
        'is_read': 1,
        'timestamp_label': 'Kemarin',
      },
    ];

    for (var n in notificationsData) {
      await db.insert('notifications', {
        'user_id': 1,
        'type': n['type']!,
        'title': n['title']!,
        'message': n['message']!,
        'avatar_url': n['avatar_url']!,
        'is_read': n['is_read'] as int,
        'timestamp_label': n['timestamp_label']!,
        'created_at': now,
      });
    }

    // Seed Comments for Post 1
    final commentsData = [
      {'user': 'budi_santoso', 'avatar': 'assets/images/img_8665.jpg', 'text': 'Keren banget videonya kak! 🔥', 'likes': 142},
      {'user': 'siti_rahma', 'avatar': 'assets/images/img_8667.jpg', 'text': 'Kembarannya lucu banget ya ampun gemeshh 😍', 'likes': 89},
      {'user': 'rizky_gaming', 'avatar': 'assets/images/img_8666.jpg', 'text': 'Sound nya nostalgia banget wkwk 🎶', 'likes': 45},
    ];

    for (var c in commentsData) {
      await db.insert('comments', {
        'post_id': 1,
        'username': c['user'] as String,
        'user_avatar': c['avatar'] as String,
        'text': c['text'] as String,
        'likes_count': c['likes'] as int,
        'created_at': now,
      });
    }
  }

  // --- UNIVERSAL QUERY HELPERS (Works on SQLite Mobile, Desktop, & Web Fallback) ---

  Future<void> initWebFallbackIfNeeded() async {
    if (_webInMemoryDb.isNotEmpty) return;

    final now = DateTime.now().toIso8601String();
    _webInMemoryDb['users'] = [
      {
        'id': 1,
        'username': 'andrianpei',
        'name': 'Andrian Pei',
        'email': 'andriandowehz123@gmail.com',
        'password': 'password123',
        'avatar_url': 'assets/images/img_8668.jpg',
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

    _webInMemoryDb['posts'] = [
      {
        'id': 1,
        'user_id': 2,
        'author_name': 'Aurelie Hermansyah',
        'author_username': 'aurelie.hermansyah',
        'author_avatar': 'assets/images/img_8664.jpg',
        'video_url': 'assets/videos/konsep_sebelum_login.mp4',
        'caption': 'Kalo ini sama kembaran aku👯',
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
      ...List.generate(9, (index) => {
        'id': index + 2,
        'user_id': 1,
        'author_name': 'Andrian Pei',
        'author_username': 'andrianpei',
        'author_avatar': 'assets/images/img_8668.jpg',
        'video_url': 'assets/videos/konsep_login.mp4',
        'caption': 'Vlog seru hari ini! Momen #${index + 1} 🚀',
        'music_title': '♫ Sound Asli - andrianpei',
        'likes_count': (index + 1) * 14,
        'comments_count': (index + 1) * 3,
        'shares_count': index + 1,
        'bookmarks_count': index + 1,
        'is_liked': 0,
        'is_bookmarked': 0,
        'view_count': index * 12,
        'thumbnail_path': 'assets/images/img_8668.jpg',
        'created_at': now,
      })
    ];

    _webInMemoryDb['friends'] = [
      {'id': 1, 'username': 'ei.kaa', 'name': 'ei.kaa🍭', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
      {'id': 2, 'username': 's_anime', 'name': 's', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
      {'id': 3, 'username': 'angsuran17', 'name': 'Angsuran17', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Membagikan video kepada Anda', 'is_following': 0},
      {'id': 4, 'username': 'annisasabila13', 'name': 'annisasabila13', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
      {'id': 5, 'username': 'gasss', 'name': 'gasss', 'avatar_url': 'assets/images/img_8665.jpg', 'subtitle': 'Orang yang mungkin Anda kenal', 'is_following': 0},
    ];

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

    _webInMemoryDb['comments'] = [
      {'id': 1, 'post_id': 1, 'username': 'budi_santoso', 'user_avatar': 'assets/images/img_8665.jpg', 'text': 'Keren banget videonya kak! 🔥', 'likes_count': 142, 'created_at': now},
      {'id': 2, 'post_id': 1, 'username': 'siti_rahma', 'user_avatar': 'assets/images/img_8667.jpg', 'text': 'Kembarannya lucu banget ya ampun gemeshh 😍', 'likes_count': 89, 'created_at': now},
      {'id': 3, 'post_id': 1, 'username': 'rizky_gaming', 'user_avatar': 'assets/images/img_8666.jpg', 'text': 'Sound nya nostalgia banget wkwk 🎶', 'likes_count': 45, 'created_at': now},
    ];
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    if (kIsWeb) {
      await initWebFallbackIfNeeded();
      final list = _webInMemoryDb[table] ?? [];
      // Apply simple filtering if provided
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        if (where.contains('username = ?') || where.contains('email = ?')) {
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

    final db = await database;
    if (db == null) return [];
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (kIsWeb) {
      await initWebFallbackIfNeeded();
      final mutable = Map<String, dynamic>.from(data);
      if (!mutable.containsKey('id') || mutable['id'] == null) {
        mutable['id'] = ++_autoIdCounter;
      }
      _webInMemoryDb.putIfAbsent(table, () => []).add(mutable);
      return mutable['id'] as int;
    }

    final db = await database;
    if (db == null) return 0;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String table, Map<String, dynamic> data, {required String where, required List<dynamic> whereArgs}) async {
    if (kIsWeb) {
      await initWebFallbackIfNeeded();
      final list = _webInMemoryDb[table] ?? [];
      int count = 0;
      if (where.contains('id = ?')) {
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

    final db = await database;
    if (db == null) return 0;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {required String where, required List<dynamic> whereArgs}) async {
    if (kIsWeb) {
      await initWebFallbackIfNeeded();
      final list = _webInMemoryDb[table] ?? [];
      int before = list.length;
      if (where.contains('id = ?')) {
        final id = whereArgs.first;
        list.removeWhere((item) => item['id'] == id);
      }
      return before - list.length;
    }

    final db = await database;
    if (db == null) return 0;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
