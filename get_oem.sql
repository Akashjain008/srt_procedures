CREATE OR REPLACE FUNCTION public.get_oem()
 RETURNS TABLE("oemId" integer, "oemName" text, "oemCode" text)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT id, oem_name, oem_code FROM public.mst_oem WHERE is_active = TRUE;
    END;
$function$
