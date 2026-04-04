<?php
// development blog webpage
// database functions
// toshi isogai 2022-2023
global $TAG;
$TAG = "#:([0-9_a-zA-Z-]+)";


if($_SERVER["HTTPS"] != "on") {
    header("Location: https://" . $_SERVER["HTTP_HOST"] . $_SERVER["REQUEST_URI"]);
    exit();
}



class MyDB extends SQLite3 {
    function __construct() {
        $this->open('db/notebook_1.db');    # database file
    }
}

function db_open () {
    $db = new MyDB();
    if(!$db) {
        echo $db->lastErrorMsg();
        exit;
    }
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
       // server using Windows
       $db->loadExtension('regexp.dll');
       
    } else {
       $db->loadExtension('pcre.so');
    }
    return $db;
}

function db_add_keywords($a_id, $body) {
    global $db;
    global $TAG;
    
    
    $keywords = array();
    if(preg_match_all("/($TAG)/", $body, $keywords,  PREG_SET_ORDER)) {
        
        foreach($keywords as &$keyword) {

            $sql = "select k_id from keywords where keyword = \"$keyword[0]\"; ";
            $ret = $db->querySingle($sql);
            if ($ret < 1 ) {
                # if keyword does not exist add it
                $sql = "INSERT INTO keywords (keyword) VALUES (\"$keyword[0]\"); ";
                $ret = $db->exec($sql);
                if(!$ret) {
                    echo $db->lastErrorMsg();
                    exit;
                }
                $k_id = $db->lastInsertRowID();
            } else {
                # keyword exists
                $k_id = $ret;
            }

            # add a link
            $sql = "INSERT INTO keyword_links (k_id, a_id) VALUES (\"$k_id\", \"$a_id\"); ";
            $ret = $db->exec($sql);
            if(!$ret) {
                echo $db->lastErrorMsg();
                exit;
            }
        }

    }
    return true;
}

function db_delete_keywords($a_id) {
    global $db;
    
    $sql = "delete from keyword_links where a_id = '$a_id'; ";
    
    return true;
}

function message($msg) {
         $msg2 = preg_replace("/'/", "`", $msg);
    echo "<script>console.log('**** $msg2 ****'); </script>";
}

