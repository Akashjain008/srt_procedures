CREATE OR REPLACE FUNCTION public.get_part_master()
 RETURNS TABLE("partGrouping" text)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT DISTINCT(part_grouping) FROM public.mst_part where is_active = TRUE;
    END;
$function$
