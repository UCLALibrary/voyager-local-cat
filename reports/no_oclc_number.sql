/*  Cataloging Analyzer report: No OCLC Number
    Bib records lacking OCLC number (035 $a ucoclc)
*/
-- Create reporting table with data needed for filtering
prompt Building vger_report.rpt_no_oclc;

drop table vger_report.rpt_no_oclc purge;
create table vger_report.rpt_no_oclc as
select
  bm.bib_id
, mm.mfhd_id
, substr(bt.bib_format, 2, 1) as bib_level
, bt.language
, l.location_code
, br.suppress_in_opac as bib_suppressed
from ucladb.bib_text bt
inner join ucladb.bib_master br on bt.bib_id = br.bib_id
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where not exists (
  select *
  from ucladb.bib_index
  where bib_id = bt.bib_id
  and index_code = '0350'
  and normal_heading like 'UCOCLC%'
)
;

grant select on vger_report.rpt_no_oclc to ucla_preaddb;

create index vger_report.ix_no_oclc on vger_report.rpt_no_oclc (location_code, bib_level, language, bib_id, mfhd_id);

