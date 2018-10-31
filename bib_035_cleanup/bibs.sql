set linesize 10;

select bib_id
from bib_index
where index_code = '0350'
and normal_heading = to_char(bib_id)
order by bib_id
;

