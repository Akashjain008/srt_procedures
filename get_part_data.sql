CREATE OR REPLACE FUNCTION public.get_part_data()
 RETURNS TABLE("partId" integer, "partCodeName" text)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT id, part_code ||' - '|| part_name
	FROM public.mst_part
	where is_active = TRUE;
    END;
$function$
