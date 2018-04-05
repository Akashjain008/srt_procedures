CREATE OR REPLACE FUNCTION public.update_job_status(jobnumber text, status boolean)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	if (jobNumber is not null) then
		IF NOT EXISTS (SELECT 1 FROM job_head_new WHERE b2x_job_number = jobNumber) THEN
			return '{ "status": "fail", "error": "jobNumber is not valid"}';
		ELSE		
			UPDATE public.job_head_new
			   SET is_active=status
			   WHERE b2x_job_number = jobNumber;
			return '{ "status": "pass", "message": "Job status updated successfully."}';
		END IF;
	else
		return '{ "status": "fail", "message": "jobNumber is missing from input"}';
	end if;
	
    END;
$function$
