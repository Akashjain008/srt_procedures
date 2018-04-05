CREATE OR REPLACE FUNCTION public.get_job_part_report(partid integer, jobnumber text)
 RETURNS TABLE("jobNumber" text, "jobCreatedOn" timestamp with time zone, "partId" integer, "partCodeName" text, "partQty" bigint)
 LANGUAGE plpgsql
AS $function$
DECLARE
jobid integer := null;
BEGIN
	
	jobid:= (select id from job_head_new where LOWER(b2x_job_number) = LOWER(jobnumber));

	IF (jobnumber != 'null' AND jobid is not null) THEN
		RETURN QUERY SELECT jh.b2x_job_number, jh.created_on, jpc.material_number_id, p.part_code||' - '||p.part_name, SUM (jpc.quantity_replaced)
			FROM public.job_part_conusmed_new  jpc
			LEFT JOIN job_head_new jh ON jh.id = jpc.job_id
			LEFT JOIN mst_part p ON p.id = jpc.material_number_id
			WHERE (
				(p.is_active = true) AND 
				(jpc.is_active = true) AND
				(jpc.job_id = jobid OR jobid is null) AND
				(jpc.material_number_id = partid or partid is null)	
			) 
			GROUP BY jh.b2x_job_number, jh.created_on, jpc.material_number_id, p.part_code||' - '||p.part_name;
	ELSEIF (jobnumber = 'null' AND jobid is null) THEN
		RETURN QUERY SELECT jh.b2x_job_number, jh.created_on, jpc.material_number_id, p.part_code||' - '||p.part_name, SUM (jpc.quantity_replaced)
			FROM public.job_part_conusmed_new  jpc
			LEFT JOIN job_head_new jh ON jh.id = jpc.job_id
			LEFT JOIN mst_part p ON p.id = jpc.material_number_id
			WHERE (
				(p.is_active = true) AND 
				(jpc.is_active = true) AND
				(jpc.job_id = jobid OR jobid is null) AND
				(jpc.material_number_id = partid or partid is null)	
			) 
			GROUP BY jh.b2x_job_number, jh.created_on, jpc.material_number_id, p.part_code||' - '||p.part_name;
	END IF;
END;
$function$
