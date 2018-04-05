CREATE OR REPLACE FUNCTION public.get_customer()
 RETURNS TABLE(id integer, name text, code text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY select c.id, c.name, c.code, c.is_active from mst_customer c where is_active = TRUE;
    END;
$function$
