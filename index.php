<?php
// development notebook webpage
// database functions
// toshi isogai 2022-2023

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

parse_str($_SERVER['QUERY_STRING'], $qs_arr);

$a_id = null;
if (array_key_exists('a_id', $qs_arr)) {
    $a_id = (int)$qs_arr['a_id'];
}
$search_keyword = null;
if (array_key_exists('search_keyword', $qs_arr)) {
    $search_keyword = $qs_arr['search_keyword'];
}
$search_title = null;
if (array_key_exists('search_title', $qs_arr)) {
    $search_title = $qs_arr['search_title'];
}
$search_text = null;
if (array_key_exists('search_text', $qs_arr)) {
    $search_text = $qs_arr['search_text'];
}
$update_title = null;
if (array_key_exists('update_title', $qs_arr)) {
    $update_title = $qs_arr['update_title'];
}
$update_status = null;
if (array_key_exists('update_status', $qs_arr)) {
    $update_status = $qs_arr['update_status'];
}
$update_body = null;
if (array_key_exists('update_body', $qs_arr)) {
    $update_body = $qs_arr['update_body'];
}
$add_link = null;
if (array_key_exists('add_link', $qs_arr)) {
    $add_link = (int)$qs_arr['add_link'];
}
$delete_link = null;
if (array_key_exists('delete_link', $qs_arr)) {
    $delete_link = (int)$qs_arr['delete_link'];
}
?>

<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
     <meta name="viewport" content="width=device-width, initial-scale=1">
     <link rel="stylesheet" href="css/w3.css">
     <link rel="stylesheet" href="css/styles.css">
     <script src="js/aes.js"></script>
     <script src="js/encryption.js"></script>

