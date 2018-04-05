CREATE OR REPLACE FUNCTION public.search_country(code text, cname text, isactive boolean)
 RETURNS TABLE(cid integer, "countryIsoCode" text, "countryName" text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$

    BEGIN
	return query SELECT mc.id, mc.iso_code, mc.name, mc.is_active
			  FROM public.mst_country mc
	
			WHERE (
				(LOWER(mc.iso_code) = LOWER(code) OR code IS NULL OR code = 'null' OR code = '') AND
				(LOWER(mc.name) = LOWER(cname) OR cname IS NULL OR cname = 'null'OR cname = '') AND
				(mc.is_active = isactive OR isactive IS NULL)
			      )ORDER BY id;
			
 	
    END;
$function$
