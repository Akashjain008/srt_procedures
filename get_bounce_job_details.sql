CREATE OR REPLACE FUNCTION public.get_bounce_job_details(imeinumber text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
jobid integer;
bouncejobdata text;
problemfounddata text;
result text;
Begin

	if (imeinumber is not null) then

		jobid := (select id from job_head_new where imei_number_in = imeinumber and repair_status = '90' order by id desc limit 1);
		
	else

		jobid := 0;
		
	End if;

	if (jobid > 0) then
	
		bouncejobdata:= (SELECT array_to_json(array_agg(row)) FROM (
			
			select jh.id, jh.b2x_job_number, jh.imei_number_in
			from job_head_new jh
			where (completion_Date between (now()::date - 30) and (now()::date))
			and repair_status = '90' and jh.id = jobid order by jh.id desc limit 1

			)row);

		problemfounddata:= (SELECT array_to_json(array_agg(row)) FROM (
			
			-- select pf.primary_code as primarycode 
-- 			from  job_problem_found pf 
-- 			where pf.flag = 1 and pf.is_active = true and pf.job_id = jobid
			select *, cc.primary_code as primarycode 
			from  job_customer_complaint cc
			where cc.flag = 1 and cc.is_active = true and cc.job_id = jobid

			)row);

		result := '{"bouncejobdata":' ||coalesce(bouncejobdata, '[]')||',"problemfounddata":'|| coalesce(problemfounddata, '[]') ||'}';
		return result;
	else

		result:= '{"code" : "200", "message": "No bounce details found in system"}';
		return result;
	End if;
	RAISE NOTICE 'result=====: %', result;
	
End	
$function$
