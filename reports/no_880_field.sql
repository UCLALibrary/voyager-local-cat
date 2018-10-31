/*  Cataloging Analyzer report: No 880 Fields
    Bib records lacking any 880 fields (whether
    there *should* be any or not....).
*/
-- Create reporting table with data needed for filtering
prompt Building vger_report.rpt_bibs_no880;

drop table vger_report.rpt_bibs_no880 purge;
create table vger_report.rpt_bibs_no880 as
with bibs_no880 as (
  select bib_id from ucladb.bib_text
  -- filter out most common western languages
  where language not in ('eng', 'ger', 'spa', 'fre', 'ita', 'por', 'lat')
  minus
  select record_id from vger_subfields.ucladb_bib_subfield where tag like '880%'
)
select
  bm.bib_id
, mm.mfhd_id
, substr(bt.bib_format, 2, 1) as bib_level
, bt.language
, l.location_code
from bibs_no880 b
inner join ucladb.bib_text bt on b.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
;

grant select on vger_report.rpt_bibs_no880 to ucla_preaddb;

create index vger_report.ix_bibs_no880_lang on vger_report.rpt_bibs_no880 (language, location_code, bib_level, bib_id, mfhd_id);

