CREATE OR REPLACE FUNCTION public.get_all_quotation()
 RETURNS json
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN (select array_to_json(array_agg(row_to_json(row)))from(
	
				select jh."b2x_job_number" as "Claim ID",
				case when (jh.repair_status = '15') then 'Y' 
				when (jh.repair_status = '50' and jh.second_repair_status = 55) then 'N' 
				when (jh.repair_status = '100' and jh.second_repair_status = 103) then 'N' 
				end as "Quotation Status Code"
				--,sum(coalesce(map.b2x_cost, 0) + coalesce(map.b2x_tax, 0)) as "Quotation Amount"
				--, 'BRL' as "Quotation Currency"
				,jh.partner_id as "Repair Service Partner ID"--,coalesce(map.currency,'BRL')
				from job_head_new jh
				join job_problem_found jpf on jpf.job_id = jh.id and jpf.is_active = true and jpf.flag = 1
				join tr_consumer tc on jh.consumer_id::integer = tc.id
				join mst_problem_found mpf on jpf.primary_code = mpf.b2x_code and mpf.is_active = true
				left join map_rsp_country_problem_cost map on (map.category = coalesce(mpf.problem_code_type, 'Others')) 
				and map.model_code = jh.product_code_in and map.country_iso_code = tc.country
				where jh.repair_status != '90' 
				and (jh.repair_status ='15' or (jh.repair_status = '50' and jh.second_repair_status = 55) or (jh.repair_status = '100' and jh.second_repair_status = 103))  
				and jh.updated_on::date = (TIMESTAMP 'yesterday')::date --now()::date
				group by jh.id,jh."b2x_job_number", jh.quotation_status_code, jh.partner_id,map.currency
				order by jh.id asc
				
			)row
	);
    END;
$function$
