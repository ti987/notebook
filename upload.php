<?php
// Initialize the session
require_once __DIR__ . '/session_init.php';
session_start();

// Check if the user is logged in, if not then redirect him to login page
if (!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] !== true) {
    header("location: auth/login.php");
    exit;
}

// Generate CSRF token if not set
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// Security headers
header("X-Frame-Options: DENY");
header("X-Content-Type-Options: nosniff");
header("Strict-Transport-Security: max-age=31536000; includeSubDomains");
header("Referrer-Policy: same-origin");

// Allowed extensions and their expected MIME types
$allowed = [
    'jpeg' => 'image/jpeg',
    'jpg'  => 'image/jpeg',
    'png'  => 'image/png',
    'svg'  => 'image/svg+xml',
    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls'  => 'application/vnd.ms-excel',
    'xlsm' => 'application/vnd.ms-excel.sheet.macroenabled.12',
    'tbz'  => 'application/x-bzip2',
    'tgz'  => 'application/gzip',
];

// Max file size: 10 MB
$max_size = 10 * 1024 * 1024;

$error   = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Validate CSRF token
    if (empty($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die("Invalid request.");
    }

    if (isset($_FILES['image']) && $_FILES['image']['error'] !== UPLOAD_ERR_NO_FILE) {

        $upload_error = $_FILES['image']['error'];
        if ($upload_error !== UPLOAD_ERR_OK) {
            $error = "Upload error (code $upload_error).";
        } else {
            $file_tmp  = $_FILES['image']['tmp_name'];
            $file_size = $_FILES['image']['size'];

            // Sanitise filename: strip path components, replace anything
            // that isn't alphanumeric, dash, underscore, or dot with '_'
            $raw_name  = basename($_FILES['image']['name']);
            $safe_name = preg_replace('/[^a-zA-Z0-9._-]/', '_', $raw_name);
            // Prevent hidden files and double-extension tricks like .php.jpg
            $safe_name = ltrim($safe_name, '.');

            // Extract extension from the sanitised name
            $ext = strtolower(pathinfo($safe_name, PATHINFO_EXTENSION));

            if (!array_key_exists($ext, $allowed)) {
                $error = "Extension not allowed. Permitted types: " . implode(', ', array_keys($allowed));
            } elseif ($file_size > $max_size) {
                $error = "File too large. Maximum size is 10 MB.";
            } else {
                // Verify MIME type via file content (not client-supplied type)
                $finfo     = new finfo(FILEINFO_MIME_TYPE);
                $real_mime = $finfo->file($file_tmp);

                // SVG and office formats are not well-detected by libmagic;
                // fall back to allowing their known MIME aliases
                $mime_ok = ($real_mime === $allowed[$ext])
                    || ($ext === 'svg'  && in_array($real_mime, ['text/html', 'text/xml', 'image/svg+xml', 'application/xml']))
                    || ($ext === 'docx' && $real_mime === 'application/zip')
                    || ($ext === 'xlsm' && $real_mime === 'application/zip')
                    || ($ext === 'xls'  && in_array($real_mime, ['application/vnd.ms-excel', 'application/zip', 'application/octet-stream']))
                    || (in_array($ext, ['tbz', 'tgz']) && in_array($real_mime, ['application/gzip', 'application/x-gzip', 'application/x-bzip2', 'application/octet-stream']));

                if (!$mime_ok) {
                    $error = "File content does not match the declared extension.";
                } else {
                    $dest = __DIR__ . '/images/' . $safe_name;
                    if (move_uploaded_file($file_tmp, $dest)) {
                        $success = "File uploaded successfully as: " . htmlspecialchars($safe_name);
                    } else {
                        $error = "Failed to save uploaded file.";
                    }
                }
            }
        }
    }
}
?>
<html>
   <head>
      <meta charset="utf-8">
      <?php if ($success): ?>
      <meta http-equiv="refresh" content="7;url=index.php" />
      <?php endif; ?>
   </head>
   <body>
      <?php if ($error): ?>
         <p style="color:red;"><?php echo htmlspecialchars($error); ?></p>
      <?php elseif ($success): ?>
         <p style="color:green;"><?php echo $success; ?></p>
      <?php endif; ?>

      <form action="" method="POST" enctype="multipart/form-data">
         <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
         <input type="file" name="image" />
         <input type="submit" value="Upload" />
      </form>

     <a href="./index.php" class="menu_button"><button> Home </button></a>

   </body>
</html>
