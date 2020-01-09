/*  Cataloging Analyzer report: COTF (circ on the fly) records which should be cleaned up.
    These are apparently in the wrong location - should be loc codes ending with 'cotf'.
    Records were created at circ desk locs and never updated by the daily OCLC loader.
*/
-- Create reporting table with data needed for filtering
prompt Building vger_report.rpt_cotf_cleanup;

drop table vger_report.rpt_cotf_cleanup purge;
create table vger_report.rpt_cotf_cleanup as
with circ_locs as (
  select *
  from ucladb.location
  where location_code like '%loan'
)
, bibs_created_by_circ as (
  select
    bh.bib_id
  , bh.action_date as created_date
  , bh.operator_id
  , cl.location_id as created_loc_id
  , cl.location_code as created_loc_code
  , cl.location_name as created_loc_name
  from ucladb.bib_history bh
  inner join circ_locs cl 
    on bh.location_id = cl.location_id
    and bh.action_type_id = 1 --created
)
, excluded_mfhds as (
  select
    bm.bib_id
  , bm.mfhd_id
  , l.location_code as mfhd_loc_code
  , l.location_name as mfhd_loc_name
  from bibs_created_by_circ bc
  inner join ucladb.bib_mfhd bm on bc.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  where l.location_code like '%cotf' -- circ-on-the-fly
  or l.location_code like '__ill' -- interlibrary loan
  or l.location_code like '__rse' -- electronic reserves
  or l.location_code like '__rs' -- print reserves
  or l.location_code like '__crs' -- more print reserves
  or l.location_code like '__rsprscp' -- reserve personal copies
  or l.location_code in ('arcr', 'birsayr', 'mgciperm', 'mgcirs') -- various other reserves locs
)
select
  bc.created_date
, bc.created_loc_code
, l.location_code as mfhd_loc_code
, l.location_name as mfhd_loc_name
, bc.bib_id
, mm.mfhd_id
, mm.display_call_no
, bt.encoding_level as enc_lvl
, vger_support.unifix(bt.title_brief) as title
from bibs_created_by_circ bc
inner join ucladb.bib_text bt on bc.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on bc.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where not exists (
  select *
  from excluded_mfhds
  where bib_id = bc.bib_id
)
and not exists (
  select *
  from ucladb.bib_history
  where bib_id = bc.bib_id
  and operator_id = 'uclaloader'
)
;

grant select on vger_report.rpt_cotf_cleanup to ucla_preaddb;

create index vger_report.ix_rpt_cotf_cleanup on vger_report.rpt_cotf_cleanup (bib_id);
