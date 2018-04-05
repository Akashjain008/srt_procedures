CREATE OR REPLACE FUNCTION public.get_sku(modelcode text, modelname text, modeldesc text, skucode text, oemid integer, isactive boolean)
 RETURNS TABLE("skuId" integer, "modelCode" text, "modelName" text, "modelDesc" text, "skuCode" text, "oemId" integer, "oemName" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (modelcode = 'null' AND modelname = 'null' AND modeldesc = 'null' AND skucode = 'null' AND oemid is null AND isActive is null) THEN
	
		RETURN QUERY SELECT s.id, s.model_code, s.model_name, s.model_description, s.sku_code, s.oem_id, o.oem_name, s.is_active, s.created_on, s.updated_on
			FROM public.mst_sku s
			left join mst_oem o on o.id = s.oem_id
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT s.id, s.model_code, s.model_name, s.model_description, s.sku_code, s.oem_id, o.oem_name, s.is_active, s.created_on, s.updated_on
			FROM public.mst_sku s
			left join mst_oem o on o.id = s.oem_id
			WHERE (
				(LOWER(s.model_code) = LOWER(modelcode) OR modelcode = 'null') AND
				(LOWER(s.model_name) = LOWER(modelname) OR modelname = 'null') AND
				(LOWER(s.model_description) = LOWER(modeldesc) OR modeldesc = 'null') AND
				(LOWER(s.sku_code) = LOWER(skucode) OR skucode = 'null') AND
				(s.oem_id = oemid OR oemid IS NULL) AND
				(s.is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
