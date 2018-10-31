-- ISBNs for titles published after 1980
-- Uses regexp to avoid bad data in many MARC records
set linesize 15;
set tab on;
set trim on;

select distinct
bi.normal_heading as isbn
from ucladb.bib_text bt
inner join ucladb.bib_index bi on bt.bib_id = bi.bib_id and bi.index_code = '020N'
-- Quick and dirty but close enough
where bt.begin_pub_date > '1980'
;

