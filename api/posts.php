<?php
require_once __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

if ($method === 'GET') {
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    $type = $_GET['type'] ?? 'feed'; // feed, user, liked, saved, reposted, private
    $limit = isset($_GET['limit']) ? min((int)$_GET['limit'], 100) : 50;

    try {
        if ($type === 'user' && $userId !== null) {
            $stmt = $db->prepare("SELECT * FROM posts WHERE user_id = :uid AND is_private = 0 ORDER BY id DESC LIMIT :limit");
            $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
        } elseif ($type === 'private' && $userId !== null) {
            $stmt = $db->prepare("SELECT * FROM posts WHERE user_id = :uid AND is_private = 1 ORDER BY id DESC LIMIT :limit");
            $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
        } elseif ($type === 'liked') {
            $stmt = $db->prepare("SELECT * FROM posts WHERE is_liked = 1 ORDER BY id DESC LIMIT :limit");
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
        } elseif ($type === 'saved' || $type === 'bookmarked') {
            $stmt = $db->prepare("SELECT * FROM posts WHERE is_bookmarked = 1 ORDER BY id DESC LIMIT :limit");
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
        } elseif ($type === 'reposted') {
            $stmt = $db->prepare("SELECT * FROM posts WHERE is_reposted = 1 ORDER BY id DESC LIMIT :limit");
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
        } else {
            // Default: All public feed posts
            $stmt = $db->prepare("SELECT * FROM posts WHERE is_private = 0 ORDER BY id DESC LIMIT :limit");
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
        }

        $posts = $stmt->fetchAll();

        // Cast boolean and integer fields properly for Flutter JSON decoding
        $formatted = array_map(function($p) {
            return [
                'id' => (int)$p['id'],
                'user_id' => (int)$p['user_id'],
                'author_name' => (string)$p['author_name'],
                'author_username' => (string)$p['author_username'],
                'author_avatar' => (string)$p['author_avatar'],
                'video_url' => (string)$p['video_url'],
                'caption' => (string)($p['caption'] ?? ''),
                'music_title' => (string)($p['music_title'] ?? '♫ Sound Asli - andrianpei'),
                'likes_count' => (int)$p['likes_count'],
                'comments_count' => (int)$p['comments_count'],
                'shares_count' => (int)$p['shares_count'],
                'bookmarks_count' => (int)$p['bookmarks_count'],
                'is_liked' => (bool)$p['is_liked'],
                'is_bookmarked' => (bool)$p['is_bookmarked'],
                'is_reposted' => (bool)$p['is_reposted'],
                'is_private' => (bool)$p['is_private'],
                'view_count' => (int)$p['view_count'],
                'thumbnail_path' => (string)($p['thumbnail_path'] ?? ''),
                'created_at' => (string)$p['created_at'],
            ];
        }, $posts);

        jsonResponse([
            'success' => true,
            'count' => count($formatted),
            'data' => $formatted
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }

} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

    if (empty($input['video_url'])) {
        jsonResponse(['success' => false, 'error' => 'video_url is required'], 400);
    }

    $userId = isset($input['user_id']) ? (int)$input['user_id'] : 1;
    $authorName = $input['author_name'] ?? 'Andrian';
    $authorUsername = $input['author_username'] ?? 'andrianpei';
    $authorAvatar = $input['author_avatar'] ?? 'assets/images/img_8668.jpg';
    $videoUrl = $input['video_url'];
    $caption = $input['caption'] ?? '';
    $musicTitle = $input['music_title'] ?? '♫ Sound Asli - andrianpei';
    $thumbnailPath = $input['thumbnail_path'] ?? 'assets/images/img_8668.jpg';
    $isPrivate = !empty($input['is_private']) ? 1 : 0;

    // AI Viral Engagement Generator if counts are 0 or omitted
    $likes = !empty($input['likes_count']) ? (int)$input['likes_count'] : rand(14500, 92700);
    $comments = !empty($input['comments_count']) ? (int)$input['comments_count'] : rand(280, 1950);
    $shares = !empty($input['shares_count']) ? (int)$input['shares_count'] : rand(1200, 10500);
    $bookmarks = !empty($input['bookmarks_count']) ? (int)$input['bookmarks_count'] : rand(650, 6200);
    $views = !empty($input['view_count']) ? (int)$input['view_count'] : rand(45000, 385000);
    $isLiked = !empty($input['is_liked']) ? 1 : 1; // Default liked for the creator

    try {
        $stmt = $db->prepare("INSERT INTO posts 
            (user_id, author_name, author_username, author_avatar, video_url, caption, music_title, 
             likes_count, comments_count, shares_count, bookmarks_count, is_liked, is_bookmarked, is_reposted, is_private, 
             view_count, thumbnail_path, created_at)
            VALUES 
            (:user_id, :author_name, :author_username, :author_avatar, :video_url, :caption, :music_title,
             :likes, :comments, :shares, :bookmarks, :is_liked, 0, 0, :is_private,
             :views, :thumbnail_path, NOW())");

        $stmt->execute([
            ':user_id' => $userId,
            ':author_name' => $authorName,
            ':author_username' => $authorUsername,
            ':author_avatar' => $authorAvatar,
            ':video_url' => $videoUrl,
            ':caption' => $caption,
            ':music_title' => $musicTitle,
            ':likes' => $likes,
            ':comments' => $comments,
            ':shares' => $shares,
            ':bookmarks' => $bookmarks,
            ':is_liked' => $isLiked,
            ':is_private' => $isPrivate,
            ':views' => $views,
            ':thumbnail_path' => $thumbnailPath,
        ]);

        $newId = (int)$db->lastInsertId();

        // Seed 2 realistic AI comments for the new video
        $commentStmt = $db->prepare("INSERT INTO comments (post_id, user_id, username, user_avatar, text, likes_count, created_at) VALUES 
            (:pid, 3, 'ei.kaa', 'assets/images/img_8665.jpg', 'Keren bangett videonya kak! FYP nih pasti 🔥✨', 18, NOW()),
            (:pid, 2, 'aurelie.hermansyah', 'assets/images/img_8664.jpg', 'Suka banget sama kontennya! Sukses selalu yaa 😍', 27, NOW())");
        $commentStmt->execute([':pid' => $newId]);

        jsonResponse([
            'success' => true,
            'message' => 'Post created successfully',
            'data' => [
                'id' => $newId,
                'user_id' => $userId,
                'author_name' => $authorName,
                'author_username' => $authorUsername,
                'author_avatar' => $authorAvatar,
                'video_url' => $videoUrl,
                'caption' => $caption,
                'music_title' => $musicTitle,
                'likes_count' => $likes,
                'comments_count' => $comments,
                'shares_count' => $shares,
                'bookmarks_count' => $bookmarks,
                'is_liked' => (bool)$isLiked,
                'is_bookmarked' => false,
                'is_reposted' => false,
                'is_private' => (bool)$isPrivate,
                'view_count' => $views,
                'thumbnail_path' => $thumbnailPath,
                'created_at' => date('Y-m-d H:i:s'),
            ]
        ], 201);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }

} elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = isset($_GET['id']) ? (int)$_GET['id'] : (isset($input['id']) ? (int)$input['id'] : null);

    if (!$id) {
        jsonResponse(['success' => false, 'error' => 'post id is required'], 400);
    }

    try {
        $stmt = $db->prepare("DELETE FROM posts WHERE id = :id");
        $stmt->execute([':id' => $id]);

        $db->prepare("DELETE FROM comments WHERE post_id = :id")->execute([':id' => $id]);
        $db->prepare("DELETE FROM post_interactions WHERE post_id = :id")->execute([':id' => $id]);

        jsonResponse([
            'success' => true,
            'message' => "Post $id deleted successfully"
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }
} else {
    jsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}