<?php
include 'functions.php';
     include_jump_nav();
     echo "</head>";

     if ($a_id) {
         // $a_id is already cast to int — safe to embed directly
         echo "<body onload='jump_nav($a_id);'>";
     } elseif ($search_keyword) {
         // json_encode produces a safely-quoted JS string
         $sk_js = json_encode($search_keyword, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
         echo "<body onload='jump_nav(null, $sk_js);'>";
     } elseif ($search_title) {
         $st_js = json_encode($search_title, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
         echo "<body onload='jump_nav(null, null, $st_js);'>";
     } else {
         echo "<body>";
     }
?>

     <div id="popup_dec">
     <div>Enter Passphrase to decrypt:</div>
     <input id="pass" type="password"/>
     <button onclick="popup_dec_text()">Decrypt</button>
     <button onclick="popup_dec_cancel()">Cancel</button>
     </div>

     <header>
     Notebook
          <version>ver. 1.7.1</version>
          <version_note> Fixed QUERY_STRING parsing </version_note>
     </header>
     <menu_bar>
     <a href="./index.php" class="menu_button" ><button> Home </button></a>
     <a href="./add.php" class="menu_button" ><button> Add </button></a>

<?php
$db = db_open();

$TAGKEY = "#:";  // keyword marker

if ($a_id) {
    echo "<a href='./edit.php?a_id=$a_id' class='menu_button'> <button> Edit  </button></a>";
    echo "<a href='./add.php?follow_up=$a_id' class='menu_button'> <button> Follow Up </button></a>";
}
?>
   <a href="./auth/logout.php" class="menu_button_right" ><button> Logout </button></a>

     <a href="./upload.php" class="menu_button_right" ><button>file upload </button></a>

<form action="index.php" method="GET" class="search_box" >
    <input type="text" name="search_text" class="search" id="search_text" placeholder="Search here!"/>
    </form>


    </menu_bar>

    <section>

<?php

    db_navigator($a_id, $search_keyword, $search_title);

// show article
echo "  <article>\n";

// URI may have search index
if ($search_text) {
    // Full-text regexp search
    $pat = "(?i:" . $search_text . ")";
    $stmt = $db->prepare(
        "SELECT * FROM articles WHERE (a_title REGEXP :pat)" .
        " OR (a_body REGEXP :pat)" .
        " OR (a_mod_date REGEXP :pat)" .
        " OR (a_datetime REGEXP :pat)"
    );
    $stmt->bindValue(':pat', $pat, SQLITE3_TEXT);
    $ret = $stmt->execute();

} elseif ($search_keyword) {
    // Keyword index search
    $keyword = $TAGKEY . $search_keyword;
    $stmt = $db->prepare(
        "SELECT * FROM articles a WHERE a.a_id IN " .
        "(SELECT kl.a_id FROM keyword_links kl WHERE kl.k_id IN " .
        "(SELECT k.k_id FROM keywords k WHERE k.keyword = :keyword))"
    );
    $stmt->bindValue(':keyword', $keyword, SQLITE3_TEXT);
    $ret = $stmt->execute();

} elseif ($search_title) {
    // Title search
    $stmt = $db->prepare("SELECT * FROM articles WHERE a_title = :title");
    $stmt->bindValue(':title', $search_title, SQLITE3_TEXT);
    $ret = $stmt->execute();

} elseif ($a_id) {
    // Article by ID
    $stmt = $db->prepare("SELECT * FROM articles WHERE a_id = :a_id");
    $stmt->bindValue(':a_id', $a_id, SQLITE3_INTEGER);
    $ret = $stmt->execute();

} else {
    // Plain index page — most recent article
    $ret = $db->query("SELECT * FROM articles ORDER BY a_id DESC LIMIT 1");
}


$row = $ret->fetchArray(SQLITE3_ASSOC);
if (!$row) {
    echo("text not found");
}
while ($row) {

    printf("<b>Date </b> %s ", htmlspecialchars($row['a_datetime']));
    printf("<b>Article </b><a href='index.php?a_id=%d'>%04d</a> \n", (int)$row['a_id'], (int)$row['a_id']);
    if ($row['a_mod_date']) {
        printf("&nbsp;<b>Last Mod Date </b> %s ", htmlspecialchars($row['a_mod_date']));
    }

    $title = htmlspecialchars($row['a_title']);
    if ($search_text) {
        $title = preg_replace("/" . preg_quote($search_text, '/') . "/i", '<search_text>$0</search_text>', $title);
    }

    if (($row['a_status'] % 4) >= 2) {
        // deleted
        $title = "<del>$title</del>";
    }

    printf("<br><b>Title </b>%s\n", $title);

    // list links
    echo "<br><b> Links  </b>";
    echo "<ul> ";
    $cur_id = (int)$row['a_id'];
    $stmt2 = $db->prepare(
        "SELECT a_id_2 AS \"a_id\" FROM article_links WHERE a_id_1 = :id " .
        "UNION SELECT a_id_1 AS \"a_id\" FROM article_links WHERE a_id_2 = :id"
    );
    $stmt2->bindValue(':id', $cur_id, SQLITE3_INTEGER);
    $ret2 = $stmt2->execute();
    while ($row2 = $ret2->fetchArray(SQLITE3_ASSOC)) {
        printf("<li><a href='index.php?a_id=%d'>%04d </a></li>\n", (int)$row2['a_id'], (int)$row2['a_id']);
    }
    echo "</ul> ";
    echo "<b> Article Text </b>";
    echo "<br> ";
    // Body is stored with HTML entities; decode for display then linkify keywords
    $body = htmlspecialchars_decode($row['a_body']);
    $body = preg_replace("/($TAG)/", '<a href="index.php?search_keyword=\2"> <keyword>\1</keyword> </a> &nbsp;', $body);
    if ($search_text) {
        $body = preg_replace("/" . preg_quote($search_text, '/') . "/i", '<search_text>$0</search_text>', $body);
    }
    echo $body . "\n";
    echo "<br><br><hr class='end_article'>\n";
    $row = $ret->fetchArray(SQLITE3_ASSOC);
}

$db->close();

?>

    </article>
    </section>

    <footer>

    </footer>

    </body>
</html>
