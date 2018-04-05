CREATE OR REPLACE FUNCTION public.get_rsp()
 RETURNS TABLE(id integer, "rspName" text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT DISTINCT ON (mr.rsp_name) mr.id,mr.rsp_id, mr.rsp_name as "rspName", mr.is_active FROM mst_rsp mr where mr.is_active = TRUE;
    END;
$function$
