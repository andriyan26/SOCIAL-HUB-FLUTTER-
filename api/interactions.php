<?php
require_once __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

    $postId = isset($input['post_id']) ? (int)$input['post_id'] : null;
    $userId = isset($input['user_id']) ? (int)$input['user_id'] : 1;
    $action = $input['action'] ?? 'like'; // like, bookmark, repost

    if (!$postId) {
        jsonResponse(['success' => false, 'error' => 'post_id is required'], 400);
    }

    try {
        // Check if user already interacted
        $checkStmt = $db->prepare("SELECT id FROM post_interactions WHERE user_id = :uid AND post_id = :pid AND type = :type");
        $checkStmt->execute([':uid' => $userId, ':pid' => $postId, ':type' => $action]);
        $exists = $checkStmt->fetch();

        $isActive = false;
        if ($exists) {
            // Remove interaction
            $delStmt = $db->prepare("DELETE FROM post_interactions WHERE id = :id");
            $delStmt->execute([':id' => $exists['id']]);
            $isActive = false;
        } else {
            // Add interaction
            $insStmt = $db->prepare("INSERT INTO post_interactions (user_id, post_id, type, created_at) VALUES (:uid, :pid, :type, NOW())");
            $insStmt->execute([':uid' => $userId, ':pid' => $postId, ':type' => $action]);
            $isActive = true;
        }

        // Update post table flags and counts
        $columnFlag = $action === 'like' ? 'is_liked' : ($action === 'bookmark' ? 'is_bookmarked' : 'is_reposted');
        $columnCount = $action === 'like' ? 'likes_count' : ($action === 'bookmark' ? 'bookmarks_count' : 'shares_count');

        $delta = $isActive ? 1 : -1;
        $db->prepare("UPDATE posts SET $columnFlag = :flag, $columnCount = GREATEST(0, $columnCount + :delta) WHERE id = :pid")
           ->execute([
               ':flag' => $isActive ? 1 : 0,
               ':delta' => $delta,
               ':pid' => $postId
           ]);

        // Fetch refreshed post
        $postStmt = $db->prepare("SELECT likes_count, bookmarks_count, shares_count, is_liked, is_bookmarked, is_reposted FROM posts WHERE id = :pid");
        $postStmt->execute([':pid' => $postId]);
        $post = $postStmt->fetch();

        jsonResponse([
            'success' => true,
            'action' => $action,
            'is_active' => $isActive,
            'post' => $post
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }
} else {
    jsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}

