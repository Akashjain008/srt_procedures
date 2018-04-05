CREATE OR REPLACE FUNCTION public.get_logistics(logisticscode text, logisticsname text, logisticstype text, logisticsdesc text, isactive boolean)
 RETURNS TABLE("logisticsId" integer, "logisticsCode" text, "logisticsName" text, "logisticsType" text, "logisticsDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (logisticscode = 'null' AND logisticsname = 'null' AND logisticstype = 'null' AND logisticsdesc = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, logistics_code, logistics_name, logistics_type, logistics_description, is_active, created_on, updated_on
			FROM public.mst_logistic_status
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, logistics_code, logistics_name, logistics_type, logistics_description, is_active, created_on, updated_on
			FROM public.mst_logistic_status
			WHERE (
				(LOWER(logistics_code) = LOWER(logisticscode) OR logisticscode = 'null') AND
				(LOWER(logistics_name) = LOWER(logisticsname) OR logisticsname = 'null') AND
				(LOWER(logistics_type) = LOWER(logisticstype) OR logisticstype = 'null') AND
				(LOWER(logistics_description) = LOWER(logisticsdesc) OR logisticsdesc = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
