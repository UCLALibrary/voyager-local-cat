/*	Create_948_archive.sql: creates archive of data for cataloging statistics reports.
	Based on existence of 948 fields/subfields in bibliographic records.
	For ucladb only.  Uses data from
	- vger_subfields.ucladb_bib_subfield
	- ucladb.bib_index
	- ucladb.bib_text

	948 a b c d are mandatory
	948 d h i j are repeatable

	Called from vger_update_subfields after subfield db has been updated

	20080626 akohler: revised to truncate/insert into base tables instead of recreating;
		now using explicit definitions for more columns instead of implicit via CREATE TABLE AS.
*/

-- Base bib (non-948) data for cataloging 948 archive
TRUNCATE TABLE vger_report.cat_948_base;
INSERT INTO vger_report.cat_948_base
SELECT
	bt.bib_id
,	s948a.field_seq
,	SubStr(bt.bib_format, 1, 1) AS rec_type --LDR/06
,	SubStr(bt.bib_format, 2, 1) AS bib_lvl --LDR/07
,	Nvl(bt.encoding_level, 'blank') AS enc_lvl --LDR/17
,	bt.date_type_status --008/06
,	bt.begin_pub_date --008/07-10
,	bt.place_code --008/15-17
,	CASE
		WHEN SubStr(bt.bib_format, 1, 1) IN ('a', 'c', 'd', 'i', 'j', 'm', 'p', 't') THEN SubStr(bt.field_008, 24, 1) --008/23
		WHEN SubStr(bt.bib_format, 1, 1) IN ('e', 'f', 'g', 'k', 'o', 'r') THEN SubStr(bt.field_008, 30, 1) --008/29
		ELSE NULL
	END AS bib_form
,	bt.LANGUAGE --008/35-37
,	(SELECT REPLACE(normal_heading, 'OCOLC ', '') FROM ucladb.bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'OCOLC %' AND ROWNUM < 2) AS oclc
,	(SELECT subfield FROM vger_subfields.ucladb_bib_subfield WHERE record_id = s948a.record_id AND tag = '040a' AND ROWNUM < 2) AS f040a
,	(SELECT subfield FROM vger_subfields.ucladb_bib_subfield WHERE record_id = s948a.record_id AND tag = '049a' AND ROWNUM < 2) AS f049a
FROM vger_subfields.ucladb_bib_subfield s948a
INNER JOIN ucladb.bib_text bt ON s948a.record_id = bt.bib_id
WHERE s948a.tag = '948a'
;

-- Bib 948 data for cataloging 948 archive
TRUNCATE TABLE vger_report.cat_948_subfield;
INSERT INTO vger_report.cat_948_subfield
SELECT
	record_id AS bib_id
,	field_seq
,	tag
,	subfield
,	'N' as deleted
FROM vger_subfields.ucladb_bib_subfield
WHERE tag LIKE '948%'
;



-- Base view for reports; includes 948 $a $b $c since those are filtering criteria on all reports
-- 948 a b c are mandatory and non-repeatable so using inner joins; catalogers can cleanup bad data via separate reports
-- 948 e is not mandatory but is not repeatable, and is used alone or as part of format in many reports
-- Using table instead of view for performance

DROP TABLE vger_report.cat_948_base_rpt;
CREATE TABLE vger_report.cat_948_base_rpt AS
SELECT
	b.bib_id
,	b.field_seq
,	b.enc_lvl
,	b.rec_type
,	b.bib_lvl
,	b.date_type_status
,	b.begin_pub_date
,	b.place_code
,	b.bib_form
,	b.language
,	b.oclc
,	b.f040a
,	b.f049a
,	bib_lvl || '-' || rec_type || '-' || bib_form || '-' || s948e.subfield AS format
,	s948a.subfield AS s948a
,	s948b.subfield AS s948b
,	s948c.subfield AS s948c
,	s948e.subfield AS s948e
FROM vger_report.cat_948_base b
INNER JOIN vger_report.cat_948_subfield s948a
	ON b.bib_id = s948a.bib_id
	AND b.field_seq = s948a.field_seq
	AND s948a.tag = '948a'
INNER JOIN vger_report.cat_948_subfield s948b
	ON b.bib_id = s948b.bib_id
	AND b.field_seq = s948b.field_seq
	AND s948b.tag = '948b'
INNER JOIN vger_report.cat_948_subfield s948c
	ON b.bib_id = s948c.bib_id
	AND b.field_seq = s948c.field_seq
	AND s948c.tag = '948c'
LEFT OUTER JOIN vger_report.cat_948_subfield s948e
	ON b.bib_id = s948e.bib_id
	AND b.field_seq = s948e.field_seq
	AND s948e.tag = '948e'
;

CREATE INDEX vger_report.ix_cat_rpt_s948a ON vger_report.cat_948_base_rpt (s948a);
CREATE INDEX vger_report.ix_cat_rpt_s948b ON vger_report.cat_948_base_rpt (s948b);
CREATE INDEX vger_report.ix_cat_rpt_s948c ON vger_report.cat_948_base_rpt (s948c);
CREATE INDEX vger_report.ix_cat_rpt_s948e ON vger_report.cat_948_base_rpt (s948e);
CREATE INDEX vger_report.ix_cat_rpt_format ON vger_report.cat_948_base_rpt (format);
CREATE INDEX vger_report.ix_cat_rpt_language ON vger_report.cat_948_base_rpt (language);

GRANT SELECT ON vger_report.cat_948_base_rpt TO PUBLIC;

