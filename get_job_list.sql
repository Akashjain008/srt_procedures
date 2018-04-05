CREATE OR REPLACE FUNCTION public.get_job_list("repairStatus" text, "secondRepairStatus" text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN (SELECT array_to_json(array_agg(row)) FROM (
	select b2x_job_number, repair_status, second_repair_status::text
	from job_head_new 
	where repair_status::integer = "repairStatus"::integer 
	and (second_repair_status::integer = "secondRepairStatus"::integer or "secondRepairStatus" is null)
	)row);
END
$function$
