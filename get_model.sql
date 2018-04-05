CREATE OR REPLACE FUNCTION public.get_model(modelcode text, modelname text, modeldesc text, devicetype text, oemid integer, isactive boolean)
 RETURNS TABLE("modelId" integer, "modelCode" text, "modelName" text, "modelDesc" text, "deviceType" text, "oemId" integer, "oemName" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (modelcode = 'null' AND modelname = 'null' AND modeldesc = 'null' AND devicetype = 'null' AND oemid is null AND isActive is null) THEN
	
		RETURN QUERY SELECT m.id, m.model_code, m.model_name, m.model_description, m.device_type, m.oem_id, o.oem_name, m.is_active, m.created_on, m.updated_on
			FROM public.mst_model m
			left join mst_oem o on o.id = m.oem_id
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT m.id, m.model_code, m.model_name, m.model_description, m.device_type, m.oem_id, o.oem_name, m.is_active, m.created_on, m.updated_on
			FROM public.mst_model m
			left join mst_oem o on o.id = m.oem_id
			WHERE (
				(LOWER(m.model_code) = LOWER(modelcode) OR modelcode = 'null') AND
				(LOWER(m.model_name) = LOWER(modelname) OR modelname = 'null') AND
				(LOWER(m.model_description) = LOWER(modeldesc) OR modeldesc = 'null') AND
				(LOWER(m.device_type) = LOWER(devicetype) OR devicetype = 'null') AND
				(m.oem_id = oemid OR oemid IS NULL) AND
				(m.is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
