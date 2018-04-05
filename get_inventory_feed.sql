CREATE OR REPLACE FUNCTION public.get_inventory_feed(customer text, site text, material text, serialized_flag text, oem text)
 RETURNS TABLE("inventoryId" integer, "invDate" date, "invTime" text, "invRegion" text, "invCountry" text, "invSite" text, "invSiteRef" text, "invSiteId2" text, "invCustomer" text, "invOem" text, "invMaterial" text, "invOnHand" integer, "invOnOrder" integer, "invDefective" integer, "invBlocked" integer, "invWeeklyExpectedUsage" integer, "invMaterialDesc" text, "invExtra1" text, "invExtra2" text, "invFeedback" text, "invModel" text, "invApc" text, "invBuyBackScrap" text, "invClassification" text, "partName" text, "partType" text, serialized text, serial text, comment text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (customer = 'null' AND site = 'null' AND material = 'null' AND serialized_flag = 'null') THEN
	
		RETURN QUERY SELECT i.id,i.inv_date,i.inv_time,inv_region,i.inv_country,i.inv_site,i.inv_site_ref,i.inv_site_id_2,i.inv_customer, i.inv_oem, i.inv_material,i.inv_on_hand,i.inv_on_order,i.inv_defective, i.inv_blocked, i.inv_weekly_expected_usage, i.inv_material_desc, i.inv_extra_1, i.inv_extra_2, i.inv_feedback,i.inv_model,i.inv_apc,i.inv_buyback_scrap, i.inv_inventory_classification,i.part_name,i.part_type,i.serialized,i.serial, i.comment,i.is_active, i.created_at, i.updated_at
		FROM public.inventory_feed i 
		WHERE i.is_active='true' AND LOWER(i.inv_oem) = LOWER(oem) 
		ORDER BY i.id;
	ELSE 
		RETURN QUERY SELECT i.id,i.inv_date,i.inv_time,inv_region,i.inv_country,i.inv_site,i.inv_site_ref,i.inv_site_id_2,i.inv_customer, i.inv_oem, i.inv_material,i.inv_on_hand,i.inv_on_order,i.inv_defective, i.inv_blocked, i.inv_weekly_expected_usage, i.inv_material_desc, i.inv_extra_1, i.inv_extra_2, i.inv_feedback,i.inv_model,i.inv_apc,i.inv_buyback_scrap, i.inv_inventory_classification,i.part_name,i.part_type,i.serialized,i.serial, i.comment,i.is_active, i.created_at, i.updated_at
		 FROM public.inventory_feed	i		
			WHERE (
				i.is_active='true' AND LOWER(i.inv_oem) = LOWER(oem) AND 
				(LOWER(i.inv_customer) = LOWER(customer) OR customer = 'null') AND
				(LOWER(i.inv_site) = LOWER(site) OR site = 'null') AND
				(LOWER(i.inv_material) = LOWER(material) OR material = 'null') AND
				(LOWER(i.serialized) = LOWER(serialized_flag) OR serialized_flag = 'null')				
			)
			ORDER BY i.id;
	END IF;
	
END;
$function$
