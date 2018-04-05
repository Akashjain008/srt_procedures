CREATE OR REPLACE FUNCTION public.search_language(lcode text, lname text, isactive boolean)
 RETURNS TABLE(lid integer, code text, name text, "isActive" boolean)
 LANGUAGE plpgsql
AS $function$

    BEGIN
	return query SELECT ml.id, ml.code, ml.name, ml.is_active
			  FROM public.mst_language ml
	
			WHERE (
				(LOWER(ml.code) = LOWER(lcode) OR lcode IS NULL OR lcode = 'null' OR lcode = '') AND
				(LOWER(ml.name) = LOWER(lname) OR lname IS NULL OR lname = 'null'OR lname = '') AND
				(ml.is_active = isactive OR isactive IS NULL)
			      )ORDER BY id;
			
 	
    END;
$function$
