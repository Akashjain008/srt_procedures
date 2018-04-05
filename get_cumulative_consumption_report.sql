CREATE OR REPLACE FUNCTION public.get_cumulative_consumption_report(partid integer, startdate text, enddate text, flag text)
 RETURNS TABLE("partId" integer, "partCodeName" text, "partQty" integer, "createdOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE

BEGIN	
	IF (flag = 'get' AND startdate = 'null' AND enddate = 'null') THEN

		RETURN QUERY SELECT jpc.part_id as "partId", 
			p.part_code||' - '||p.part_name as "partCodeName",
			jpc.part_consumed_qty as "partQty",
			jpc.created_on as "createdOn"
			FROM public.tr_job_part_consumed  jpc
			LEFT JOIN tr_job_head jh ON jh.id = jpc.job_id
			LEFT JOIN mst_part p ON p.id = jpc.part_id
			WHERE (
				(jpc.part_id = partid OR partid is null) AND
				--(jpc.created_on BETWEEN (startdate)::timestamp with time zone AND (enddate)::timestamp with time zone) AND
				(p.is_active = true AND jpc.is_active = true) AND
				(jpc.part_consumed_qty > 0)
			);
	ELSEIF (flag = 'search' AND startdate != 'null' AND enddate != 'null') THEN

		RETURN QUERY SELECT jpc.part_id as "partId", 
			p.part_code||' - '||p.part_name as "partCodeName",
			jpc.part_consumed_qty as "partQty",
			jpc.created_on as "createdOn"
			FROM public.tr_job_part_consumed  jpc
			LEFT JOIN tr_job_head jh ON jh.id = jpc.job_id
			LEFT JOIN mst_part p ON p.id = jpc.part_id
			WHERE (
				(jpc.part_id = partid OR partid is null) AND
				(jpc.created_on BETWEEN (startdate)::timestamp with time zone AND (enddate)::timestamp with time zone + interval '1' day) AND
				(p.is_active = true AND jpc.is_active = true) AND
				(jpc.part_consumed_qty > 0)
			);
		
	END IF;
END;
$function$
