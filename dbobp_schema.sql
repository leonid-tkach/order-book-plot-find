/*
psql -h ls-27d029825698cf13d3ab49ee92428a74a412cad4.cs6qemxizget.us-east-1.rds.amazonaws.com -U dbweaver -d dbobp -p 5432
*/

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
	ddate VARCHAR NOT NULL,
	obplotno INT NOT NULL
);

/*
\copy obps(nno, seccode, buysell, ttime, orderno, aaction, price, volume, tradeno, tradeprice, ddate, obplotno) FROM C:\Users\lt\Documents\GWU\final_project\order-book-plot-find\resources\for_web_app\L_S_G_2007_10_obps.csv DELIMITER ',' CSV HEADER;
*/

CREATE TABLE IF NOT EXISTS order_atts_cumsums (
	id SERIAL PRIMARY KEY,
	att VARCHAR NOT NULL,
	val DOUBLE PRECISION NOT NULL,
	datetimetxt VARCHAR NOT NULL,
	datetimemlls TIMESTAMP,
	nno INT NOT NULL,
	obplotno INT NOT NULL,
	ddate VARCHAR NOT NULL,
	seccode VARCHAR NOT NULL,
	sharebal VARCHAR NOT NULL,
	bprofit DOUBLE PRECISION NOT NULL,
	sprofit DOUBLE PRECISION NOT NULL,
	obpminprice REAL NOT NULL,
	obpmaxprice REAL NOT NULL,
	CBOVOLtdcs DOUBLE PRECISION NOT NULL,
	CSOVOLtdcs DOUBLE PRECISION NOT NULL,
	BOVOLtdcs DOUBLE PRECISION NOT NULL,
	SOVOLtdcs DOUBLE PRECISION NOT NULL,
	BTVOLtdcs DOUBLE PRECISION NOT NULL,
	STVOLtdcs DOUBLE PRECISION NOT NULL,
	CBOVOLobpcs DOUBLE PRECISION NOT NULL,
	CSOVOLobpcs DOUBLE PRECISION NOT NULL,
	BOVOLobpcs DOUBLE PRECISION NOT NULL,
	SOVOLobpcs DOUBLE PRECISION NOT NULL,
	BTVOLobpcs DOUBLE PRECISION NOT NULL,
	STVOLobpcs DOUBLE PRECISION NOT NULL
);

/*
\copy order_atts_cumsums(att, val, datetimetxt, nno, obplotno, ddate, seccode, sharebal, bprofit, sprofit, obpminprice, obpmaxprice, CBOVOLtdcs, CSOVOLtdcs, BOVOLtdcs, SOVOLtdcs, BTVOLtdcs, STVOLtdcs, CBOVOLobpcs, CSOVOLobpcs, BOVOLobpcs, SOVOLobpcs, BTVOLobpcs, STVOLobpcs) FROM C:\Users\lt\Documents\GWU\final_project\order-book-plot-find\resources\for_web_app\L_S_G_2007_10_order_atts_cumsums.csv DELIMITER ',' CSV HEADER;
*/

CREATE TABLE IF NOT EXISTS obp_cum_atts (
	id SERIAL PRIMARY KEY,
	seccode VARCHAR NOT NULL,
	ddate VARCHAR NOT NULL,
	obplotno INT NOT NULL,
	tradevol DOUBLE PRECISION NOT NULL,
	buysellobp VARCHAR NOT NULL,
	
	buysell VARCHAR NOT NULL,
	ttime INT NOT NULL,
	orderno INT NOT NULL,
	aaction INT NOT NULL,
	price REAL NOT NULL,
	volume INT NOT NULL,
	tradeno INT,
	tradeprice REAL,
);

/*
COPY obps(nno, seccode, buysell, ttime, orderno, 
aaction, price, volume, tradeno, tradeprice, ddate, obplotno)
FROM './resources/L_S_G_2007_10_obps.csv'
DELIMITER ','
CSV HEADER;
*/