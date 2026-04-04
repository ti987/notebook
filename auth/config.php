<?php
/* Database credentials. Assuming you are running Sqlite3 */
class MyDB extends SQLite3 {
    function __construct() {
        $this->open('db/auth1.db');
    }
}
$db = new MyDB();
if(!$db) {
    echo $db->lastErrorMsg();
    exit;
}
$db->loadExtension('pcre.so');
?>
