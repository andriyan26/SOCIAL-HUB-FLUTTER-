<?php
require_once __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    $action = $input['action'] ?? 'login';

    if ($action === 'login') {
        $identifier = trim($input['identifier'] ?? ($input['username'] ?? ($input['email'] ?? '')));
        $password = trim($input['password'] ?? '');

        if (empty($identifier) || empty($password)) {
            jsonResponse(['success' => false, 'error' => 'Username/email dan password wajib diisi'], 400);
        }

        try {
            $stmt = $db->prepare("SELECT * FROM users WHERE LOWER(username) = LOWER(:id1) OR LOWER(email) = LOWER(:id2) LIMIT 1");
            $stmt->execute([':id1' => $identifier, ':id2' => $identifier]);
            $user = $stmt->fetch();

            if ($user && ($user['password'] === $password || password_verify($password, $user['password']))) {
                unset($user['password']); // don't return password
                jsonResponse([
                    'success' => true,
                    'message' => 'Login berhasil',
                    'data' => $user
                ]);
            } else {
                jsonResponse(['success' => false, 'error' => 'Username/email atau password salah'], 401);
            }
        } catch (\Exception $e) {
            jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
        }

    } elseif ($action === 'register') {
        $username = trim($input['username'] ?? '');
        $name = trim($input['name'] ?? '');
        $email = trim($input['email'] ?? '');
        $password = trim($input['password'] ?? '');
        $avatarUrl = $input['avatar_url'] ?? 'assets/images/img_8668.jpg';
        $bio = $input['bio'] ?? 'Halo, saya baru di Social Hub! ✨';

        if (empty($username) || empty($email) || empty($password)) {
            jsonResponse(['success' => false, 'error' => 'Lengkapi data pendaftaran'], 400);
        }

        try {
            $check = $db->prepare("SELECT id FROM users WHERE LOWER(username) = LOWER(:u) OR LOWER(email) = LOWER(:e)");
            $check->execute([':u' => $username, ':e' => $email]);
            if ($check->fetch()) {
                jsonResponse(['success' => false, 'error' => 'Username atau email sudah digunakan'], 409);
            }

            $stmt = $db->prepare("INSERT INTO users (username, name, email, password, avatar_url, bio, created_at) 
                VALUES (:u, :n, :e, :p, :a, :b, NOW())");
            $stmt->execute([
                ':u' => $username,
                ':n' => $name ?: $username,
                ':e' => $email,
                ':p' => $password,
                ':a' => $avatarUrl,
                ':b' => $bio
            ]);

            $newId = (int)$db->lastInsertId();
            jsonResponse([
                'success' => true,
                'message' => 'Pendaftaran berhasil',
                'data' => [
                    'id' => $newId,
                    'username' => $username,
                    'name' => $name ?: $username,
                    'email' => $email,
                    'avatar_url' => $avatarUrl,
                    'bio' => $bio,
                    'following_count' => 0,
                    'followers_count' => 0,
                    'likes_count' => 0,
                ]
            ], 201);
        } catch (\Exception $e) {
            jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
        }
    } else {
        jsonResponse(['success' => false, 'error' => 'Unknown action'], 400);
    }
} else {
    jsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}
