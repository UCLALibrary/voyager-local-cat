-- Table of bib 910 $a to support various batch jobs and reports

prompt Building vger_report.bib_f910a_data;

drop table vger_report.bib_f910a_data purge;
create table vger_report.bib_f910a_data as
  select
    record_id as bib_id
  , subfield as f910a
  from vger_subfields.ucladb_bib_subfield
  where tag = '910a'
;
create index vger_report.ix_bib_f910a_data_bib_id on vger_report.bib_f910a_data (bib_id);

grant select on vger_report.bib_f910a_data to ucla_preaddb;

