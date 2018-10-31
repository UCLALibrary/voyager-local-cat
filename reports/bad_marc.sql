prompt Building vger_report.rpt_bad_marc_data;

drop table vger_report.tmp_bad_marc_data purge;
create table vger_report.tmp_bad_marc_data as
select
  record_id as bib_id
, tag
, subfield
from vger_subfields.ucladb_bib_subfield
where subfield like '%[MARC+%'
;

drop table vger_report.rpt_bad_marc_data purge;
create table vger_report.rpt_bad_marc_data as
with hex as (
  -- Hex values 00..FF
  select trim(to_char(rownum - 1, '0X')) val from dual connect by rownum <= 256
)
, marc as (
  select '[MARC+' || val || ']' as marcval from hex
)
select
  m.marcval
, b.bib_id
, b.tag
, b.subfield
, case when exists (
    select *
    from vger_subfields.ucladb_bib_subfield
    where record_id = b.bib_id
    and tag = '856x'
    and subfield = 'CDL'
  )
  then 'Y'
  else 'N'
  end as scp
from marc m
inner join vger_report.tmp_bad_marc_data b
  on b.subfield like '%' || m.marcval || '%'
order by m.marcval, b.bib_id, b.tag
;

create index vger_report.ix_rpt_bad_marc_data on vger_report.rpt_bad_marc_data (marcval, bib_id);

grant select on vger_report.rpt_bad_marc_data to ucla_preaddb;

