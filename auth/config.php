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

// Migrate: add rate-limiting columns if they don't exist yet
$cols = [];
$res = $db->query("PRAGMA table_info(users)");
while ($r = $res->fetchArray(SQLITE3_ASSOC)) {
    $cols[] = $r['name'];
}
if (!in_array('failed_attempts', $cols)) {
    $db->exec("ALTER TABLE users ADD COLUMN failed_attempts INTEGER NOT NULL DEFAULT 0");
}
if (!in_array('lockout_until', $cols)) {
    $db->exec("ALTER TABLE users ADD COLUMN lockout_until DATETIME DEFAULT NULL");
}
?>
