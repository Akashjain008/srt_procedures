CREATE OR REPLACE FUNCTION public.get_part_missing("pageIndex" integer, "pageSize" integer, OUT "partMissingData" json[], OUT "totalRecords" integer)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
    BEGIN
	"partMissingData":= ARRAY(SELECT row_to_json(r) 
		FROM(select tif.id, tif.inv_date AS "invDate", tif.inv_time AS "invTime", tif.inv_site AS "invSite", tif.inv_site_id_2 AS "invSiteId2", tif.inv_customer AS "invCustomer",
		 tif.inv_oem AS "invOem", tif.oem_id AS "oemId", tif.inv_material AS "invMaterial", tif.inv_material_desc AS "invMaterialDesc", tif.inv_model AS "invModel", tif.part_name AS "partName", 
		 tif.part_type AS "partType", tif.created_by AS "createdBy", tif.jira_ticket_url AS "jiraTicketUrl", tif.inv_region AS "invRegion", tif.inv_country AS "invCountry", tif.inv_site_ref AS "invSiteRef", 
		 tif.inv_on_hand AS "invOnHand", tif.inv_defective AS "invDefective", tif.inv_blocked AS "invBlocked", tif.inv_weekly_expected_usage AS "invWeeklyExpectedUsage", tif.inv_extra_1 AS "invExtra1",
		 tif.inv_extra_2 AS "invExtra2", tif.inv_feedback AS "invFeedback", tif.inv_apc AS "invApc", tif.inv_buyback_scrap AS "invBuybackScrap", tif.inv_inventory_classification AS "invInventoryClassification", 
		 tif.serialized, tif.serial, tif.comment, tif.inv_on_order AS "invonorder", tif.created_at AS "createdFrom", tif.is_added AS "isAdded", tif.is_active AS "isActive"
		from temp_inventory_feed tif where is_active=true 
		ORDER BY ID
		OFFSET "pageIndex" LIMIT "pageSize")r);
		"totalRecords":= (SELECT count(1) FROM public.temp_inventory_feed WHERE is_active = true );
 	
    END;
$function$
