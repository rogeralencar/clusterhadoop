-- init.sql
CREATE DATABASE IF NOT EXISTS LAB08;

CREATE TABLE IF NOT EXISTS LAB08.documentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data VARCHAR(255) NOT NULL
);

INSERT INTO LAB08.documentos (data) VALUES ('Grupo SD: Roger, Arthur, Luis Felipe, Lucas, Sabrina');

