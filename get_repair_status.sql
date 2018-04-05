CREATE OR REPLACE FUNCTION public.get_repair_status()
 RETURNS TABLE(id integer, "b2xCode" text, "customerCode" text, "statusName" text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT  mrs.id, mrs.b2x_code, mrs.customer_code, mrs.status_name, mrs.is_active FROM mst_repair_status mrs where mrs.is_active = TRUE;
    END;
$function$
