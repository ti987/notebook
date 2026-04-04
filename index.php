<?php
// development notebook webpage
// database functions
// toshi isogai 2022-2023

// Initialize the session
session_start();
 
// Check if the user is logged in, if not then redirect him to login page
if(!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] !== true){
    header("location: auth/login.php");
    exit;
}
parse_str( $_SERVER['QUERY_STRING'], $qs_arr);

$a_id = null;
if (array_key_exists('a_id', $qs_arr)) {
    $a_id = $qs_arr['a_id'];
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
    $add_link = $qs_arr['add_link'];
}
$delete_link = null;
if (array_key_exists('delete_link', $qs_arr)) {
    $delete_link = $qs_arr['delete_link'];
}
    
//parse_str($_SERVER['QUERY_STRING']);
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

     if( $a_id ) {
         # scroll jump to a_id index
         echo "<body onload='jump_nav($a_id);'>";
     } else if($search_keyword) {
         echo "<body onload='jump_nav(null, \"$search_keyword\");'>";
     } else if($search_title) {
         $st2 = preg_replace("/'/", "&apos;", $search_title);
         echo "<body onload='jump_nav(null, null, \"$st2\");'>";
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

$TAGKEY = "#:";  # keyword marker



if ( $a_id ) {
    echo "<a href='./edit.php?a_id=$a_id' class='menu_button'> <button> Edit  </button></a>";
    echo "<a href='./add.php?follow_up=$a_id' class='menu_button'> <button> Follow Up </button></a>";
}
?>
   <a href="./auth/logout.php" class="menu_button_right" ><button> Logout </button></a>

     <a href="./upload.php" class="menu_button_right" ><button>file upload </button></a>
    
<form action="index.php" method="GET" class="search_box" >
    <input type="text" name="search_text" class="search" id="search_text" placeholder="Search here!"/>
    <!--    <input type="submit" name="submit" class="submit" id="search_button" value="Search"> -->
    </form>

                                                                                        
    </menu_bar>
    
    <section>
    
<?php

    db_navigator($a_id,$search_keyword,$search_title);
    

# show article 
echo "  <article>\n";

# URI may have search index
if ( $search_text ) {
    # from search_box
    $pat = "(?i:$search_text)";
    $pat = preg_replace("/'/", "&apos;", $pat);

    $sql ="SELECT * from articles where (a_title regexp '$pat')" .
         " or (a_body regexp '$pat')" .
         " or (a_mod_date regexp '$pat')" .
         " or (a_datetime regexp '$pat') ;";
    # printf("Seached $pat ");
    # printf("from Title and Article body -- $sql");
    
} elseif ( $search_keyword ) {
    # from keyword index
    $keyword = $TAGKEY . $search_keyword;
    $sql = "select * from articles a where a.a_id in " .
           "(select kl.a_id from keyword_links kl where kl.k_id in " .
           "(select k.k_id from keywords k where k.keyword = '$keyword') );" ;
    
} elseif ( $search_title ) {
    # from title index
    $sql ="SELECT * from articles where a_title = \"$search_title\";";
    
} elseif ( $a_id ) {
    # a_id search
    $sql ="SELECT * from articles where a_id = '$a_id';";
} else {
      # plain index page
    $sql ="SELECT * from articles order by a_id desc limit 1;";
}


$ret = $db->query($sql);

$row = $ret->fetchArray(SQLITE3_ASSOC);
if (! $row) {
    echo("text not found");
}
while ($row) {
    
    printf( "<b>Date </b> %s ", $row['a_datetime']);
    printf( "<b>Article </b><a href='index.php?a_id=%d'>%04d</a> \n" , $row['a_id'], $row['a_id']);
    if ($row['a_mod_date']) {
        printf( "&nbsp;<b>Last Mod Date </b> %s ", $row['a_mod_date']);
    }
    
    $title = $row['a_title'];
    $title = htmlspecialchars_decode($title);
    if ($search_text) {
        $title = preg_replace("/($search_text)/i",  '<search_text>\1</search_text>', $title);
    }

    if (($row['a_status'] % 4) >= 2) {
        #deleted
        $title = "<del>$title</del>";
    }
    
    printf("<br><b>Title </b>%s\n", $title);
    
    # list links 
    echo "<br><b> Links  </b>";
    echo "<ul> ";
    $a_id = $row['a_id'];
    $sql2 ="SELECT a_id_2 as \"a_id\" from article_links " .
          "where a_id_1=$a_id union select a_id_1 as \"a_id\" from article_links where a_id_2=$a_id;";
    $ret2 = $db->query($sql2);
    while($row2 = $ret2->fetchArray(SQLITE3_ASSOC) ) {
        printf( "<li><a href='index.php?a_id=%d'>%04d </a></li>\n" ,  $row2['a_id'], $row2['a_id'] );
    }
    echo "</ul> ";
    echo "<b> Article Text </b>";
    echo "<br> ";
    $body = htmlspecialchars_decode($row['a_body']);
    $body = preg_replace("/($TAG)/", '<a href="index.php?search_keyword=\2"> <keyword>\1</keyword> </a> &nbsp;', $body);
    if($search_text) {
        $body = preg_replace("/($search_text)/i", '<search_text>\1</search_text>', $body);
    }
    echo  $body ."\n";
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
