--CREATE DATABASE kappa;
-- change database to kappa

CREATE SCHEMA security;

CREATE TABLE security.users (
  id SERIAL NOT NULL PRIMARY KEY,
  username VARCHAR(50),
  password VARCHAR(255),
  role VARCHAR(50)
);