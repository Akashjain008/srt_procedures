CREATE OR REPLACE FUNCTION public.get_problem_customer_map("code_Type" text, "customer_Code" text, isactive boolean)
 RETURNS TABLE("mapId" integer, "codeType" text, "codeTypeId" integer, "customerCode" text, description text, b2x_code text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$

DECLARE
BEGIN
	IF ("code_Type" = 'null' AND "customer_Code" = 'null' AND isactive is null) THEN
	
		RETURN QUERY SELECT a.id, a.code_type , a.code_type_id, a.customer_code,b.problem_description,b.b2x_code,a.is_active, a.created_on, a.updated_on
			FROM map_problem_found_customer_complaint a 
			left join mst_problem_found b on a.code_type_id = b.id
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT a.id, a.code_type , a.code_type_id, a.customer_code,b.problem_description,b.b2x_code,a.is_active, a.created_on, a.updated_on
			FROM map_problem_found_customer_complaint a 
			left join mst_problem_found b on a.code_type_id = b.id
			WHERE (
				(LOWER(a.code_type) = LOWER("code_Type") OR "code_Type" = 'null') AND
				(LOWER(a.customer_code) = LOWER("customer_Code") OR "customer_Code" = 'null') AND
				(a.is_active = isactive OR isactive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;

$function$
