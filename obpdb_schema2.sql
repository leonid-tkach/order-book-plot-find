/*
psql -h wdb.ca9hkvxdudzq.us-east-1.rds.amazonaws.com -U postgres -d obpdb -p 5432
*/

CREATE TABLE IF NOT EXISTS order_atts_cumsums (
	nno INT NOT NULL,
	seccode VARCHAR NOT NULL,
	datetimetxt VARCHAR NOT NULL,
	datetimemlls TIMESTAMP,
	price REAL NOT NULL,
	tradeprice REAL,
	volume INT NOT NULL,
	ddate VARCHAR NOT NULL,
	ttime_s INT NOT NULL,
	obplotno INT NOT NULL,
	att VARCHAR NOT NULL,
	val DOUBLE PRECISION NOT NULL,
	sharebal INT NOT NULL,
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
	STVOLobpcs DOUBLE PRECISION NOT NULL,
	sobp DOUBLE PRECISION NOT NULL,
	bobp DOUBLE PRECISION NOT NULL,
	max_sobp_bobp DOUBLE PRECISION NOT NULL,
	minus_max_sobp_bobp DOUBLE PRECISION NOT NULL,
	stday DOUBLE PRECISION NOT NULL,
	btday DOUBLE PRECISION NOT NULL,
	max_std_btd DOUBLE PRECISION NOT NULL,
	minus_max_std_btd DOUBLE PRECISION NOT NULL,
	pcolor VARCHAR NOT NULL,
	pshape INT NOT NULL,
	psize REAL NOT NULL
);

/*
\copy order_atts_cumsums(nno, seccode, datetimetxt, price, tradeprice, volume, ddate, ttime_s, obplotno, att, val, sharebal, CBOVOLtdcs, CSOVOLtdcs, BOVOLtdcs, SOVOLtdcs, BTVOLtdcs, STVOLtdcs, CBOVOLobpcs, CSOVOLobpcs, BOVOLobpcs, SOVOLobpcs, BTVOLobpcs, STVOLobpcs, sobp, bobp, max_sobp_bobp, minus_max_sobp_bobp, stday, btday, max_std_btd, minus_max_std_btd, pcolor, pshape, psize) FROM C:\Users\lt\Documents\GWU\final_project\order-book-plot-find\cum_errors\resources\for_web_app\order_atts_cumsums_enh4_df.csv DELIMITER ',' CSV HEADER;
*/

/*
UPDATE order_atts_cumsums set datetimemlls = to_timestamp(datetimetxt,'YYYY-MM-DD\THH24:MI:SS.MS\Z');
*/

