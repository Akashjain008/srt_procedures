CREATE OR REPLACE FUNCTION public.get_job_repair_history(jobnumber text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE result text;
jobid integer;
BEGIN
	-- result := ARRAY(SELECT row_to_json(r) 
-- 	FROM(select job_id, repair_status, second_repair_status,mst_repair_status.status_name status, repair_description, job_detail_new.created_on from 		job_detail_new 
-- 		left join mst_repair_status on mst_repair_status.b2x_code = job_detail_new.repair_status
-- 		where job_id=85
-- 	)r);
	if (jobnumber is not null and jobnumber != 'null') then
		jobid := (select id from job_head_new where lower(b2x_job_number) = lower(jobnumber) limit 1);
		if (jobid > 0) then
			result := (SELECT array_to_json(array_agg(row)) FROM (

				select distinct on (jdn.repair_status) jdn.repair_status as "repairStatus", 
				coalesce("jdn"."created_on", null) as "createdOn", 
				coalesce("rs"."status_name", null) as "statusName", 
				coalesce("jdn"."second_repair_status", null) as "secondRepairStatus", 
				coalesce("jdn"."file_name", null) as "fileName", 
				coalesce("jdn"."custom_1", null) as "custom_1",
				coalesce("jdn"."custom_2", null) as "custom_2",
				coalesce("jdn"."custom_3", null) as "custom_3",
				coalesce("jdn"."custom_4", null) as "custom_4",
				coalesce("jdn"."custom_5", null) as "custom_5",
				coalesce("jdn"."custom_6", null) as "custom_6",
				coalesce("jdn"."custom_7", null) as "custom_7",
				coalesce("jdn"."custom_8", null) as "custom_8",
				coalesce("jdn"."custom_9", null) as "custom_9",
				coalesce("jdn"."custom_10", null) as "custom_10"
				from job_detail_new as jdn
				left join mst_repair_status as rs ON rs.b2x_code = jdn.repair_status
	-- 			left join job_head_new as jhn ON jhn.id = jdn.job_id
				where job_id=jobid
				order by jdn.repair_status, jdn.created_on desc

			)row);
		else

		result:= '{"error" : { "code" : "200", "message": "No job details found in system" } }';
		
		End if;
	else

		result:= '{"error" : { "code" : "200", "message": "Invalid job number" } }';

	End if;



 	return result ;
END;
$function$
