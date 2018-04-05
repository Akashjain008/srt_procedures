CREATE OR REPLACE FUNCTION public.get_country()
 RETURNS TABLE(id integer, name text, "isoCode" text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY select c.id, c.iso_code||' - '||c.name, c.iso_code, c.is_active from mst_country c where is_active = TRUE;
    END;
$function$
