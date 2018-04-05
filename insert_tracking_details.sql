CREATE OR REPLACE FUNCTION public.insert_tracking_details(jobid integer, jobnumber text DEFAULT NULL::text, inputname text DEFAULT NULL::text, trackingnumber text DEFAULT NULL::text, trackingstatusdate timestamp with time zone DEFAULT NULL::timestamp with time zone, trackingstatuscode text DEFAULT NULL::text, trackingstatusdescription text DEFAULT NULL::text, dateofpickup timestamp with time zone DEFAULT NULL::timestamp with time zone, dateofdelivery timestamp with time zone DEFAULT NULL::timestamp with time zone, statuscode text DEFAULT NULL::text, geterror text DEFAULT NULL::text, getmessage text DEFAULT NULL::text, getstatus text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
Declare getstatusflag boolean;
sendstatus text DEFAULT NULL::text;
trackingid integer;
BEGIN	
	
	-- raise notice '%',(select id from job_tracking_details where lower(input_name) = lower(inputname) and 
-- 		lower(tracking_number) = lower(trackingnumber) and (error::text = geterror::text or error::text is null) and 
-- 		job_id =jobid order by id desc limit 1);
	if not exists(select id from job_tracking_details where lower(input_name) = lower(inputname) and 
		lower(tracking_number) = lower(trackingnumber) and (error::text = geterror::text or error::text is null) and 
		job_id =jobid order by id desc limit 1) then

		if (geterror is null and dateofpickup is null and dateofdelivery is null) then
 			sendstatus := 'Awaiting Pickup';
 			getstatusflag := false;
 		elseif (geterror is null  and dateofpickup is not null and dateofdelivery is null) then
 			sendstatus := 'In transit';
 			getstatusflag := false;
 		elseif (geterror is null and dateofdelivery is not null) then
 			sendstatus := 'Delivered/Complete';
 			getstatusflag := true;
 		else
			sendstatus := null;
			getstatusflag := false;
		end if;
	
		INSERT INTO public.job_tracking_details(job_id, input_name, tracking_number, tracking_status_date,
				tracking_status_code, tracking_status_description, date_of_pickup, date_of_delivery,
				status_code, error, message, status, status_flag, is_active, created_on,latest_update)
			VALUES (jobid, inputname, trackingnumber, trackingstatusdate,
				trackingstatuscode, trackingstatusdescription, dateofpickup, dateofdelivery,
				statuscode, geterror, getmessage, sendstatus, getstatusflag, true, now(), true);

	else

		trackingid := (select id from job_tracking_details where lower(input_name) = lower(inputname) and 
		lower(tracking_number) = lower(trackingnumber) and (error::text = geterror::text or error::text is null) and 
		job_id =jobid order by id desc limit 1);
		
		update job_tracking_details set latest_update = false where id = trackingid;
	
	end if;

	return '{"status": "pass", "message": "successfully insert"}';

END;
$function$
