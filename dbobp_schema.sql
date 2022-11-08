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

/*
UPDATE order_atts_cumsums set datetimemlls = to_timestamp(datetimetxt,'YYYY-MM-DD HH24:MI:SS.MS');
*/

CREATE TABLE IF NOT EXISTS obp_cum_atts (
	id SERIAL PRIMARY KEY,
	seccode VARCHAR NOT NULL,
	ddate VARCHAR NOT NULL,
	obplotno INT NOT NULL,
	tradevol DOUBLE PRECISION NOT NULL,
	buysellobp VARCHAR NOT NULL,
	tradesnotrades VARCHAR NOT NULL,
	buysellyield DOUBLE PRECISION,
	obptovolratio DOUBLE PRECISION NOT NULL,
	minmaxratio DOUBLE PRECISION NOT NULL
);

/*
\copy obp_cum_atts(seccode, ddate, obplotno, tradevol, buysellobp, tradesnotrades, buysellyield, obptovolratio, minmaxratio)  FROM C:\Users\lt\Documents\GWU\final_project\order-book-plot-find\resources\for_web_app\L_S_G_2007_10_8-9_obp_cum_atts.csv DELIMITER ',' CSV HEADER;
*/

/*
ALTER TABLE obps ADD COLUMN ttime_s INT;
UPDATE obps SET ttime_s = obps.ttime/1000;
*/

/*
CREATE TABLE order_atts_cumsums_enhanced AS 
	SELECT
		oac.nno,
		oac.seccode,
		oac.datetimemlls,
		obps.price,
		obps.tradeprice,
		obps.volume,
		oac.ddate,
		obps.ttime_s,
		oac.obplotno,
		oac.att,
		oac.val,
		oac.sharebal,
		oac.bprofit,
		oac.sprofit,
		oac.obpminprice,
		oac.obpmaxprice,
		oac.CBOVOLtdcs,
		oac.CSOVOLtdcs,
		oac.BOVOLtdcs,
		oac.SOVOLtdcs,
		oac.BTVOLtdcs,
		oac.STVOLtdcs,
		oac.CBOVOLobpcs,
		oac.CSOVOLobpcs,
		oac.BOVOLobpcs,
		oac.SOVOLobpcs,
		oac.BTVOLobpcs,
		oac.STVOLobpcs
	FROM order_atts_cumsums AS oac LEFT JOIN obps ON 
		oac.nno = obps.nno AND oac.ddate = obps.ddate;
*/

/*
ALTER TABLE order_atts_cumsums_enhanced ADD COLUMN id SERIAL PRIMARY KEY;
*/

/*
CREATE TABLE obp_minmax_atts AS 
	SELECT
		oac.seccode,
		oac.ddate,
		oac.obplotno,
		MIN(oac.datetimemlls) AS obpbegin,
		MAX(oac.datetimemlls) AS obpend,
		MIN(oac.price) AS obpminprice,
		MAX(oac.price) AS obpmaxprice
	FROM obp_cum_atts AS oca
	INNER JOIN order_atts_cumsums_enhanced AS oac
	ON 
		oca.seccode = oac.seccode AND
		oca.ddate = oac.ddate AND
		oca.obplotno = oac.obplotno
	GROUP BY oac.seccode, oac.ddate, oac.obplotno;
*/

/*
CREATE TABLE obp_cum_minmax_atts AS
	SELECT
		oca.seccode,
		oca.ddate,
		oca.obplotno,
		oca.tradevol,
		oca.buysellobp,
		oma.obpbegin,
		oma.obpend,
		oma.obpminprice,
		oma.obpmaxprice,
		oca.tradesnotrades,
		oca.buysellyield,
		oca.obptovolratio,
		oca.minmaxratio
	FROM obp_cum_atts AS oca LEFT JOIN obp_minmax_atts AS oma
	ON 
		oca.seccode = oma.seccode AND
		oca.ddate = oma.ddate AND
		oca.obplotno = oma.obplotno;
*/

/*
CREATE TABLE obp_cum_atts_enh AS
	SELECT DISTINCT
		ocma.seccode,
		ocma.ddate,
		ocma.obplotno,
		ocma.tradevol,
		ocma.buysellobp,
		oace.sharebal,
		oace.bprofit,
		oace.sprofit,
		ocma.obpbegin,
		ocma.obpend,
		ocma.obpminprice,
		ocma.obpmaxprice,
		ocma.tradesnotrades,
		ocma.buysellyield,
		ocma.obptovolratio,
		ocma.minmaxratio
	FROM obp_cum_minmax_atts AS ocma INNER JOIN order_atts_cumsums_enhanced AS oace
	ON 
		ocma.seccode = oace.seccode AND
		ocma.ddate = oace.ddate AND
		ocma.obplotno = oace.obplotno;
*/

/*
ALTER TABLE obp_cum_atts_enh ADD COLUMN id SERIAL PRIMARY KEY;
*/

/*
CREATE TABLE order_atts_cumsums_enh2 AS 
TABLE order_atts_cumsums_enhanced;
*/

/*
ALTER TABLE order_atts_cumsums_enh2
	DROP COLUMN sharebal,
	DROP COLUMN bprofit,
	DROP COLUMN sprofit,
	DROP COLUMN obpminprice,
	DROP COLUMN obpmaxprice;
*/

ALTER TABLE order_atts_cumsums_enh2 ADD COLUMN pcolor VARCHAR;
UPDATE order_atts_cumsums_enh2 
	SET pcolor = CASE 
		WHEN att = 'BOVOL' THEN 'aquamarine'
		WHEN att = 'SOVOL' THEN 'coral'
		ELSE '#004481' END;



