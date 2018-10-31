/*  Cataloging Analyzer report: Integrating Resources as Monographs
    Bib records for integrating resources cataloged as monographs.
*/
-- Create reporting table with data needed for filtering
-- Takes about 40 minutes to run

prompt Building vger_report.rpt_ir_monographs;

drop table vger_report.rpt_ir_monographs purge;
create table vger_report.rpt_ir_monographs as
with looseleaf as (
  select record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag in ('300a', '500a')
  and regexp_like(subfield, 'loose[ -]{0,1}leaf')
)
select
  bm.bib_id
, mm.mfhd_id
, substr(bt.bib_format, 2, 1) as bib_level
, l.location_code
from looseleaf ll
inner join ucladb.bib_text bt on ll.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on ll.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
;

grant select on vger_report.rpt_ir_monographs to ucla_preaddb;

create index vger_report.ix_rpt_ir_monographs on vger_report.rpt_ir_monographs (location_code, bib_level, bib_id, mfhd_id);

