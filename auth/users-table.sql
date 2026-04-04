CREATE TABLE users (
    id integer unique,
    username text NOT NULL UNIQUE,
    password text NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY("id" AUTOINCREMENT)               
  
);
