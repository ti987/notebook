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

// Security headers (must be before any output)
header("X-Frame-Options: DENY");
header("X-Content-Type-Options: nosniff");
header("Strict-Transport-Security: max-age=31536000; includeSubDomains");
header("Referrer-Policy: same-origin");

include 'functions.php';

parse_str($_SERVER['QUERY_STRING'], $qs_arr);

if (isset($qs_arr['a_id']) && (int)$qs_arr['a_id'] > 0) {
    // initial entry via GET
    $a_id = (int)$qs_arr['a_id'];
} else {
    // edit update entry via POST
    $a_id = isset($_POST['a_id']) ? (int)$_POST['a_id'] : 0;
}

$search_keyword = null;
if (array_key_exists('search_keyword', $_POST)) {
    $search_keyword = $_POST['search_keyword'];
}
$search_title = null;
if (array_key_exists('search_title', $_POST)) {
    $search_title = $_POST['search_title'];
}
$update_title = null;
if (array_key_exists('update_title', $_POST)) {
    $update_title = $_POST['update_title'];
}
$update_status = null;
if (array_key_exists('update_status', $_POST)) {
    $update_status = (int)$_POST['update_status'];
}
$update_body = null;
if (array_key_exists('update_body', $_POST)) {
    $update_body = $_POST['update_body'];
}
$add_link = null;
if (array_key_exists('add_link', $_POST)) {
    $add_link = (int)$_POST['add_link'];
}
$delete_link = null;
if (array_key_exists('delete_link', $_POST)) {
    $delete_link = (int)$_POST['delete_link'];
}

