CREATE OR REPLACE FUNCTION public.insert_temp_inventory(inventoryarray text)
 RETURNS TABLE("invSite" text, "invCustomer" text, "invMaterial" text, "errorList" json, "insertedIntoDb" boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE inventory record;
declare get_inventory_id integer;
declare get_oem_id integer;
BEGIN
	-- Create temp table to hold json data
	drop table if exists tmp_inventoryinserteddata;
	create temp table tmp_inventoryinserteddata(
		"id" serial,
		"inv_site" text,
		"inv_customer" text,
		"inv_material" text,
		"error_List" json,
		"insertedInto_Db" boolean
	);

	FOR inventory IN 

		select * from json_to_recordset(inventoryArray::json) as (
		"invDate" date,"invTime" text,"invRegion" text,"invCountry" text,"invSite" text,"invSiteRef" text,"invSiteId2" text,"invCustomer" text,
		"invOem" text,"invMaterial" text,"invOnHand" integer,"invOnOrder" integer,"invDefective" integer,"invBlocked" integer,
		"invWeeklyExpectedUsage" integer,"invMaterialDesc" text,"invExtra1" text,"invExtra2" text,"invFeedback" text,"invModel" text,
		"invApc" text,"invBuybackScrap" text,"invInventoryClassification" text,"partName" text,"partType" text,"serialzed" text,"serial" text,
		"comment" text,"createdBy" text, "errorList" json, "jiraTicketUrl" text, "jiraIssueId" text
	)
	LOOP
		get_oem_id := (select id from mst_oem where LOWER(oem_name) = LOWER(inventory."invOem") and is_active = true);
		
		INSERT INTO public.temp_inventory_feed(
		inv_date, inv_time, inv_region, inv_country, inv_site, inv_site_ref, 
		inv_site_id_2, inv_customer, inv_oem, inv_material, inv_on_hand, 
		inv_on_order, inv_defective, inv_blocked, inv_weekly_expected_usage, 
		inv_material_desc, inv_extra_1, inv_extra_2, inv_feedback, inv_model, 
		inv_apc, inv_buyback_scrap, inv_inventory_classification, part_name, 
		part_type, serialized, serial, comment, created_at, created_by, 
		is_active,jira_ticket_url, jira_issue_id, oem_id)
		VALUES (inventory."invDate", inventory."invTime", inventory."invRegion", inventory."invCountry", inventory."invSite",
		inventory."invSiteRef", inventory."invSiteId2", inventory."invCustomer", inventory."invOem", inventory."invMaterial", 
		inventory."invOnHand", inventory."invOnOrder", inventory."invDefective", inventory."invBlocked", inventory."invWeeklyExpectedUsage", 
		inventory."invMaterialDesc", inventory."invExtra1", inventory."invExtra2",inventory."invFeedback", inventory."invModel",
		inventory."invApc", inventory."invBuybackScrap", inventory."invInventoryClassification", inventory."partName", inventory."partType",
		inventory."serialzed", inventory."serial", inventory."comment", now(), inventory."createdBy",
		'true', inventory."jiraTicketUrl",inventory."jiraIssueId", get_oem_id);

	-- 	insert into tmp_inventoryinserteddata ("inv_site","inv_customer","inv_material","error_List","insertedInto_Db")	
	-- 	values (inventory."invSite",inventory."invCustomer",inventory."invMaterial",inventory."errorList",true);

	END LOOP;

	return query (select "inv_site","inv_customer","inv_material","error_List", "insertedInto_Db" from tmp_inventoryinserteddata);

END;
$function$
