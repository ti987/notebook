<?php
// written by toshi isogai
// 2021-2022

// Initialize the session
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

if (array_key_exists('cancel', $_POST)) {
    header("location: index.php");
    exit;
}

include 'functions.php';
$db = db_open();

date_default_timezone_set("America/Denver");
?>

<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/w3.css">
    <link rel="stylesheet" href="css/styles.css">
    <script type="text/javascript" src="js/aes.js"></script>
    <script type="text/javascript" src="js/encryption.js"></script>
  <script src="js/jquery-3.6.0.min.js"></script>
  <link href="css/bootstrap.css" rel="stylesheet">
  <script src="js/bootstrap.min.js"></script>
  <link href="css/summernote.css" rel="stylesheet">
  <script src="js/summernote.js"></script>
     <script src="js/html_edit.js" type="text/javascript"></script>

<?php
     include_jump_nav();
     echo "</head>";

$follow = null;
     if (array_key_exists('follow_up', $_GET)) {
         $follow = (int)$_GET['follow_up'];
     }
     if ($follow) {
         // $follow is an int — safe to embed directly in JS
         echo "<body onload='jump_nav($follow);'>";
     } else {
         echo "<body>";
     }
?>
     <div id="popup_enc">
     <div>Enter Passphrase to encrypt:</div>
     <input id="pass" type="password"/>
     <button onclick="popup_enc_post('id_form_body','id_textarea_body')">Encrypt</button>
     <button onclick="popup_enc_cancel()">Cancel</button>
     </div>

    <header>
      New article
    </header>
    <menu_bar>
      <a href="./index.php" class="menu_button" ><button> Home </button></a>
      <form action="index.php" method="GET" class="search_box" >
         <input type="text" name="search_text" class="search" id="search_text" placeholder="Regular expression search…">
      </form>
    </menu_bar>

<?php
     db_navigator($follow);

echo " <article>";

echo "<label>Date</label> " . date("Y-m-d H:i");

echo " <div style='display:block; height:100%;'>";
echo "      <form method='post' style='height:100%;' id='id_form_body' enctype='multipart/form-data' onsubmit='search_encrypt_tag();' >";
echo "<input type='hidden' name='csrf_token' value='" . htmlspecialchars($_SESSION['csrf_token']) . "'>";


if (array_key_exists('follow_up', $_GET)) {
    // continue with the same title, add a link, add keywords
    $follow_id = (int)$_GET['follow_up'];
    printf("<label>Follow-up Article </label><a href='index.php?a_id=%d'>%04d</a><br> \n", $follow_id, $follow_id);
    $stmt = $db->prepare("SELECT * FROM articles WHERE a_id = :a_id");
    $stmt->bindValue(':a_id', $follow_id, SQLITE3_INTEGER);
    $ret = $stmt->execute();
    if (!$ret) {
        echo $db->lastErrorMsg();
    }
    while ($row = $ret->fetchArray(SQLITE3_ASSOC)) {
        $title = htmlspecialchars($row['a_title']);
        $body  = htmlspecialchars($row['a_body']);
        echo "<label > Title </label>";
        echo "<textarea name='title1' rows='1' style='height:10%'>$title</textarea>";

        echo "<label > Article </label>";

        echo ' <div class="sliderdiv"> <label class="switch"> ';
        echo   "<input id='id_html_switch' type='checkbox' onchange='toggle_html(\"id_html_switch\", \"id_textarea_body\");'> ";
        echo   '<span class="slider"></span>';
        echo '</label> &nbsp; HTML Editor </div>';

        echo "<textarea id='id_textarea_body' name='article1' style='height:80%' >";
        if (preg_match_all("/($TAG)/", $body, $keywords, PREG_SET_ORDER)) {
            foreach ($keywords as &$keyword) {
                echo htmlspecialchars($keyword[0]) . " ";
            }
            echo "<br>\n";
        }
        echo "</textarea>\n";
        echo "<input type='hidden' name='link1' value='" . $follow_id . "' />";
    }
} else {
    echo "<label > Title </label>";
    echo "<textarea name='title1' rows='1' style='height:10%'></textarea>";
    echo "<label > Article Text </label>";
    echo "<textarea id='id_textarea_body' name='article1'  ></textarea>\n";
}

echo "<input type=\"button\" name=\"article1\" class=\"button\" value=\"Add\" ";
echo " onclick='search_encrypt_tag()' /> ";

?>

            <input type="submit" name="cancel" class="button" value="Cancel" />
          </form>
        </div>
      </article>
   </section>


<?php

$article1 = null;
if (array_key_exists('article1', $_POST)) {
    $article1 = $_POST['article1'];
}
$title1 = null;
if (array_key_exists('title1', $_POST)) {
    $title1 = $_POST['title1'];
}

if ($article1) {

    // Validate CSRF token
    if (empty($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die("Invalid request.");
    }

    $datestr = date("Y-m-d H:i");
    $title = htmlspecialchars($title1);
    $body  = htmlspecialchars($article1);
    $title = trim($title);
    if (($title == "") || preg_match('/^ *$/', $body)) {
        echo "Title and article can not be empty";
    } else {
        $stmt = $db->prepare(
            "INSERT INTO articles (a_datetime, a_title, a_body, a_mod_date) VALUES (:datetime, :title, :body, '')"
        );
        $stmt->bindValue(':datetime', $datestr, SQLITE3_TEXT);
        $stmt->bindValue(':title', $title, SQLITE3_TEXT);
        $stmt->bindValue(':body', $body, SQLITE3_TEXT);

        if (!$stmt->execute()) {
            echo $db->lastErrorMsg();
            exit;
        }
        $a_id = $db->lastInsertRowID();

        // add keywords
        db_add_keywords($a_id, $body);

        // add link
        if (array_key_exists('link1', $_POST)) {
            $link_int = (int)$_POST['link1'];
            db_add_link($a_id, $link_int);
        }

        $db->close();
        echo "Article added successfully\n";

        // jump back on success
        echo "<script>window.location = 'index.php';</script>";
    }
}

?>


  </body>
</html>
