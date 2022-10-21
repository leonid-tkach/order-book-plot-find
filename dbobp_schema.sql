CREATE TABLE IF NOT EXISTS obps (
  id SERIAL PRIMARY KEY,
  nno INT NOT NULL,
  seccode VARCHAR NOT NULL,
  buysell VARCHAR NOT NULL,
  ttime INT NOT NULL,
  orderno INT NOT NULL,
  aaction INT NOT NULL,
  price REAL NOT NULL,
  volume INT NOT NULL,
  tradeno INT,
  tradeprice REAL,
  ddate VARCHAR,
  obplotno INT
);

COPY obps(nno, seccode, buysell, ttime, orderno, 
aaction, price, volume, tradeno, tradeprice, ddate, obplotno)
FROM './resources/L_S_G_2007_10_obps.csv'
DELIMITER ','
CSV HEADER;