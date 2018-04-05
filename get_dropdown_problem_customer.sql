CREATE OR REPLACE FUNCTION public.get_dropdown_problem_customer(codetype text)
 RETURNS TABLE(id integer, b2x_code text, description text)
 LANGUAGE plpgsql
AS $function$

DECLARE
BEGIN
	
--		RETURN QUERY SELECT P.b2x_code,p.problem_description as description
--				FROM   mst_problem_found p where LOWER(p.problem_code_type) = LOWER(codeType) and p.is_active = true
--				union all
--				SELECT c.b2x_code,c.complaint_description as description
--				FROM   mst_customer_complaint c where LOWER(c.complaint_code_type) = LOWER(codetype) and c.is_active = true;
	
	return QUERY SELECT p.id,p.b2x_code,p.problem_description as description
	FROM   mst_problem_found p where LOWER(p.problem_code_type) = LOWER(codeType) and is_active = true;
END;

$function$
