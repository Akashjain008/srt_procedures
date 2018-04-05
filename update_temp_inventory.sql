CREATE OR REPLACE FUNCTION public.update_temp_inventory(part_id integer, partcode text, partdesc text, oemid integer, partname text, parttype text, isserialized boolean, userid integer)
 RETURNS json
 LANGUAGE plpgsql
AS $function$

DECLARE
count integer;
update_count integer;
    BEGIN
	-- count:= (select count(1) from map_problem_found_customer_complaint where LOWER(code_type_id) = LOWER(codetypeid));
-- 	IF (count > 0 AND flag = 'i') THEN
-- 		return '{ "status": "fail", "message": "Code Type Id is Already Present.", "errorCode": "COM004" }';
-- 	ELSE
		if (part_id is not null) then

			INSERT INTO public.temp_inventory_feed(
				inv_date, inv_time, inv_region, inv_country, inv_site, inv_site_ref, 
				inv_site_id_2, inv_customer, inv_oem, inv_material, inv_on_hand, 
				inv_on_order, inv_defective, inv_blocked, inv_weekly_expected_usage, 
				inv_material_desc, inv_extra_1, inv_extra_2, inv_feedback, inv_model, 
				inv_apc, inv_buyback_scrap, inv_inventory_classification, part_name, 
				part_type, serialized, serial, comment, created_at, created_by, 
				is_active,jira_ticket_url, jira_issue_id, oem_id, is_added, modified_id)
			SELECT inv_date, inv_time, inv_region, inv_country, inv_site, inv_site_ref, 
				inv_site_id_2, inv_customer, inv_oem, partcode, inv_on_hand, 
				inv_on_order, inv_defective, inv_blocked, inv_weekly_expected_usage, 
				partdesc, inv_extra_1, inv_extra_2, inv_feedback, inv_model, 
				inv_apc, inv_buyback_scrap, inv_inventory_classification, partname, 
				parttype, isserialized, serial, comment, created_at, userid, 
				is_active,jira_ticket_url, jira_issue_id, oemId, true, part_id
			FROM temp_inventory_feed WHERE id=part_id;

			UPDATE public.temp_inventory_feed 
				SET is_active = false
				WHERE id = part_id; 
			
			return '{ "status": "pass", "message": "Part updated successfully.", "errorCode": "COM002" }';
		else
			return '{ "status": "fail", "message": "Missing id", "errorCode": "COM003" }';
		end if;	
-- 	END IF; 
	
    END;

$function$
