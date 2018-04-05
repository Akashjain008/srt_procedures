CREATE OR REPLACE FUNCTION public.get_email_tracking_details()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE 
emailData text;
result text;
Begin

	--================get inbound details============
	emailData:= (SELECT array_to_json(array_agg(row)) FROM (
			select jh.b2x_job_number,jh.imei_number_in, jh.repair_status, jh.second_repair_status, 
			co.country, co.email, co.name, jtd.input_name, jtd.tracking_number, jtd.status
			from job_tracking_details jtd
			inner join job_head_new jh on jtd.job_id = jh.id
			inner join tr_consumer co on jh.consumer_id = co.id::integer
			where jh.repair_status::integer != 90 
			and ((status in ('In transit') and input_name in ('inBound','outBound')) or 
			(status in ('Delivered/Complete') and input_name in ('outBound'))) and latest_update = true
		)row) ;
		   
	result:= '{"table1":' ||coalesce(emailData, '[]')||'}';
-- 	result:= '{"table1":' ||coalesce(emailData, '[]')||', "table2":'|| coalesce(outBound, '[]') ||'}';

	RAISE NOTICE 'result=====: %', result;
	return result;
	
End
$function$
