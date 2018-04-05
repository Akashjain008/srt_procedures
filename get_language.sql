CREATE OR REPLACE FUNCTION public.get_language()
 RETURNS TABLE(id integer, name text, code text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY select ml.id, ml.code||' - '||ml.name, ml.code, ml.is_active from mst_language ml where is_active = TRUE;
    END;
$function$
