import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('social_hub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
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
        username TEXT UNIQUE NOT NULL COLLATE NOCASE,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL COLLATE NOCASE,
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

    await db.insert('users', {
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
    });

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

    await db.insert('posts', {
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
    });

    await db.insert('posts', {
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
    });

    await db.insert('posts', {
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
    });

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

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String table, Map<String, dynamic> data, {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}

