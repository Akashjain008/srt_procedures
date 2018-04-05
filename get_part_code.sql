CREATE OR REPLACE FUNCTION public.get_part_code(oemid integer)
 RETURNS TABLE(id integer, "invMaterial" text, "partName" text, "invMaterialDesc" text, "partType" text, oem_id integer, "isActive" boolean, serialized boolean)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY SELECT p.id, p.part_code, p.part_name, p.part_description, p.part_grouping, p.oem_id, p.is_active, p.serialized
	FROM public.mst_part p
	where (
		(p.oem_id = oemid)
	);
    END;
$function$
