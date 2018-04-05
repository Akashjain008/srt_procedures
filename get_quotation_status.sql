CREATE OR REPLACE FUNCTION public.get_quotation_status(rsp_id text[])
 RETURNS json
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN (select array_to_json(array_agg(row_to_json(row)))from(
	
		select
		h.b2x_job_number as "b2xJobNumber",
		--h.repair_status,
		--h.second_repair_status,
		d.quotation_amount as "quotationAmount",
		d.quotation_currency as "quotationCurrency",
		case when (h.repair_status = '15') then 'Approved' 
		when (h.repair_status = '50' and h.second_repair_status = 55) then 'Pending' 
		when (h.repair_status = '100' and h.second_repair_status = 103) then 'Rejected'
		end as "status",
		(select array_to_string(ARRAY(select primary_code::text from job_problem_found where job_id = h.id and is_active= true), ', ')) as "problemFoundCode"
		from job_head_new h
		join job_detail_new d on d.id = h.job_detail_id
		where h.repair_status != '90' 
		and (h.repair_status = '15' or (h.repair_status = '50' and h.second_repair_status = 55) or (h.repair_status = '100' and h.second_repair_status = 103))
		and (h.partner_id in (select unnest(ARRAY[rsp_id])) or rsp_id is null)
		order by h.id asc
		
--		h.b2x_job_number IN (
--			select
--			distinct h.b2x_job_number
--			from job_head_new h
--			join job_detail_new d on h.id = d.job_id and d.repair_status::integer = 50 and d.second_repair_status::integer = 55 --and d.quotation_amount > 0
--			where h.repair_status != '90'
--			--and h.created_on::date >= '2017-12-11' --(CURRENT_DATE - INTERVAL '1 day')
--			and (h.partner_id in (select unnest(ARRAY[rsp_id])) or rsp_id is null) 
--			order by h.b2x_job_number
--		)
		
	)row
	);
    END;
$function$