// Validate CSRF for all state-mutating POST actions
$mutating = $update_title || !is_null($update_status) || $update_body || $add_link || $delete_link;
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $mutating) {
    if (empty($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die("Invalid request.");
    }
}
?>

<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/w3.css">
     <script src="js/aes.js"></script>
     <script src="js/encryption.js"></script>
  <script src="js/jquery-3.6.0.min.js"></script>
  <link href="css/bootstrap.css" rel="stylesheet">
  <script src="js/bootstrap.min.js"></script>
  <link href="css/summernote.css" rel="stylesheet">
     <script src="js/html_edit.js" type="text/javascript"></script>
  <link rel="stylesheet" href="css/styles.css">
  <script src="js/summernote.js"></script>

<?php
include_jump_nav();
echo "</head>";

if ($a_id) {
    // $a_id is already cast to int — safe to embed directly in JS
    echo "<body onload='jump_nav($a_id);'>";
} elseif ($search_keyword) {
    $sk_js = json_encode($search_keyword, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
    echo "<body onload='jump_nav(null, $sk_js);'>";
} elseif ($search_title) {
    $st_js = json_encode($search_title, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
    echo "<body onload='jump_nav(null, null, $st_js);'>";
} else {
    echo "<body>";
}
?>

    <header>
      Edit articles
    </header>
    <menu_bar>
      <a href="./index.php" class="menu_button" ><button> Home </button></a>
      <a href="./add.php" class="menu_button" ><button> Add </button></a>
      <form action="index.php" method="GET" class="search_box" >
         <input type="text" name="search_text" class="search" id="search_text" placeholder="Regular expression search…">
      </form>
    </menu_bar>

     <div id="popup_enc">
     <div>Enter Passphrase to encrypt:</div>
     <input id="pass" type="password"/>
     <button onclick="popup_enc_post('id_form_body','id_textarea_body')">Encrypt</button>
     <button onclick="popup_enc_cancel()">Cancel</button>
     </div>

     <div id="popup_dec">
     <div>Enter Passphrase to decrypt:</div>
     <input id="pass" type="password"/>
     <button onclick="popup_dec_text()">Decrypt</button>
     <button onclick="popup_dec_cancel()">Cancel</button>
     </div>

     <div id="popup_file">
     <input type="file" />
     </div>

    <section>

<?php

$db = db_open();

date_default_timezone_set("America/Denver");

if ($a_id < 1) {
    echo "?!";
    exit;
}

// Helper: hidden CSRF field
$csrf_field = "<input type='hidden' name='csrf_token' value='" . htmlspecialchars($_SESSION['csrf_token']) . "'>";

// update title
if ($update_title) {
    $title = htmlspecialchars($update_title);
    $datestr = date("Y-m-d H:i");
    $title = trim($title);
    $stmt = $db->prepare("UPDATE articles SET a_title = :title, a_mod_date = :datestr WHERE a_id = :a_id");
    $stmt->bindValue(':title', $title, SQLITE3_TEXT);
    $stmt->bindValue(':datestr', $datestr, SQLITE3_TEXT);
    $stmt->bindValue(':a_id', $a_id, SQLITE3_INTEGER);
    if (!$stmt->execute()) {
        echo $db->lastErrorMsg();
    }
}

// update status — a_status bit 0 is pinned, bit 1 is deleted
if (!is_null($update_status)) {
    $stmt = $db->prepare("UPDATE articles SET a_status = :status WHERE a_id = :a_id");
    $stmt->bindValue(':status', $update_status, SQLITE3_INTEGER);
    $stmt->bindValue(':a_id', $a_id, SQLITE3_INTEGER);
    if (!$stmt->execute()) {
        echo $db->lastErrorMsg();
    }
}

// update body
if ($update_body) {
    $body    = htmlspecialchars($update_body);
    $datestr = date("Y-m-d H:i");
    $stmt = $db->prepare("UPDATE articles SET a_body = :body, a_mod_date = :datestr WHERE a_id = :a_id");
    $stmt->bindValue(':body', $body, SQLITE3_TEXT);
    $stmt->bindValue(':datestr', $datestr, SQLITE3_TEXT);
    $stmt->bindValue(':a_id', $a_id, SQLITE3_INTEGER);
    if (!$stmt->execute()) {
        echo $db->lastErrorMsg();
    }
    db_delete_keywords($a_id);
    db_add_keywords($a_id, $body);

    // jump back on success
    echo "<script>window.location = 'index.php?a_id=$a_id';</script>";
}

// add new link
if ($add_link && $add_link != 0) {
    db_add_link($a_id, $add_link);
}

// delete a link
if ($delete_link && $delete_link != 0) {
    db_delete_link($delete_link);
}

db_navigator($a_id);

// show article
echo "  <article>\n";

$stmt = $db->prepare("SELECT * FROM articles WHERE a_id = :a_id");
$stmt->bindValue(':a_id', $a_id, SQLITE3_INTEGER);
$ret  = $stmt->execute();
$row  = $ret->fetchArray(SQLITE3_ASSOC);

// date
echo "<p><b> Date : </b> ";
printf("<a href='index.php?a_id=%d'>%04d %s </a>\n", $a_id, $a_id, htmlspecialchars($row['a_datetime']));

// title
echo "<form method=\"post\" >" .
    $csrf_field .
    "<input type='hidden' name='a_id' value='$a_id' />" .
    "<label><b> Title </b></label>" .
    "<textarea name=\"update_title\" rows=\"1\"  >";
echo htmlspecialchars($row['a_title']);
echo "</textarea> ";
echo "<input type=\"submit\" name=\"t_button\" class=\"button\" value=\"Update Title\" /> ";
echo "</form>\n";

// pin — stationary article
$status = (int)$row['a_status'];
if (($status % 2) == 1) {
    $state = "Pinned";
    $value = $status - 1;
    $label = "Unpin";
} else {
    $state = "Not pinned";
    $value = $status + 1;
    $label = "Pin";
}
echo "<form method='post'>";
echo $csrf_field;
echo "<label>$state</label> <nbsp>";
echo "<input type='hidden' name='update_status' value='$value' />";
echo "<input type='hidden' name='a_id' value='$a_id' />";
echo "<input type='submit' value='" . htmlspecialchars($label) . "' />";
echo "</form>\n";

// delete article
if (($status % 4) >= 2) {
    $state = "Deleted";
    $value = $status - 2;
    $label = "Undelete";
} else {
    $state = "Active";
    $value = $status + 2;
    $label = "Delete";
}
echo "<form method='post'>";
echo $csrf_field;
echo "<label>$state</label> <nbsp>";
echo "<input type='hidden' name='a_id'  value='$a_id' />";
echo "<input type='hidden' name='update_status' value='$value' />";
echo "<input type='submit' value='" . htmlspecialchars($label) . "' />";
echo "</form>\n";

// list links
echo "<br><b> Links : </b>";
echo "<ul> ";
$stmt = $db->prepare(
    "SELECT a_id_2 AS 'a_id', al_id FROM article_links WHERE a_id_1 = :id " .
    "UNION SELECT a_id_1 AS 'a_id', al_id FROM article_links WHERE a_id_2 = :id"
);
$stmt->bindValue(':id', $a_id, SQLITE3_INTEGER);
$ret = $stmt->execute();
while ($l_row = $ret->fetchArray(SQLITE3_ASSOC)) {
    $l_a_id = (int)$l_row['a_id'];
    $al_id  = (int)$l_row['al_id'];
    echo "<form method=\"post\">";
    echo $csrf_field;
    printf("<li><a href='index.php?a_id=%d'>%04d </a>\n", $l_a_id, $l_a_id);
    echo "<input type='hidden' name='delete_link' value='$al_id' />";
    echo "<input type='hidden' name='a_id' value='$a_id' />";
    echo "<input type='submit' value='Delete' />";
    echo "</li></form>\n";
}
echo "</ul> ";

// add link selector
echo "<form method=\"post\">" .
     $csrf_field .
     "<input type=\"hidden\" name=\"a_id\" value=\"$a_id\" />" .
    "  <label >Add link:</label> " .
    "  <select name=\"add_link\" id=\"add_link\"> ";
echo "<option value=''> </option>";

$stmt = $db->prepare("SELECT * FROM articles WHERE a_id != :a_id ORDER BY a_id DESC");
$stmt->bindValue(':a_id', $a_id, SQLITE3_INTEGER);
$ret = $stmt->execute();
while ($l_row = $ret->fetchArray(SQLITE3_ASSOC)) {
    $opt_id    = (int)$l_row['a_id'];
    $opt_title = htmlspecialchars(substr($l_row['a_title'], 0, 20));
    echo "<option value=\"$opt_id\">$opt_id $opt_title</option>";
}

echo " </select> ";
echo " <input type=\"submit\" value=\"Add link\" >";
echo "</form>\n";

echo "</p>";

// article body
$body = htmlspecialchars_decode($row['a_body']);
echo "<form id='id_form_body' method=\"post\">";
echo $csrf_field;
echo "<input type='hidden' name='a_id' value='$a_id' />";
echo " <label><b> Article Text</b></label> ";
echo " <textarea id='id_textarea_body' name=\"update_body\" style=\"height:500px;\" >";
echo $body;
echo "</textarea> ";

echo "<input type=\"button\" name=\"button_b\" class=\"button\" value=\"Update Article Text\" ";
echo " onclick='search_encrypt_tag()' /> ";

echo "</form> ";

$db->close();

?>

       </article>
    </section>

    <footer>

    </footer>


  </body>
</html>
