LOAD DATA
CHARACTERSET UTF8
APPEND
INTO TABLE vger_subfields.ucladb_bib_subfield_del_948
FIELDS TERMINATED BY x'09'
TRAILING NULLCOLS
( record_id
, field_seq
, subfield_seq
, indicators
, tag
, subfield CHAR(9999)
)
