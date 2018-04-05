CREATE OR REPLACE FUNCTION public.get_logistic_type()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
begin
	return (SELECT array_to_json(array_agg(row)) FROM (
	SELECT distinct lg.logistics_type as "logisticType" FROM mst_logistic_status lg 
	where lg.logistics_type is not null or lg.logistics_type != 'null'
	)row);
end;	
$function$