function db_navigator($a_id=null,$search_keyword=null,$search_title=null) {
    global $db;
    # message("a_id is $a_id");
    echo "<nav>";

    # navigator index
    echo "<b>Chronological Index</b>";
    echo "  <nav_daily id='id_nav_daily'>";
    echo "<ul class='index'> ";
    # a_status bit 0 is pinned, bit 1 is deleted when 1
    $sql ="SELECT * from articles where (a_status % 4)=0 order by  a_id desc;";
    $ret = $db->query($sql);
    while($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
        $title = htmlspecialchars_decode($row['a_title']);
        $ref_id = "";
        if ($row['a_id'] == $a_id) {
            $ref_id = "id='id_nav_daily_$a_id'";
        } 
        
        printf( "<li $ref_id><a href='index.php?a_id=%d'>%04d %s %s</a></li>\n" ,
                $row['a_id'], $row['a_id'], substr($row['a_datetime'],0,10), $title );
        
    }
    echo "   </ul> </nav_daily> <br>\n";
    
    # navigator pinned
    echo "<b>Pinned</b>  <nav_pinned> <ul class='index'>\n";
    $sql ="SELECT * from articles where (a_status % 4)=1 order by a_id desc ;";
    $ret = $db->query($sql);
    while($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
        $ref_id = "";
        if ($row['a_id'] == $a_id) {
            $ref_id = "id='id_nav_pinned_$a_id'";
        } 
        printf( "<li $ref_id><a href='index.php?a_id=%d'>%04d %s %s</a></li>\n" ,  $row['a_id'], $row['a_id'], substr($row['a_datetime'],0,10), $row['a_title'] );
    }
    
    echo "   </ul>  </nav_pinned> <br>\n";

    # navigator deleted
    echo "<nav_deleted>";
    echo "<details><summary><b>Deleted</b></summary>";
    $sql ="SELECT * from articles where (a_status % 4)>=2 order by  a_id desc;";
    $ret = $db->query($sql);
    while($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
        $title = "<del>" . htmlspecialchars_decode($row['a_title']) . "</del>";
        printf( "<div class='detail_item' $ref_id><a href='index.php?a_id=%d'>%04d %s %s</a></div>\n" ,
                $row['a_id'], $row['a_id'], substr($row['a_datetime'],0,10), $title );
    }
    echo "</details>";
    echo "</nav_deleted>\n";
    echo "</nav> \n";

    # column-tag keywords
    echo "<col_tag>\n";
    echo "<b>tags</b>  <nav_keywords>\n";
    $sql ="SELECT keyword from keywords order by " .
         "CASE WHEN keyword GLOB '[A-Za-z]*' THEN keyword ELSE '~' || keyword END COLLATE NOCASE;";
    $ret = $db->query($sql);
    $search_keyword2 = "#:" . $search_keyword;
    while($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
        $buf = array();
        $keyword =  $row['keyword'];
        if($keyword == $search_keyword2) {
            #keyword searching. jump to keyword line
            $ref_id = "id='id_nav_keyword_s'";
            array_push($buf, "<details open $ref_id> <summary>   \n");
        } else {
            array_push($buf, "<details> <summary>   \n");
        }
        $ix = sizeof($buf) - 1;
        array_push($buf, sprintf( "<a href='index.php?search_keyword=%s'> %s </a></li>\n" ,  substr($keyword,2), $keyword ));
        array_push($buf, "</summary>");

        # list under each keyword
        $sql2 = "select * from articles a where a.a_id in " .
             "(select kl.a_id from keyword_links kl where kl.k_id in " .
             "(select k.k_id from keywords k where k.keyword = '$keyword') );" ;
        
        $ret2 = $db->query($sql2);
        while($row2 = $ret2->fetchArray(SQLITE3_ASSOC) ) {
            $ref_id = "";
            if ($row2['a_id'] == $a_id) {
                $ref_id = "id='id_nav_keyword_$a_id'";
                $buf[$ix] =  "<details open $ref_id> <summary>   \n";
            } 
            array_push($buf, "<div class='detail_item'>");
            array_push($buf, sprintf( "<a href='index.php?a_id=%d'>%04d %s %s</a>\n" ,
                                      $row2['a_id'], $row2['a_id'], substr($row2['a_datetime'],0,10), $row2['a_title'] ));
            array_push($buf, "</div>\n");
        }
        array_push($buf, "</details>\n");

        # echo all
        foreach($buf as $line) {
            echo $line;
        }
    }
    echo "</nav_keywords> \n";

    # column-tag titles
    echo "<br><b>titles</b>  <nav_titles> <ul class='index'>\n";
    #$sql ="SELECT * from articles order by lower(trim(a_title)) asc, a_id desc ;";
    # alphabetical order, move special charater to end
    #$sql ="SELECT * from articles order by  CASE WHEN a_title GLOB '[A-Za-z]*' THEN a_title ELSE '~' || a_title END COLLATE NOCASE;";
    
    # gather and sort by a_title 
    $sql = "select * from articles where ".
         "a_title in (SELECT DISTINCT a_title from articles) ".
         "order by  CASE WHEN a_title GLOB '[A-Za-z]*' THEN a_title ELSE '~' || a_title END COLLATE NOCASE";
    
    $ret = $db->query($sql);

    $last_title = null;
    $buf = array();
    $ix = 0;
    
    while($row = $ret->fetchArray(SQLITE3_ASSOC) ) {
        $a_title = $row['a_title'];
        if ($a_title != $last_title) {
            #new title
            if ($a_title) {
                # close the last title
                array_push($buf, "</details>\n");
            }

            if($search_title == $a_title) {
                array_push($buf, "<details open id='id_nav_title_s'> <summary>");
            } else {
                array_push($buf, "<details> <summary>");
            }
            $ix = sizeof($buf) -1;

            array_push($buf, sprintf( "<a href='index.php?search_title=%s'> %s </a></li></summary> \n" ,
                                      urlencode($a_title), $a_title ));
            $last_title = $a_title;
        }
        
        if ($row['a_id'] == $a_id) {
            $ref_id = "id='id_nav_title_$a_id'";
            $buf[$ix] = "<details open $ref_id> <summary> \n";
        }
        array_push($buf, sprintf( "<div class='detail_item'><a href='index.php?a_id=%d'>%04d %s %s</a></div>\n" ,
                           $row['a_id'], $row['a_id'], substr($row['a_datetime'],0,10), $a_title ));
    }
    
    foreach($buf as $line) {
        echo $line;
    }
    echo "   </ul>  </nav_titles> \n";
    echo "</col_tag> \n";
}

function db_add_link( $a_id_1, $a_id_2) {
    global $db;
    $sql = "INSERT INTO article_links (a_id_1, a_id_2)  VALUES ( $a_id_1, $a_id_2);";
    $ret = $db->exec($sql);
    if(!$ret) {
        echo $db->lastErrorMsg();
        exit;
    }
}

function db_delete_link( $al_id) {
    global $db;
    $sql = "DELETE FROM article_links where al_id='$al_id' ;";
    $ret = $db->exec($sql);
    if(!$ret) {
        echo $db->lastErrorMsg();
        exit;
    }
}

function include_jump_nav () {
    echo '
         <script>
     function jump_nav(arg_id_1=null, arg_id_2=null, arg_id_3=null) {
         if (arg_id_1) {
             id = "id_nav_daily_".concat(arg_id_1);
             document.getElementById(id).scrollIntoView();
             id = "id_nav_title_".concat(arg_id_1);
             document.getElementById(id).scrollIntoView();

             id = "id_nav_keyword_".concat(arg_id_1);
             if (document.getElementById(id)) {
                 // jump to article index in tag list
                 document.getElementById(id).scrollIntoView();
             }
         } 

         if (arg_id_2) {
             id = "id_nav_keyword_s";
             if (document.getElementById(id)) {
                 // jump to tag index in tag list
                 document.getElementById(id).scrollIntoView();
             }
         }

         if (arg_id_3) {
             id = "id_nav_title_s";
             if (document.getElementById(id)) {
                 // jump to tag index in tag list
                 document.getElementById(id).scrollIntoView();
             }
         }
     }
     </script> ';
}
?>
    
