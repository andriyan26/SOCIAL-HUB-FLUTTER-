<?php
require_once __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

if ($method === 'GET') {
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 1;
    $username = $_GET['username'] ?? null;

    try {
        if ($username) {
            $stmt = $db->prepare("SELECT id, username, name, email, avatar_url, bio, following_count, followers_count, likes_count, created_at FROM users WHERE LOWER(username) = LOWER(:u)");
            $stmt->execute([':u' => $username]);
        } else {
            $stmt = $db->prepare("SELECT id, username, name, email, avatar_url, bio, following_count, followers_count, likes_count, created_at FROM users WHERE id = :id");
            $stmt->execute([':id' => $userId]);
        }

        $user = $stmt->fetch();
        if (!$user) {
            jsonResponse(['success' => false, 'error' => 'User not found'], 404);
        }

        jsonResponse([
            'success' => true,
            'data' => [
                'id' => (int)$user['id'],
                'username' => (string)$user['username'],
                'name' => (string)$user['name'],
                'email' => (string)$user['email'],
                'avatar_url' => (string)($user['avatar_url'] ?? ''),
                'bio' => (string)($user['bio'] ?? ''),
                'following_count' => (int)$user['following_count'],
                'followers_count' => (int)$user['followers_count'],
                'likes_count' => (int)$user['likes_count'],
                'created_at' => (string)$user['created_at'],
            ]
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }

} elseif ($method === 'POST' || $method === 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

    $userId = isset($input['id']) ? (int)$input['id'] : (isset($input['user_id']) ? (int)$input['user_id'] : 1);
    $name = $input['name'] ?? null;
    $username = $input['username'] ?? null;
    $bio = $input['bio'] ?? null;
    $avatarUrl = $input['avatar_url'] ?? null;

    try {
        $fields = [];
        $params = [':id' => $userId];

        if ($name !== null) {
            $fields[] = "name = :name";
            $params[':name'] = $name;
        }
        if ($username !== null) {
            $cleanUser = ltrim(trim($username), '@');
            $fields[] = "username = :username";
            $params[':username'] = $cleanUser;
        }
        if ($bio !== null) {
            $fields[] = "bio = :bio";
            $params[':bio'] = $bio;
        }
        if ($avatarUrl !== null && !empty($avatarUrl)) {
            $fields[] = "avatar_url = :avatar";
            $params[':avatar'] = $avatarUrl;
        }

        if (!empty($fields)) {
            $sql = "UPDATE users SET " . implode(', ', $fields) . ", updated_at = NOW() WHERE id = :id";
            $stmt = $db->prepare($sql);
            $stmt->execute($params);

            // Also propagate author updates to posts table so Beranda immediately reflects it!
            $postFields = [];
            $postParams = [':uid' => $userId];
            if ($name !== null) {
                $postFields[] = "author_name = :pname";
                $postParams[':pname'] = $name;
            }
            if ($username !== null) {
                $cleanUser = ltrim(trim($username), '@');
                $postFields[] = "author_username = :puser";
                $postParams[':puser'] = $cleanUser;
            }
            if ($avatarUrl !== null && !empty($avatarUrl)) {
                $postFields[] = "author_avatar = :pavatar";
                $postParams[':pavatar'] = $avatarUrl;
            }

            if (!empty($postFields)) {
                $postSql = "UPDATE posts SET " . implode(', ', $postFields) . " WHERE user_id = :uid";
                $db->prepare($postSql)->execute($postParams);
            }
        }

        // Return refreshed user profile
        $fetchStmt = $db->prepare("SELECT id, username, name, email, avatar_url, bio, following_count, followers_count, likes_count, created_at FROM users WHERE id = :id");
        $fetchStmt->execute([':id' => $userId]);
        $updatedUser = $fetchStmt->fetch();

        jsonResponse([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $updatedUser
        ]);
    } catch (\Exception $e) {
        jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
    }
} else {
    jsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}
