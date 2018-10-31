/*  Cataloging Analyzer report: Multiple UCOCLC fields
    Bib records with multiple OCLC numbers (035 $a ucoclc)
*/
-- Create reporting table with data needed for filtering
prompt Building vger_report.rpt_multiple_ucoclc;

drop table vger_report.rpt_multiple_ucoclc purge;
create table vger_report.rpt_multiple_ucoclc as
with multiple_ucoclc as (
  select bib_id
  from ucladb.bib_index
  where index_code = '0350'
  and normal_heading like 'UCOCLC%'
  group by bib_id
  having count(*) > 1
)
select
  bm.bib_id
, mm.mfhd_id
, substr(bt.bib_format, 2, 1) as bib_level
, l.location_code
from multiple_ucoclc mu
inner join ucladb.bib_text bt on mu.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
;

grant select on vger_report.rpt_multiple_ucoclc to ucla_preaddb;

create index vger_report.ix_rpt_multiple_ucoclc on vger_report.rpt_multiple_ucoclc (location_code, bib_level, bib_id, mfhd_id);

