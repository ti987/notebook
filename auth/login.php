<?php
// Initialize the session
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', 1);
ini_set('session.cookie_samesite', 'Strict');
session_start();

if ($_SERVER["HTTPS"] != "on") {
    header("Location: https://" . $_SERVER["HTTP_HOST"] . $_SERVER["REQUEST_URI"]);
    exit();
}

// Check if the user is already logged in, redirect to welcome page
if (isset($_SESSION["loggedin"]) && $_SESSION["loggedin"] === true) {
    header("location: ./index.php");
    exit;
}

// Include config file
require_once "config.php";

// Generate CSRF token if not set
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// Define variables and initialize with empty values
$username = $password = "";
$username_err = $password_err = $login_err = "";

// Processing form data when form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // Validate CSRF token
    if (empty($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die("Invalid request.");
    }

    // Check if username is empty
    if (empty(trim($_POST["username"]))) {
        $username_err = "Please enter username.";
    } else {
        $username = trim($_POST["username"]);
    }

    // Check if password is empty
    if (empty(trim($_POST["password"]))) {
        $password_err = "Please enter your password.";
    } else {
        $password = trim($_POST["password"]);
    }

    // Validate credentials
    if (empty($username_err) && empty($password_err)) {

        // Check for account lockout
        $stmt = $db->prepare("SELECT id, username, password, failed_attempts, lockout_until FROM users WHERE username = :username");
        $stmt->bindValue(':username', $username, SQLITE3_TEXT);
        $ret = $stmt->execute();
        $row = $ret->fetchArray(SQLITE3_ASSOC);

        if ($row) {
            // Check if account is locked out
            if ($row['lockout_until'] && strtotime($row['lockout_until']) > time()) {
                $login_err = "Too many failed attempts. Please try again later.";
            } elseif (password_verify($password, $row['password'])) {
                // Password is correct — reset failed attempts and start session
                $stmt2 = $db->prepare("UPDATE users SET failed_attempts = 0, lockout_until = NULL WHERE id = :id");
                $stmt2->bindValue(':id', $row['id'], SQLITE3_INTEGER);
                $stmt2->execute();

                session_regenerate_id(true);
                $_SESSION["loggedin"] = true;
                $_SESSION["id"] = $row['id'];
                $_SESSION["username"] = $row['username'];

                header("location: ../index.php");
                exit;
            } else {
                // Password is not valid — increment failed attempts
                $new_attempts = $row['failed_attempts'] + 1;
                if ($new_attempts >= 5) {
                    $lockout = date('Y-m-d H:i:s', time() + 15 * 60);
                    $stmt2 = $db->prepare("UPDATE users SET failed_attempts = :attempts, lockout_until = :lockout WHERE id = :id");
                    $stmt2->bindValue(':lockout', $lockout, SQLITE3_TEXT);
                } else {
                    $stmt2 = $db->prepare("UPDATE users SET failed_attempts = :attempts, lockout_until = NULL WHERE id = :id");
                }
                $stmt2->bindValue(':attempts', $new_attempts, SQLITE3_INTEGER);
                $stmt2->bindValue(':id', $row['id'], SQLITE3_INTEGER);
                $stmt2->execute();

                $login_err = "Invalid username or password.";
            }
        } else {
            // Username doesn't exist — use generic message
            $login_err = "Invalid username or password.";
        }
    }

    // Close connection
    $db->close();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <style>
        body{ font: 14px sans-serif; }
        .wrapper{ width: 360px; padding: 20px; }
    </style>
</head>
<body>
    <div class="wrapper">
        <h2>Login</h2>
        <p>Please fill in your credentials to login.</p>

        <?php
        if (!empty($login_err)) {
            echo '<div class="alert alert-danger" style="color:red;"> ' . htmlspecialchars($login_err) . '</div>';
        }
        ?>

        <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
            <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" class="form-control <?php echo (!empty($username_err)) ? 'is-invalid' : ''; ?>" value="<?php echo htmlspecialchars($username); ?>">
                <span class="invalid-feedback"><?php echo htmlspecialchars($username_err); ?></span>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" class="form-control <?php echo (!empty($password_err)) ? 'is-invalid' : ''; ?>">
                <span class="invalid-feedback"><?php echo htmlspecialchars($password_err); ?></span>
            </div>
            <div class="form-group">
                <input type="submit" class="btn btn-primary" value="Login">
            </div>
            <p>Don't have an account? <a href="register.php">Sign up now</a>.</p>
        </form>
    </div>
</body>
</html>
