CREATE OR REPLACE FUNCTION public.rule_for_insert_inventory(arrayinventories text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE op_outputjson text := '';
declare recordCheck record;
declare inventory record;
Declare dbflag boolean;
declare errorList json:= '[]';
declare adderror record;
declare error record;
declare check_rsp_id integer;
declare check_material_id integer;
Begin

	-- Create temp table to hold json data
	drop table if exists tmp_createinventoryjsondata;
	create temp table tmp_createinventoryjsondata("id" serial, "invDate" date,"invTime" text,"invRegion" text,"invCountry" text,"invSite" text,"invSiteRef" text,"invSiteId2" text,"invCustomer" text,"invOem" text,"invMaterial" text,"invOnHand" integer,"invOnOrder" integer,"invDefective" integer,"invBlocked" integer,"invWeeklyExpectedUsage" integer,"invMaterialDesc" text,"invExtra1" text,"invExtra2" text,"invFeedback" text,"invModel" text,"invApc" text,"invBuybackScrap" text,"invInventoryClassification" text,"partName" text,"partType" text,"serialzed" text,"serial" text,"comment" text,"createdBy" text,"createdFrom" text, "createdFromId" integer, "errorList" text,
		"insertedIntoDb" boolean,"uniqueId" text);

	drop table if exists tmp_errorlistjson;
	create temp table tmp_errorlistjson("id" serial,"uniqueId" text,"errorCode" text, "errorMessage" text, "errorColumn" text, "errorType" text, "successFlag" boolean );
	
	insert into tmp_createinventoryjsondata("invDate" ,"invTime" ,"invRegion" ,"invCountry" , "invSite",
		"invSiteRef" ,"invSiteId2" ,"invCustomer" ,"invOem" ,"invMaterial" ,"invOnHand" ,"invOnOrder" ,"invDefective" ,"invBlocked" ,"invWeeklyExpectedUsage" ,"invMaterialDesc" , "invExtra1" ,"invExtra2" ,"invFeedback" ,"invModel","invApc" ,"invBuybackScrap","invInventoryClassification",
		"partName" ,"partType","serialzed" ,"serial" ,
		"comment" ,"createdBy","createdFrom", "createdFromId", "errorList" ,"insertedIntoDb","uniqueId")
	select * from json_to_recordset(arrayinventories::json) as ("invDate" date,"invTime" text,"invRegion" text,"invCountry" text,"invSite" text,"invSiteRef" text,"invSiteId2" text,"invCustomer" text,"invOem" text,"invMaterial" text,"invOnHand" integer,"invOnOrder" integer,"invDefective" integer,"invBlocked" integer,"invWeeklyExpectedUsage" integer,"invMaterialDesc" text,"invExtra1" text,"invExtra2" text,"invFeedback" text,"invModel" text,"invApc" text,"invBuybackScrap" text,"invInventoryClassification" text,"partName" text,"partType" text,"serialzed" text,"serial" text,"comment" text,"createdBy" text , "createdFrom" text, "createdFromId" integer, "errorList" text,
		"insertedIntoDb" boolean,"uniqueId" text);

	FOR inventory IN (select * from tmp_createinventoryjsondata)
	LOOP
		truncate tmp_errorlistjson;
		
		insert into tmp_errorlistjson("uniqueId","errorCode", "errorMessage", "errorColumn", "errorType", "successFlag")
		SELECT * from json_to_recordset(inventory."errorList"::json) as ("uniqueId" text,"errorCode" text, "errorMessage" text, "errorColumn" text, "errorType" text, "successFlag" boolean);
		
		FOR recordCheck IN (SELECT * FROM tr_rule where is_active=true and db_level=true and event_type ='insertInventory')
		LOOP	
			--=======check material data in master data rule========
			if (recordCheck."code" = 'SRTI10005') then
				if (inventory."invMaterial" is not null and inventory."invMaterial" != '') then
					--=======check repairServicePartnerId in table================					
					if not exists(select 1 from mst_part p join mst_oem o on o.id = p.oem_id where  lower(p.part_code) = lower(inventory."invMaterial") AND lower(o.oem_name) = lower(inventory."invOem") AND p.is_active = true) then
						insert into tmp_errorlistjson("uniqueId","errorCode", "errorMessage", "errorColumn", "errorType", "successFlag")
						values (inventory."uniqueId",recordCheck."code",recordCheck."name", recordCheck."column_name", recordCheck."type", false);
					end if;
				End if;
			ENd if;
					
			--=======check repair Service Partner Id rule========
			if (recordCheck."code" = 'SRTI10008') then
				if (inventory."invSiteRef" is not null and inventory."invSiteRef" != '') then
					--=======check repairServicePartnerId in table================					
					if not exists(select 1 from mst_rsp where lower(rsp_id) = lower(inventory."invSiteRef") and is_active = true) then
						insert into tmp_errorlistjson("uniqueId","errorCode", "errorMessage", "errorColumn", "errorType", "successFlag")
						values (inventory."uniqueId",recordCheck."code",recordCheck."name", recordCheck."column_name", recordCheck."type", false);
					end if;
				End if;
			ENd if;
		END LOOP;
		--=============insert all the error list in the variable and send to the response=============
		errorList:= (select array_to_json(array_agg(row_to_json(row)))
			    from (
				select "errorCode", "errorMessage", "errorColumn", "errorType", "successFlag" 
				from tmp_errorlistjson
			    ) row);
		
		op_outputjson := op_outputjson || ((select row_to_json(row) from (
			select inventory."invDate", inventory."invTime", inventory."invRegion", inventory."invCountry", inventory."invSite",inventory."invSiteRef", inventory."invSiteId2", inventory."invCustomer", inventory."invOem", inventory."invMaterial", inventory."invOnHand", inventory."invOnOrder", inventory."invDefective", inventory."invBlocked", inventory."invWeeklyExpectedUsage", inventory."invMaterialDesc", 
            inventory."invExtra1", inventory."invExtra2",inventory."invFeedback", inventory."invModel",inventory."invApc", inventory."invBuybackScrap", inventory."invInventoryClassification", inventory."partName", inventory."partType", inventory."serialzed", inventory."serial", inventory."comment", now(), inventory."createdBy", inventory."createdFrom", inventory."createdFromId",
             errorList as "errorList", inventory."insertedIntoDb"
				-- select inventory."invSite" ,inventory."invOem",inventory."invCustomer" ,inventory."invMaterial" ,errorList as "errorList", inventory."insertedIntoDb"
				) row) || ',');
		
	END LOOP;
	--RAISE NOTICE '%', op_outputjson;
	return trim(trailing ',' from op_outputjson);
End
$function$
