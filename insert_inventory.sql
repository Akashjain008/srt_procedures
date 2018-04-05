CREATE OR REPLACE FUNCTION public.insert_inventory(inventoryarray text)
 RETURNS TABLE("invSite" text, "invSiteRef" text, "invOem" text, "invMaterial" text, "errorList" json, "insertedIntoDb" boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE inventory record;
declare get_inventory_id integer;
    BEGIN
    -- Create temp table to hold json data
	drop table if exists tmp_inventoryinserteddata;
	create temp table tmp_inventoryinserteddata("id" serial,"inv_site" text,"inv_site_ref" text, "inv_oem" text,"inv_material" text, "error_List" json, "insertedInto_Db" boolean);
	
	FOR inventory IN 

		select * from json_to_recordset(inventoryArray::json) as ("invDate" date,"invTime" text,"invRegion" text,"invCountry" text,"invSite" text,"invSiteRef" text,"invSiteId2" text,"invCustomer" text,"invOem" text,"invMaterial" text,"invOnHand" integer,"invOnOrder" integer,"invDefective" integer,"invBlocked" integer,"invWeeklyExpectedUsage" integer,"invMaterialDesc" text,"invExtra1" text,"invExtra2" text,"invFeedback" text,"invModel" text,"invApc" text,"invBuybackScrap" text,"invInventoryClassification" text,"partName" text,"partType" text,"serialzed" text,"serial" text,"comment" text,"createdBy" text, "createdFrom" text, "createdFromId" integer, "errorList" json)
	
	LOOP

	--===================  check if combination of invSiteRef, invOem & invMaterial exist ====== 
	get_inventory_id:= (select id from inventory_feed where LOWER(inv_site_ref) = LOWER(inventory."invSiteRef") AND LOWER(inv_oem) = LOWER(inventory."invOem") AND LOWER(inv_material) = LOWER(inventory."invMaterial") AND is_active = 'true');	

	--===================  if combination exists, then update is_active = false of old row  ==========
	IF (get_inventory_id is not null) THEN

		update inventory_feed set is_active = 'false' where id = get_inventory_id;

	END IF; 
	--=================== Insert into inventory_feed ============

	INSERT INTO public.inventory_feed(
             inv_date, inv_time, inv_region, inv_country, inv_site, inv_site_ref, 
            inv_site_id_2, inv_customer, inv_oem, inv_material, inv_on_hand, 
            inv_on_order, inv_defective, inv_blocked, inv_weekly_expected_usage, 
            inv_material_desc, inv_extra_1, inv_extra_2, inv_feedback, inv_model, 
            inv_apc, inv_buyback_scrap, inv_inventory_classification, part_name, 
            part_type, serialized, serial, comment, created_at, created_by, created_from, created_from_id,
              is_active)
    VALUES (inventory."invDate", inventory."invTime", inventory."invRegion", inventory."invCountry", inventory."invSite",inventory."invSiteRef", inventory."invSiteId2", inventory."invCustomer", inventory."invOem", inventory."invMaterial", inventory."invOnHand", inventory."invOnOrder", inventory."invDefective", inventory."invBlocked", inventory."invWeeklyExpectedUsage", inventory."invMaterialDesc", 
            inventory."invExtra1", inventory."invExtra2",inventory."invFeedback", inventory."invModel",inventory."invApc", inventory."invBuybackScrap", inventory."invInventoryClassification", inventory."partName", inventory."partType", inventory."serialzed", inventory."serial", inventory."comment", now(), inventory."createdBy",inventory."createdFrom",inventory."createdFromId",
            'true');


	insert into tmp_inventoryinserteddata ("inv_site","inv_site_ref","inv_oem","inv_material","error_List","insertedInto_Db")	values (inventory."invSite",inventory."invSiteRef",inventory."invOem",inventory."invMaterial",inventory."errorList",true);

	END LOOP;

	return query (select "inv_site","inv_site_ref","inv_oem","inv_material","error_List", "insertedInto_Db" from tmp_inventoryinserteddata);

    END;
$function$
