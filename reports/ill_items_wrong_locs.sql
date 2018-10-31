/*  Cataloging Analyzer report: ILL Items in Wrong Locations
    Items coded as ILL but not in ILL locations.
*/
-- Create reporting table with data needed for filtering

prompt Building vger_report.rpt_ill_items_wrong_locs;

drop table vger_report.rpt_ill_items_wrong_locs purge;
create table vger_report.rpt_ill_items_wrong_locs as
select
  l.location_code
, mm.display_call_no as call_number
, ib.item_barcode
, vger_support.get_all_item_status(i.item_id) as item_status
, bmr.suppress_in_opac as bib_suppressed
, bt.bib_id
, mm.mfhd_id
, vger_support.unifix(bt.edition) as f250a -- has special use in ILL records
, vger_support.unifix(bt.pub_place) as f260a -- has special use in ILL records
, vger_support.unifix(bt.title) as title
from ucladb.item_type it
inner join ucladb.item i on it.item_type_id = i.item_type_id
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
inner join ucladb.bib_master bmr on bm.bib_id = bmr.bib_id
left outer join ucladb.item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --active
where it.item_type_code = 'ill'
and l.location_code not in ('biill', 'lwill', 'mgill', 'yrill')
order by location_code, bib_id
;

grant select on vger_report.rpt_ill_items_wrong_locs to ucla_preaddb;

