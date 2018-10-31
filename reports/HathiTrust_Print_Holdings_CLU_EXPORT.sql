-- Build tables of records qualified for various CLU extracts, to support HathiTrust Print Holdings extract
-- Took 10236 seconds (2 hours 50 minutes)
drop table vger_report.tmp_clu_export_1 purge;
create table vger_report.tmp_clu_export_1 as
select distinct
  bm.bib_id
from ucladb.bib_master bm
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join vger_report.bib_f910a_data f on bm.bib_id = f.bib_id
where l.location_code not like '%acq'
and l.location_code not like '%prscp'
and l.location_code not like 'sr%'
and l.location_code != 'in'
and l.suppress_in_opac = 'N'
and mm.suppress_in_opac = 'N'
and bm.suppress_in_opac = 'N'
and f.f910a not in ('ACQ', 'MARS', 'oclcmusic2')
and f.f910a not like '%3lvl%'
and f.f910a not like '%acq/sc%'
and not exists (select * from vger_subfields.ucladb_mfhd_subfield 
    where record_id = mm.mfhd_id and tag = '852h' and upper(subfield) like 'SEE INDIV%'
)
and (   exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h')
    or  exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852j')
)
;
create index vger_report.ix_tmp_clu_export_1 on vger_report.tmp_clu_export_1 (bib_id);

-- Group 2
drop table vger_report.tmp_clu_export_2 purge;
create table vger_report.tmp_clu_export_2 as
select distinct
  bm.bib_id
from ucladb.bib_master bm
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join vger_report.bib_f910a_data f on bm.bib_id = f.bib_id
inner join vger_subfields.ucladb_bib_subfield bs on bm.bib_id = bs.record_id and bs.tag = '856x'
where l.location_code = 'in'
and mm.suppress_in_opac = 'N'
and bm.suppress_in_opac = 'N'
and f.f910a not in ('ACQ', 'MARS', 'oclcmusic2')
and f.f910a not like '%3lvl%'
and f.f910a not like '%acq/sc%'
and not exists (select * from vger_subfields.ucladb_mfhd_subfield 
    where record_id = mm.mfhd_id and tag = '852h' and upper(subfield) like 'SEE INDIV%'
)
and bs.subfield = 'UCLA'
;
create index vger_report.ix_tmp_clu_export_2 on vger_report.tmp_clu_export_2 (bib_id);

-- Group 3
drop table vger_report.tmp_clu_export_3 purge;
create table vger_report.tmp_clu_export_3 as
select distinct
  bm.bib_id
from ucladb.bib_master bm
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join ucladb.item_stats ist on mi.item_id = ist.item_id
inner join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id
where l.location_code like 'sr%'
and mm.suppress_in_opac = 'N'
and bm.suppress_in_opac = 'N'
and not exists (select * from vger_subfields.ucladb_mfhd_subfield 
    where record_id = mm.mfhd_id and tag = '852h' and upper(subfield) like 'SEE INDIV%'
)
and substr(isc.item_stat_code, 1, 2) in (
  'aa', 'ai', 'ar', 'bi', 'ca', 'ck', 'cl', 'cs', 'ea', 'er', 'id', 'il', 'im', 'ip'
, 'lw', 'ma', 'mg', 'mi', 'mp', 'mu', 'sc', 'sg', 'sm', 'ue', 'yr'
)
and not exists (
  select * 
  from vger_report.bib_f910a_data
  where bib_id = bm.bib_id
  and (f910a like '%3lvl%' or f910a like '%acq/sc%')
)
;
create index vger_report.ix_tmp_clu_export_3 on vger_report.tmp_clu_export_3 (bib_id);

-- Group 4
drop table vger_report.tmp_clu_export_4 purge;
create table vger_report.tmp_clu_export_4 as
select distinct
  bm.bib_id
from ucladb.bib_text bt
inner join ucladb.bib_master bm on bt.bib_id = bm.bib_id
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where l.location_code not like '%acq'
and l.location_code not like '%prscp'
and l.location_code != 'in'
and l.suppress_in_opac = 'N'
and mm.suppress_in_opac = 'N'
and bm.suppress_in_opac = 'N'
and bt.bib_format like '%s'
and not exists (select * from vger_subfields.ucladb_mfhd_subfield 
    where record_id = mm.mfhd_id and tag = '852h' and upper(subfield) like 'SEE INDIV%'
)
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h')
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852i')
and not exists (
  select * 
  from vger_report.bib_f910a_data
  where bib_id = bm.bib_id
  and f910a not in ('ACQ', 'MARS', 'oclcmusic2')
)
;
create index vger_report.ix_tmp_clu_export_4 on vger_report.tmp_clu_export_4 (bib_id);

-- Group 5
/*  monograph holdings record contains $h and $i 
    AND associated bib record LACKS 910 
    but has 935 $a beginning with MC (that is, it migrated from the MC file in ORION1).
*/
drop table vger_report.tmp_clu_export_5 purge;
create table vger_report.tmp_clu_export_5 as
select distinct
  bm.bib_id
from ucladb.bib_text bt
inner join ucladb.bib_master bm on bt.bib_id = bm.bib_id
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where l.location_code not like '%acq'
and l.location_code not like '%prscp'
and l.location_code != 'in'
and l.suppress_in_opac = 'N'
and mm.suppress_in_opac = 'N'
and bm.suppress_in_opac = 'N'
and bt.bib_format like '%m'
and not exists (select * from vger_subfields.ucladb_mfhd_subfield 
    where record_id = mm.mfhd_id and tag = '852h' and upper(subfield) like 'SEE INDIV%'
)
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h')
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852i')
and exists (select * from vger_subfields.ucladb_bib_subfield where record_id = bm.bib_id and tag = '935a' and subfield like 'MC%')
and not exists (
  select * 
  from vger_report.bib_f910a_data
  where bib_id = bm.bib_id
  and f910a not in ('ACQ', 'MARS', 'oclcmusic2')
)
;
create index vger_report.ix_tmp_clu_export_5 on vger_report.tmp_clu_export_5 (bib_id);

