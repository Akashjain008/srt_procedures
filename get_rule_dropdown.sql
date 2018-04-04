CREATE OR REPLACE FUNCTION public.get_rule_dropdown1(OUT "errorTypeData" json[], OUT "eventTypeData" json[])
 RETURNS record
 LANGUAGE plpgsql
AS $function$

begin
	"errorTypeData":= array(SELECT row_to_json(r) 
				FROM(SELECT distinct rr.type as "errorType1" FROM tr_rule rr where rr.type is not null or rr.type != 'null' )r);
				
    "eventTypeData":= array(SELECT row_to_json(r) 
				FROM(SELECT DISTINCT event_type as "eventType" FROM tr_rule  where event_type is not null or event_type != 'null')r);

	end;			

$function$
