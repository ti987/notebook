<?php
// Store PHP sessions inside the project so the runtime never touches
// /var/lib/php/sessions, which is typically unwritable for the user
// running `php -S`. Include this BEFORE every session_start() call.
$dir = __DIR__ . '/tmp/sessions';
if (!is_dir($dir)) {
    @mkdir($dir, 0700, true);
}
ini_set('session.save_path', $dir);
