/*  Cataloging Analyzer report: Duplicate OCLC Numbers
    OCLC Numbers appearing in multiple bib records.
*/
-- Create reporting table with data needed for filtering
prompt Building vger_report.rpt_duplicate_oclc;

drop table vger_report.rpt_duplicate_oclc purge;
create table vger_report.rpt_duplicate_oclc as
with dups as (
  select normal_heading
  from ucladb.bib_index bi
  where bi.index_code = '0350'
  and bi.normal_heading like 'UCOCLC%'
  group by normal_heading
  having count(*) > 1  
)
select 
  bm.bib_id
, mm.mfhd_id
, bi.normal_heading
, substr(bt.bib_format, 2, 1) as bib_level
, l.location_code
from dups d
inner join ucladb.bib_index bi 
  on d.normal_heading = bi.normal_heading
  and bi.index_code = '0350'
inner join ucladb.bib_text bt on bi.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
;

grant select on vger_report.rpt_duplicate_oclc to ucla_preaddb;

create index vger_report.ix_dup_oclc_loc_id on vger_report.rpt_duplicate_oclc (location_code, bib_level, normal_heading, bib_id, mfhd_id);

