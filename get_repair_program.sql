CREATE OR REPLACE FUNCTION public.get_repair_program()
 RETURNS TABLE(id integer, name text, code text, description text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY select mrp.id, mrp.code ||' - '||  mrp.name, mrp.code, mrp.description, mrp.is_active from mst_repair_program mrp where mrp.is_active = TRUE;
    END;
$function$
