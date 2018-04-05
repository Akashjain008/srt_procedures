CREATE OR REPLACE FUNCTION public.search_currency(ccode text, cname text, isactive boolean)
 RETURNS TABLE(lid integer, code text, name text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$

    BEGIN
	return query SELECT mc.id, mc.code, mc.currency, mc.is_active
			  FROM public.mst_currency mc
	
			WHERE (
				(LOWER(mc.code) = LOWER(ccode) OR ccode IS NULL OR ccode = 'null' OR ccode = '') AND
				(LOWER(mc.currency) = LOWER(cname) OR cname IS NULL OR cname = 'null'OR cname = '') AND
				(mc.is_active = isactive OR isactive IS NULL)
			      )ORDER BY id;
			
 	
    END;
$function$
