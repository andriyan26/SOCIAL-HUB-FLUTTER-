<?php
require_once __DIR__ . '/db.php';

// Set memory limit and execution time for video uploads
@ini_set('memory_limit', '512M');
@ini_set('max_execution_time', '300');
@ini_set('upload_max_filesize', '256M');
@ini_set('post_max_size', '256M');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}

$baseUrl = getBaseUrl();

// 1. Check for Multipart file upload
if (!empty($_FILES['file'])) {
    $file = $_FILES['file'];

    if ($file['error'] !== UPLOAD_ERR_OK) {
        jsonResponse([
            'success' => false,
            'error' => 'Upload error code: ' . $file['error']
        ], 400);
    }

    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (empty($ext)) {
        $mime = $file['type'] ?? '';
        if (strpos($mime, 'video/') !== false) $ext = 'mp4';
        else if (strpos($mime, 'image/png') !== false) $ext = 'png';
        else $ext = 'jpg';
    }

    $isVideo = in_array($ext, ['mp4', 'mov', 'webm', 'avi', 'mkv', '3gp', 'm4v']);
    $targetDir = $isVideo ? VIDEOS_DIR : IMAGES_DIR;
    $folderName = $isVideo ? 'videos' : 'images';

    $uniqueName = ($isVideo ? 'vid_' : 'img_') . date('Ymd_His') . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
    $targetPath = $targetDir . DIRECTORY_SEPARATOR . $uniqueName;

    if (move_uploaded_file($file['tmp_name'], $targetPath)) {
        // Return both relative and full URL
        $relativeUrl = "uploads/$folderName/$uniqueName";
        $fullUrl = "$baseUrl/$relativeUrl";

        jsonResponse([
            'success' => true,
            'message' => 'File uploaded successfully',
            'is_video' => $isVideo,
            'filename' => $uniqueName,
            'relative_url' => $relativeUrl,
            'url' => $fullUrl
        ], 200);
    } else {
        jsonResponse(['success' => false, 'error' => 'Failed to save uploaded file'], 500);
    }
}

// 2. Check for base64 JSON upload
$rawInput = file_get_contents('php://input');
$json = json_decode($rawInput, true);

if (!empty($json['data'])) {
    $dataUri = $json['data'];
    $isVideo = !empty($json['is_video']);
    $folderName = $isVideo ? 'videos' : 'images';
    $targetDir = $isVideo ? VIDEOS_DIR : IMAGES_DIR;

    if (preg_match('/^data:(.*?);base64,(.*)$/', $dataUri, $matches)) {
        $mime = $matches[1];
        $base64 = $matches[2];
        $ext = 'jpg';
        if (strpos($mime, 'png') !== false) $ext = 'png';
        elseif (strpos($mime, 'video/mp4') !== false) $ext = 'mp4';
        elseif (strpos($mime, 'video/quicktime') !== false) $ext = 'mov';

        $binary = base64_decode($base64);
        if ($binary !== false) {
            $uniqueName = ($isVideo ? 'vid_' : 'img_') . date('Ymd_His') . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
            $targetPath = $targetDir . DIRECTORY_SEPARATOR . $uniqueName;

            if (file_put_contents($targetPath, $binary) !== false) {
                $relativeUrl = "uploads/$folderName/$uniqueName";
                $fullUrl = "$baseUrl/$relativeUrl";
                jsonResponse([
                    'success' => true,
                    'message' => 'Base64 file uploaded successfully',
                    'is_video' => $isVideo,
                    'filename' => $uniqueName,
                    'relative_url' => $relativeUrl,
                    'url' => $fullUrl
                ]);
            }
        }
    }
}

jsonResponse(['success' => false, 'error' => 'No file received'], 400);

