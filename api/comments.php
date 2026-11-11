<?php
require_once __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

if ($method === 'GET') {
    $postId = isset($_GET['post_id']) ? (int)$_GET['post_id'] : null;
    if (!$postId) {
        jsonResponse(['success' => false, 'error' => 'post_id is required'], 400);
    }

    try {
        $stmt = $db->prepare("SELECT * FROM comments WHERE post_id = :pid ORDER BY id ASC");
        $stmt->execute([':pid' => $postId]);
        $comments = $stmt->fetchAll();

        jsonResponse([
            'success' => true,
            'count' => count($comments),
            'data' => $comments
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }

} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

    $postId = isset($input['post_id']) ? (int)$input['post_id'] : null;
    $text = trim($input['text'] ?? '');
    $username = $input['username'] ?? 'andrianpei';
    $userAvatar = $input['user_avatar'] ?? 'assets/images/img_8668.jpg';
    $userId = isset($input['user_id']) ? (int)$input['user_id'] : 1;

    if (!$postId || empty($text)) {
        jsonResponse(['success' => false, 'error' => 'post_id and text are required'], 400);
    }

    try {
        $stmt = $db->prepare("INSERT INTO comments (post_id, user_id, username, user_avatar, text, likes_count, created_at) 
            VALUES (:pid, :uid, :username, :avatar, :text, 0, NOW())");
        $stmt->execute([
            ':pid' => $postId,
            ':uid' => $userId,
            ':username' => $username,
            ':avatar' => $userAvatar,
            ':text' => $text,
        ]);

        $commentId = (int)$db->lastInsertId();

        // Increment comments_count in posts table
        $db->prepare("UPDATE posts SET comments_count = comments_count + 1 WHERE id = :pid")->execute([':pid' => $postId]);

        jsonResponse([
            'success' => true,
            'message' => 'Comment added successfully',
            'data' => [
                'id' => $commentId,
                'post_id' => $postId,
                'user_id' => $userId,
                'username' => $username,
                'user_avatar' => $userAvatar,
                'text' => $text,
                'likes_count' => 0,
                'created_at' => date('Y-m-d H:i:s'),
            ]
        ], 201);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }
} else {
    jsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}
