/*  Cataloging Analyzer report: Google shipment items with no OCLC number
*/
-- Create reporting table with data needed for filtering
prompt Building vger_report.rpt_gbs_no_oclc;

drop table vger_report.rpt_gbs_no_oclc purge;
create table vger_report.rpt_gbs_no_oclc as
select 
  gs.shipment_number
, gs.shipment_date
, gmv.cart_id
, gmv.bib_id
, gmv.mfhd_id
, gmv.location_code
, gmv.call_number
, gmv.item_barcode
, gmv.item_enum
, gmv.title
from vger_support.gbs_master_view gmv
inner join vger_support.gbs_shipment gs 
  on gmv.cart_id between gs.cart_id_start and gs.cart_id_end
  and gmv.charge_date between gs.min_charge_date and gs.shipment_date
where gmv.oclc is null
--order by vger_support.normalizecallnumber(call_number), item_enum
;

grant select on vger_report.rpt_gbs_no_oclc to ucla_preaddb;

