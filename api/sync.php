<?php
require_once __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

if ($method === 'GET') {
    try {
        // Fetch primary user
        $userStmt = $db->query("SELECT id, username, name, email, avatar_url, bio, following_count, followers_count, likes_count, created_at FROM users WHERE id = 1");
        $user = $userStmt->fetch();

        // Fetch posts
        $postsStmt = $db->query("SELECT * FROM posts ORDER BY id DESC LIMIT 50");
        $posts = $postsStmt->fetchAll();

        $formattedPosts = array_map(function($p) {
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
                'is_liked' => (int)$p['is_liked'],
                'is_bookmarked' => (int)$p['is_bookmarked'],
                'is_reposted' => (int)$p['is_reposted'],
                'is_private' => (int)$p['is_private'],
                'view_count' => (int)$p['view_count'],
                'thumbnail_path' => (string)($p['thumbnail_path'] ?? ''),
                'created_at' => (string)$p['created_at'],
            ];
        }, $posts);

        jsonResponse([
            'success' => true,
            'data' => [
                'name' => $user['name'] ?? 'Andrian',
                'username' => $user['username'] ?? 'andrianpei',
                'bio' => $user['bio'] ?? 'Ya Sudahilah aku yaaa ah jangan ya ini mah !',
                'avatar_url' => $user['avatar_url'] ?? 'assets/images/img_8668.jpg',
                'updated_at' => date('Y-m-d H:i:s'),
                'posts' => $formattedPosts,
            ]
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }

} elseif ($method === 'PUT' || $method === 'POST') {
    $rawInput = file_get_contents('php://input');
    $payload = json_decode($rawInput, true);

    $data = $payload['data'] ?? $payload;

    try {
        // 1. Sync User Profile
        if (!empty($data['name']) || !empty($data['username']) || !empty($data['bio']) || !empty($data['avatar_url'])) {
            $userFields = [];
            $userParams = [':id' => 1];

            if (!empty($data['name'])) {
                $userFields[] = "name = :name";
                $userParams[':name'] = $data['name'];
            }
            if (!empty($data['username'])) {
                $cleanUser = ltrim(trim($data['username']), '@');
                $userFields[] = "username = :user";
                $userParams[':user'] = $cleanUser;
            }
            if (isset($data['bio'])) {
                $userFields[] = "bio = :bio";
                $userParams[':bio'] = $data['bio'];
            }
            if (!empty($data['avatar_url']) && !str_starts_with($data['avatar_url'], 'blob:') && $data['avatar_url'] !== 'custom_avatar') {
                $userFields[] = "avatar_url = :avatar";
                $userParams[':avatar'] = $data['avatar_url'];
            }

            if (!empty($userFields)) {
                $sql = "UPDATE users SET " . implode(', ', $userFields) . ", updated_at = NOW() WHERE id = :id";
                $db->prepare($sql)->execute($userParams);
            }
        }

        // 2. Sync Posts without destructive duplicate key overwrite
        if (!empty($data['posts']) && is_array($data['posts'])) {
            foreach ($data['posts'] as $p) {
                if (empty($p['video_url'])) continue;

                $videoUrl = $p['video_url'];
                $caption = $p['caption'] ?? '';
                $userId = (int)($p['user_id'] ?? 1);

                // Check if this post already exists by video_url or by small id
                $existingPost = null;
                if (!empty($p['id']) && (int)$p['id'] < 1000000) {
                    $chk = $db->prepare("SELECT id FROM posts WHERE id = :id LIMIT 1");
                    $chk->execute([':id' => (int)$p['id']]);
                    $existingPost = $chk->fetch();
                }

                if (!$existingPost) {
                    $chk2 = $db->prepare("SELECT id FROM posts WHERE user_id = :uid AND video_url = :vurl LIMIT 1");
                    $chk2->execute([':uid' => $userId, ':vurl' => $videoUrl]);
                    $existingPost = $chk2->fetch();
                }

                if ($existingPost) {
                    // Update existing post
                    $upd = $db->prepare("UPDATE posts SET 
                        author_name = :aname,
                        author_username = :auser,
                        author_avatar = :aavatar,
                        caption = :caption,
                        music_title = :mtitle,
                        likes_count = :likes,
                        comments_count = :comments,
                        shares_count = :shares,
                        bookmarks_count = :bookmarks,
                        is_liked = :is_liked,
                        is_bookmarked = :is_bookmarked,
                        is_reposted = :is_reposted,
                        is_private = :is_private,
                        view_count = :views,
                        thumbnail_path = :thumbnail
                        WHERE id = :id");

                    $upd->execute([
                        ':id' => $existingPost['id'],
                        ':aname' => $p['author_name'] ?? 'Andrian',
                        ':auser' => $p['author_username'] ?? 'andrianpei',
                        ':aavatar' => $p['author_avatar'] ?? 'assets/images/img_8668.jpg',
                        ':caption' => $caption,
                        ':mtitle' => $p['music_title'] ?? '♫ Sound Asli - andrianpei',
                        ':likes' => (int)($p['likes_count'] ?? 0),
                        ':comments' => (int)($p['comments_count'] ?? 0),
                        ':shares' => (int)($p['shares_count'] ?? 0),
                        ':bookmarks' => (int)($p['bookmarks_count'] ?? 0),
                        ':is_liked' => !empty($p['is_liked']) ? 1 : 0,
                        ':is_bookmarked' => !empty($p['is_bookmarked']) ? 1 : 0,
                        ':is_reposted' => !empty($p['is_reposted']) ? 1 : 0,
                        ':is_private' => !empty($p['is_private']) ? 1 : 0,
                        ':views' => (int)($p['view_count'] ?? 0),
                        ':thumbnail' => $p['thumbnail_path'] ?? 'assets/images/img_8668.jpg',
                    ]);
                } else {
                    // Insert brand new post with MySQL AUTO_INCREMENT ID!
                    $ins = $db->prepare("INSERT INTO posts 
                        (user_id, author_name, author_username, author_avatar, video_url, caption, music_title,
                         likes_count, comments_count, shares_count, bookmarks_count, is_liked, is_bookmarked, is_reposted, is_private,
                         view_count, thumbnail_path, created_at)
                        VALUES
                        (:uid, :aname, :auser, :aavatar, :vurl, :caption, :mtitle,
                         :likes, :comments, :shares, :bookmarks, :is_liked, :is_bookmarked, :is_reposted, :is_private,
                         :views, :thumbnail, NOW())");

                    $ins->execute([
                        ':uid' => $userId,
                        ':aname' => $p['author_name'] ?? 'Andrian',
                        ':auser' => $p['author_username'] ?? 'andrianpei',
                        ':aavatar' => $p['author_avatar'] ?? 'assets/images/img_8668.jpg',
                        ':vurl' => $videoUrl,
                        ':caption' => $caption,
                        ':mtitle' => $p['music_title'] ?? '♫ Sound Asli - andrianpei',
                        ':likes' => (int)($p['likes_count'] ?? 0),
                        ':comments' => (int)($p['comments_count'] ?? 0),
                        ':shares' => (int)($p['shares_count'] ?? 0),
                        ':bookmarks' => (int)($p['bookmarks_count'] ?? 0),
                        ':is_liked' => !empty($p['is_liked']) ? 1 : 0,
                        ':is_bookmarked' => !empty($p['is_bookmarked']) ? 1 : 0,
                        ':is_reposted' => !empty($p['is_reposted']) ? 1 : 0,
                        ':is_private' => !empty($p['is_private']) ? 1 : 0,
                        ':views' => (int)($p['view_count'] ?? 0),
                        ':thumbnail' => $p['thumbnail_path'] ?? 'assets/images/img_8668.jpg',
                    ]);
                }
            }
        }

        jsonResponse([
            'success' => true,
            'message' => 'Synced to Hostinger MySQL successfully'
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }
} else {
    jsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}
