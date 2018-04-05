CREATE OR REPLACE FUNCTION public.get_tracking_details()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE 
inBound text;
outBound text;
result text;
Begin

	--================get inbound details============
	inBound:= (SELECT array_to_json(array_agg(row)) FROM (
			select jh.id as job_id, b2x_job_number as job_number, jd.logistic_inbound_courier_name as courier_name, logistic_inbound_awb as awb,
			'inBound' as input_name
			from job_head_new jh
			inner join job_detail_new jd on jh.job_detail_id= jd.id
			where jd.logistic_inbound_courier_name is not null and logistic_inbound_awb is not null and jh.repair_status::integer != 90 --limit 5
		)row) ;

	--================get outBound details============
	outBound:= (SELECT array_to_json(array_agg(row)) FROM (
			select jh.id as job_id, b2x_job_number as job_number, jd.logistic_outbound_courier_name as courier_name,logistic_outbound_awb as awb,
			'outBound' as input_name
			from job_head_new jh
			inner join job_detail_new jd on jh.job_detail_id= jd.id
			where jd.logistic_outbound_courier_name is not null and logistic_outbound_awb is not null and jh.repair_status::integer != 90 --limit 5
		)row) ;
		   
	result:= '{"table1":' ||coalesce(inBound, '[]')||', "table2":'|| coalesce(outBound, '[]') ||'}';

	RAISE NOTICE 'result=====: %', result;
	return result;
	
End
$function$
