LOAD DATA
CHARACTERSET UTF8
APPEND
INTO TABLE vger_subfields.foobar_deleted_items -- calling script will change foobar to relevant db
WHEN (1) = '"'
FIELDS TERMINATED BY '","'
(	item_barcode TERMINATED BY ',"' ENCLOSED BY '"'
,	item_id INTEGER EXTERNAL
,	mfhd_id INTEGER EXTERNAL
,	bib_id INTEGER EXTERNAL
,	title
,	create_operator_id
,	delete_operator_id
,	delete_datetime DATE(19) "YYYY-MM-DD HH24:MI:SS"
,	lccn
,	item_type_id INTEGER EXTERNAL
,	item_type_code
,	media_type_id INTEGER EXTERNAL
,	media_type_code
,	location_id INTEGER EXTERNAL
,	location_code
,	item_enum
,	chron
,	year
,	caption
,	freetext
,	spine_label
,	copy_number INTEGER EXTERNAL
,	pieces INTEGER EXTERNAL
,	price INTEGER EXTERNAL TERMINATED BY '"'
)

