<?php
// Initialize the session
session_start();
 
// Check if the user is logged in, if not then redirect him to login page
if(!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] !== true){
    header("location: auth/login.php");
    exit;
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
      <!-- script src="js/nicEdit.js" type="text/javascript"></script-->
  <link href="css/summernote.css" rel="stylesheet">
     <script src="js/html_edit.js" type="text/javascript"></script>
  <link rel="stylesheet" href="css/styles.css">
  <script src="js/summernote.js"></script>
     <script type="text/javascript">
//        bkLib.onDomLoaded(function() {
//               nic_editor = new nicEditor({fullPanel : true}).panelInstance('id_textarea_body');
//              document.getElementById('id_html_switch').checked = true;
//        });     
     </script>                                                     

<?php
include 'functions.php';

parse_str( $_SERVER['QUERY_STRING'], $qs_arr);

if ($qs_arr['a_id'] > 0) {
    #initial entry
    $a_id = $qs_arr['a_id'];
} else {
    # edit update entry
    $a_id = $_POST['a_id'];
}
$search_keyword = null;
if (array_key_exists('search_keyword', $_POST)) {
    $search_keyword = $_POST['search_keyword'];
}
$search_title = null;
if (array_key_exists('search_title', $_POST)) {
    $search_title = $_POST['search_title'];
}
$search_text = null;
if (array_key_exists('search_text', $_POST)) {
    $search_text = $_POST['search_text'];
}
$update_title = null;
if (array_key_exists('update_title', $_POST)) {
    $update_title = $_POST['update_title'];
}
$update_status = null;
if (array_key_exists('update_status', $_POST)) {
    $update_status = $_POST['update_status'];
}
$update_body = null;
if (array_key_exists('update_body', $_POST)) {
    $update_body = $_POST['update_body'];
}
$add_link = null;
if (array_key_exists('add_link', $_POST)) {
    $add_link = $_POST['add_link'];
}
$delete_link = null;
if (array_key_exists('delete_link', $_POST)) {
    $delete_link = $_POST['delete_link'];
}


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

    <header>
      Edit articles
    </header>
    <menu_bar>
      <a href="./index.php" class="menu_button" ><button> Home </button></a>
      <a href="./add.php" class="menu_button" ><button> Add </button></a>
      <form action="index.php" method="GET" class="search_box" >
         <input type="text" name="search_text" class="search" id="search_text" placeholder="Search here!">
        <!--    <input type="submit" name="submit" class="submit" id="search_button" value="Search"> -->
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

$method = "post";
#$method = "get"; # debug to show URL, no execution


# URI may have search index

if ( $a_id < 1 ) {
    echo "?!";
    exit;
}

# update title 
if($update_title) {
    $title = htmlspecialchars($update_title);
    $datestr = date("Y-m-d H:i");
    $title = trim($title);
    $title = preg_replace("/'/", "&apos;", $title);
    $sql = "update articles set a_title='$title', a_mod_date='$datestr' where a_id=$a_id;";
    $ret = $db->exec($sql);
    if(!$ret) {
        echo $db->lastErrorMsg();
    }
}

# update status
# a_status bit 0 is pinned, bit 1 is deleted when 1
if(! is_null($update_status) ) {
    $sql = "update articles set a_status='$update_status' where a_id=$a_id;";
    $ret = $db->exec($sql);
    if(!$ret) {
        echo $db->lastErrorMsg();
    }
}

# update body  
if($update_body) {
    $body =  htmlspecialchars($update_body);
    $datestr = date("Y-m-d H:i");
    $body = preg_replace("/'/", "&apos;", $body);
    $sql = "update articles set a_body='$body', a_mod_date='$datestr' where a_id=$a_id;";
    $ret = $db->exec($sql);
    if(!$ret) {
        echo $db->lastErrorMsg();
    }
    # process keywords
    db_delete_keywords($a_id);
    db_add_keywords($a_id, $body);
    #echo "<script> console.log('added keywords in $a_id');</script>\n";

        # jump back on success
        $url = "index.php?a_id=$a_id"; // this can be set based on whatever
        echo "<script>window.location = '$url';</script>";
}

# add new link
if($add_link) {
    if($add_link!=0) {
        db_add_link($a_id, $add_link);
    }
}

# delete a link
if($delete_link) {
    if($delete_link!=0) {
        db_delete_link($delete_link);
    }
}


    db_navigator($a_id);


# show article 
echo "  <article>\n";

$sql ="SELECT * from articles where a_id=$a_id;";
$ret = $db->query($sql);
$row = $ret->fetchArray(SQLITE3_ASSOC);

# date
echo "<p><b> Date : </b> ";
printf("<a href='index.php?a_id=%d'>%04d %s </a>\n" , $a_id , $a_id, $row['a_datetime'] );


# title
echo "<form method=\"" .$method ."\" >" .
    "<lable ><b> Title </b></label>" .
    "<textarea name=\"update_title\" rows=\"1\"  >";
echo $row['a_title'];
echo "</textarea> ";
echo "<input type='hidden' name='a_id' value='$a_id' />";
echo "<input type=\"submit\" name=\"t_button\" class=\"button\" value=\"Update Title\" /> ";
echo "</form>\n";


# pin - stationary article
$status = $row['a_status'];
if(($status % 2) == 1) {
    $state = "Pinned";
    $value = $status - 1;
    $label = "Unpin";
}else{
    $state = "Not pinned";
    $value = $status + 1;
    $label = "Pin";
}
echo "<form method='$method'  >" ;
echo "<label>$state</label> <nbsp>";
echo "<input type='hidden' name='update_status' value='$value' />";
echo "<input type='hidden' name='a_id' value='$a_id' />";
echo "<input type='submit' value='$label' />" ;
echo "</form>\n";

# delete article
$status = $row['a_status'];
if(($status % 4) >= 2) {
    $state = "Deleted";
    $value = $status - 2;
    $label = "Undelete";
}else{
    $state = "Active";
    $value = $status + 2;
    $label = "Delete";
}
echo "<form method='$method'  >" ;
echo "<label>$state</label> <nbsp>";
echo "<input type='hidden' name='a_id'  value='$a_id' />";
echo "<input type='hidden' name='update_status' value='$value' />";
echo "<input type='submit' value='$label' />" ;
echo "</form>\n";





# list links 
echo "<br><b> Links : </b>";
echo "<ul> ";
$sql ="SELECT a_id_2 as 'a_id', al_id from article_links where a_id_1='$a_id' union select a_id_1 as 'a_id', al_id from article_links where a_id_2='$a_id';";
$ret = $db->query($sql);
while($l_row = $ret->fetchArray(SQLITE3_ASSOC) ) {
    
    $l_a_id = $l_row['a_id'];
    $al_id = $l_row['al_id'];
    echo "<form method=\"" .$method ."\" >";
    echo "<input type=\"hidden\" name=\"al_id\" value=\"$al_id\" />" ;
    printf( "<li><a href='index.php?a_id=%d'>%04d </a>\n" , $l_a_id , $l_a_id );

echo     "<input type='hidden' name='delete_link' value='$al_id' />" ;
    echo "<input type='submit' value='Delete' />";
#    echo "<input type='submit' name='delete_link' class='button_delete' value='$al_id'>Delete </input> ";
    echo "</li></form>\n";
}
echo "</ul> ";

# add selector
echo "<form method=\"" .$method ."\" >" .
     "<input type=\"hidden\" name=\"a_id\" value=\"$a_id\" />" .
    "  <label >Add link:</label> " .
    "  <select name=\"add_link\" id=\"add_link\"> ";
echo "<option value=''> </option>";

$sql ="SELECT * from articles where a_id!=" . $a_id ." order by a_id desc;" ;

$ret = $db->query($sql);
while($l_row = $ret->fetchArray(SQLITE3_ASSOC) ) {
    echo $l_row['a_id'];
    echo "<option value=\"" . $l_row['a_id'] . "\">" . $l_row['a_id'] . " " . substr($l_row['a_title'],0,20) . "</option>";
}

echo " </select> ";
echo " <input type=\"submit\" value=\"Add link\" >";
echo "</form>\n";

echo "</p>";

# article body
$body = htmlspecialchars_decode($row['a_body']);
echo "<form id='id_form_body' method=\"" .$method ."\" >";
echo " <lable ><b> Article Text</b></label> " ;


## echo ' <div class="sliderdiv"> <label class="switch"> ';
## echo   "<input id='id_html_switch' type='checkbox' onchange='toggle_html(\"id_html_switch\", \"id_textarea_body\");'> ";
## echo   '<span class="slider"></span>';
## echo '</label> &nbsp; HTML Editor </div>' ;

 echo  " <textarea id='id_textarea_body' name=\"update_body\" style=\"height:500px;\" >";
 echo  $body;
 echo "</textarea> ";

echo "<input type=\"button\" name=\"button_b\" class=\"button\" value=\"Update Article Text\" ";

echo " onclick='search_encrypt_tag()' /> ";

## echo "<input type='submit' value='submit' class='button' />";
echo "</form> ";


$db->close();


?>

       </article>
    </section>

    <footer>

    </footer>



  </body>
</html>
