CREATE OR REPLACE FUNCTION public.get_problem_found(b2xcode text, customercode text, problemdesc text, isactive boolean)
 RETURNS TABLE("problemId" integer, "b2xCode" text, "customerCode" text, "problemDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (b2xcode = 'null' AND customercode = 'null' AND problemdesc = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, b2x_code, customer_code, problem_description, is_active, created_on, updated_on
			FROM public.mst_problem_found
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, b2x_code, customer_code, problem_description, is_active, created_on, updated_on
			FROM public.mst_problem_found
			WHERE (
				(LOWER(b2x_code) = LOWER(b2xcode) OR b2xcode = 'null') AND
				(LOWER(customer_code) = LOWER(customercode) OR customercode = 'null') AND
				(LOWER(problem_description) = LOWER(problemdesc) OR problemdesc = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
