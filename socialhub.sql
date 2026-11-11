-- ========================================================
-- Social Hub Database Schema & Seed Data for Hostinger MySQL
-- Database: u975115372_SocialHub12345
-- Created for: Andrian (Social Hub Flutter App)
-- ========================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- Table structure for `users`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `name` VARCHAR(150) NOT NULL,
  `email` VARCHAR(191) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `avatar_url` TEXT NULL,
  `bio` TEXT NULL,
  `following_count` INT DEFAULT 0,
  `followers_count` INT DEFAULT 0,
  `likes_count` INT DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `posts`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL DEFAULT 1,
  `author_name` VARCHAR(150) NOT NULL,
  `author_username` VARCHAR(100) NOT NULL,
  `author_avatar` TEXT NULL,
  `video_url` TEXT NOT NULL,
  `caption` TEXT NULL,
  `music_title` VARCHAR(255) DEFAULT '♫ Sound Asli - andrianpei',
  `likes_count` INT DEFAULT 0,
  `comments_count` INT DEFAULT 0,
  `shares_count` INT DEFAULT 0,
  `bookmarks_count` INT DEFAULT 0,
  `is_liked` TINYINT(1) DEFAULT 0,
  `is_bookmarked` TINYINT(1) DEFAULT 0,
  `is_reposted` TINYINT(1) DEFAULT 0,
  `is_private` TINYINT(1) DEFAULT 0,
  `view_count` INT DEFAULT 0,
  `thumbnail_path` TEXT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX (`user_id`),
  INDEX (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `comments`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `post_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED DEFAULT 1,
  `username` VARCHAR(100) NOT NULL,
  `user_avatar` TEXT NULL,
  `text` TEXT NOT NULL,
  `likes_count` INT DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `friends`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `friends`;
CREATE TABLE `friends` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(100) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `avatar_url` TEXT NULL,
  `subtitle` VARCHAR(255) NULL,
  `is_following` TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `notifications`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL DEFAULT 1,
  `type` VARCHAR(50) NOT NULL,
  `title` VARCHAR(150) NOT NULL,
  `message` TEXT NOT NULL,
  `avatar_url` TEXT NULL,
  `is_read` TINYINT(1) DEFAULT 0,
  `timestamp_label` VARCHAR(50) NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for `post_interactions`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `post_interactions`;
CREATE TABLE `post_interactions` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `post_id` BIGINT UNSIGNED NOT NULL,
  `type` ENUM('like', 'bookmark', 'repost') NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `user_post_type` (`user_id`, `post_id`, `type`),
  INDEX (`user_id`),
  INDEX (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- SEED DATA (DATA AWAL LENGKAP PERSIS SEPERTI DI APLIKASI)
-- ========================================================

-- 1. Default Users
INSERT INTO `users` (`id`, `username`, `name`, `email`, `password`, `avatar_url`, `bio`, `following_count`, `followers_count`, `likes_count`, `created_at`) VALUES
(1, 'andrianpei', 'Andrian', 'andriandowehz123@gmail.com', 'password123', 'assets/images/img_8668.jpg', 'Ya Sudahilah aku yaaa ah jangan ya ini mah !', 0, 0, 0, NOW()),
(2, 'aurelie.hermansyah', 'Aurelie Hermansyah', 'aurel@socialhub.com', 'password123', 'assets/images/img_8664.jpg', 'Content Creator & Musician ✨', 234, 844000, 3200000, NOW()),
(3, 'ei.kaa', 'ei.kaa🍭', 'eika@socialhub.com', 'password123', 'assets/images/img_8665.jpg', 'Life is sweet like candy 🍭', 120, 95000, 480000, NOW());

-- 2. Default Feed Posts
INSERT INTO `posts` (`id`, `user_id`, `author_name`, `author_username`, `author_avatar`, `video_url`, `caption`, `music_title`, `likes_count`, `comments_count`, `shares_count`, `bookmarks_count`, `is_liked`, `is_bookmarked`, `is_reposted`, `is_private`, `view_count`, `thumbnail_path`, `created_at`) VALUES
(1, 1, 'Andrian', 'andrianpei', 'assets/images/img_8668.jpg', 'assets/videos/andrian_feed.mp4', 'Wisuda Sarjana Teknik Informatika S1 🎓 IPK 3.73 Wisudawan Terbaik! Terima kasih untuk semua dukungannya ✨ #wisuda #unpam #informatika #fyp', '♫ Berisi: Sound Wisuda Bangga (Original) - andrianpei', 844300, 3322, 12300, 17100, 0, 0, 0, 0, 182000, 'assets/images/andrian_feed_poster.jpg', NOW());

-- 3. Comments for Post 1
INSERT INTO `comments` (`id`, `post_id`, `user_id`, `username`, `user_avatar`, `text`, `likes_count`, `created_at`) VALUES
(1, 1, 3, 'ei.kaa', 'assets/images/img_8665.jpg', 'Keren banget videonya kak! Selamat atas wisudanya 🔥🎓', 142, NOW()),
(2, 1, 2, 'aurelie.hermansyah', 'assets/images/img_8664.jpg', 'MasyaAllah tabarakallah, bangga banget liatnya! Sukses selalu kak! 😍', 89, NOW()),
(3, 1, 1, 'rizky_gaming', 'assets/images/img_8666.jpg', 'Informatika keras bro, salut bisa dapet 3.73 mantapp 🚀', 45, NOW()),
(4, 1, 1, 'kalisa_putri', 'assets/images/img_8664.jpg', 'Congrats yaaa! Semoga ilmunya berkah dan langsung keterima kerja impian ✨🎉', 215, NOW());

-- 4. Friends List (Teman / Komunitas)
INSERT INTO `friends` (`id`, `username`, `name`, `avatar_url`, `subtitle`, `is_following`) VALUES
(1, 'ei.kaa', 'ei.kaa🍭', 'assets/images/img_8665.jpg', 'Membagikan video kepada Anda', 0),
(2, 's_anime', 's', 'assets/images/img_8667.jpg', 'Orang yang mungkin Anda kenal', 0),
(3, 'angsuran17', 'Angsuran17', 'assets/images/img_8666.jpg', 'Membagikan video kepada Anda', 0),
(4, 'annisasabila13', 'annisasabila13', 'assets/images/img_8664.jpg', 'Orang yang mungkin Anda kenal', 0),
(5, 'gasss', 'gasss', 'assets/images/img_8668.jpg', 'Orang yang mungkin Anda kenal', 0);

-- 5. Notifications List
INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `message`, `avatar_url`, `is_read`, `timestamp_label`, `created_at`) VALUES
(1, 1, 'activity', 'Aktivitas dan pengikut baru', 'MPL Indonesia mengundangmu unt...', 'assets/images/img_8667.jpg', 1, '1 j', NOW()),
(2, 1, 'system', 'Notifikasi sistem', 'Asisten transaksi: Saldo akan...', 'assets/images/img_8667.jpg', 0, '21 j', NOW()),
(3, 1, 'bot', 'TikTok Tako', 'Mulainya dari mana?', 'assets/images/img_8667.jpg', 1, '2 h', NOW()),
(4, 1, 'shop', 'Pesan toko', '5 pembaruan toko dan 14...', 'assets/images/img_8667.jpg', 0, '25 Okt', NOW()),
(5, 1, 'direct_message', 'andrianpei', 'Terkirim', 'assets/images/img_8667.jpg', 1, 'Kemarin', NOW());

SET FOREIGN_KEY_CHECKS = 1;
