CREATE TABLE users (
    id integer unique,
    username text NOT NULL UNIQUE,
    password text NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    lockout_until DATETIME DEFAULT NULL,
  PRIMARY KEY("id" AUTOINCREMENT)
);
