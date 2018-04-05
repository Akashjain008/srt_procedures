CREATE OR REPLACE FUNCTION public.update_casenumber(jobnumber text, casenumber text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE 
jobid integer;
result text;
Begin

	if (jobnumber is not null) then

		jobid := (select id from job_head_new where lower(b2x_job_number) = lower(jobnumber) limit 1);

	else	

		jobid := 0;
		
	End if;

	if (jobid > 0) then
	
		update job_head_new set partner_job_number = casenumber where id = jobid;

		result:= '{"code" : "200", "message": "Case number successfully updated"}';	
		
	else

		result:= '{"error": "code" : "200", "message": "No job number and imei details found in system"}';

	End if;

	RAISE NOTICE 'result=====: %', result;

	return result;
End	
$function$
