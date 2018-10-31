-- Table of holdings SPAC codes to support Analyzer report(s)

prompt Building vger_report.mfhd_spac_code;

drop table vger_report.mfhd_spac_code purge;
create table vger_report.mfhd_spac_code as
select
  record_id as mfhd_id
, subfield as spac_code
from vger_subfields.ucladb_mfhd_subfield
where tag = '901a'
;
create index vger_report.ix_mfhd_spac_code on vger_report.mfhd_spac_code (spac_code, mfhd_id);

grant select on vger_report.mfhd_spac_code to ucla_preaddb;

