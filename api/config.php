<?php
// ========================================================
// Hostinger Database Configuration
// ========================================================

define('DB_HOST', 'localhost');
define('DB_NAME', 'u975115372_SocialHub12345');
define('DB_USER', 'u975115372_SocialHub12345');
define('DB_PASS', 'SocialHub12345');
define('DB_CHARSET', 'utf8mb4');

// Directory paths
define('ROOT_DIR', dirname(__DIR__));
define('UPLOADS_DIR', ROOT_DIR . DIRECTORY_SEPARATOR . 'uploads');
define('VIDEOS_DIR', UPLOADS_DIR . DIRECTORY_SEPARATOR . 'videos');
define('IMAGES_DIR', UPLOADS_DIR . DIRECTORY_SEPARATOR . 'images');

// Auto create upload directories if they don't exist
if (!file_exists(UPLOADS_DIR)) {
    @mkdir(UPLOADS_DIR, 0755, true);
}
if (!file_exists(VIDEOS_DIR)) {
    @mkdir(VIDEOS_DIR, 0755, true);
}
if (!file_exists(IMAGES_DIR)) {
    @mkdir(IMAGES_DIR, 0755, true);
}

