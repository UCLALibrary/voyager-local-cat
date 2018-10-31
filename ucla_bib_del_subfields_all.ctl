LOAD DATA
CHARACTERSET UTF8
TRUNCATE
INTO TABLE vger_subfields.ucladb_bib_subfield_del
FIELDS TERMINATED BY x'09'
TRAILING NULLCOLS
( record_id
, field_seq
, subfield_seq
, indicators
, tag
, subfield CHAR(9999)
)
