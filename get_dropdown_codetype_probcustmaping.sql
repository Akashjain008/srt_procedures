CREATE OR REPLACE FUNCTION public.get_dropdown_codetype_probcustmaping(OUT "codeType" json[], OUT "customerCode" json[])
 RETURNS record
 LANGUAGE plpgsql
AS $function$

begin
	"codeType":= array(SELECT row_to_json(r) 
				FROM(SELECT distinct problem_code_type as "codeType" FROM mst_problem_found  where problem_code_type is not null or problem_code_type != 'null' )r);
				
    "customerCode":= array(SELECT row_to_json(r) 
				FROM(SELECT DISTINCT customer_code as "customerCode" FROM map_problem_found_customer_complaint  where customer_code is not null or customer_code != 'null')r);

	end;			

$function$
