CREATE OR REPLACE FUNCTION public.update_job_quotation(jobnumber text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
jobId integer;
result text;
BEGIN
	-- get job id
	jobId := (select id from job_head_new where b2x_job_number = jobNumber);
	-- inactive old records
	UPDATE public.job_quotation SET is_active = false WHERE job_id = jobId and is_active = true;
	-- insert new records
	INSERT INTO public.job_quotation(job_id, problem_found_code, amount, tax, is_active, created_on,currency)
	select distinct jh.id, jpf.primary_code, coalesce(map.b2x_cost, 0), coalesce(map.b2x_tax, 0), true, now(),map.currency
	from job_head_new jh
	join job_problem_found jpf on jpf.job_id = jh.id and jpf.is_active = true and jpf.flag = 1
	join tr_consumer tc on jh.consumer_id::integer = tc.id
	join mst_problem_found mpf on jpf.primary_code = mpf.b2x_code and mpf.is_active = true
	left join map_rsp_country_problem_cost map on (map.category = coalesce(mpf.problem_code_type, 'Others')) 
	and map.model_code = jh.product_code_in and map.country_iso_code = tc.country
	where jh.id = jobId;
	
-- 	SELECT jobId, jpf.primary_code, coalesce(mapc.b2x_cost, 0), coalesce(mapc.b2x_tax, 0), true, now(),mapc.currency
-- 	from job_head_new jh
-- 	join mst_rsp rsp on jh.partner_id = rsp.rsp_id
-- 	join job_problem_found jpf on jh.id = jpf.job_id
-- 	left join map_rsp_country_problem_cost mapc on jpf.primary_code = mapc.problem_found_code and mapc.country_iso_code = rsp.rsp_iso_code
-- 	where jh.id = jobId and jpf.is_active = true and jpf.flag = 1;
 	return 'done';
END;
$function$
