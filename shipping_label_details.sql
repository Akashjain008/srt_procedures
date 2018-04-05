CREATE OR REPLACE FUNCTION public.shipping_label_details(iso_code text, OUT "shippingLabel" json[])
 RETURNS json[]
 LANGUAGE plpgsql
AS $function$
    BEGIN
	"shippingLabel" := ARRAY(SELECT row_to_json(r) FROM(
				select rs.id as rsp_id, rs.rsp_city, coalesce(rs.rsp_state,null) as rsp_state, rs.rsp_name, rs.rsp_pincode, rs.rsp_iso_code, rs.rsp_address, 
				rs.rsp_email, rs.rsp_phone_number, lo.partner_name as logistic_partner, map.service_iso_code, map.logistic_account, map.proforma_invoice
				from mst_rsp rs
				left join mst_repair_program_country_rsp_logistic_mapping map on map.rsp_id = rs.id --and map.service_iso_code = rs.rsp_iso_code
				inner join mst_logistic_partner lo on lo.id = map.logistic_id and lo.is_active = true
				where map.service_iso_code = iso_code and rs.is_active = true
			)r);

	
    END;
$function$
