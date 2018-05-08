-- createdb -U postgres Kappa
-- psql -U postgres -d Kappa -a -f users.sql


CREATE TABLE customerstemp (
  id SERIAL NOT NULL,
  name VARCHAR,
  age INT,
  car VARCHAR,
  gender VARCHAR
);

CREATE TABLE users (
  id SERIAL NOT NULL PRIMARY KEY,
  username VARCHAR,
  password VARCHAR,
  role VARCHAR
);


-- TEMP DATA

INSERT INTO customerstemp VALUES (DEFAULT, 'Tito Pickens',29, 'Mazda','Male');
INSERT INTO customerstemp VALUES (DEFAULT, 'Rosa Cohen',32, 'GMC','Female');
INSERT INTO customerstemp VALUES (DEFAULT, 'Joseph Gilardo',58, 'Ford','Male');
INSERT INTO customerstemp VALUES (DEFAULT, 'Mirna Gustafa',24, 'Porsche','Female');
INSERT INTO customerstemp VALUES (DEFAULT, 'Rachel McAllen',38, 'Volkswagen','Female');
INSERT INTO customerstemp VALUES (DEFAULT, 'Andrea Mormo',35, 'Toyota','Female');
INSERT INTO customerstemp VALUES (DEFAULT, 'Ken Nurman',65, 'Scion','Male');