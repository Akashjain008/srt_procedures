CREATE OR REPLACE FUNCTION public.check_in_routing_table(tablename text, columnname text, checkvalues text[])
 RETURNS TABLE("isValid" integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
valueCount text;
dbCount int4;
inValues text[];
runQuery text;
BEGIN

	raise notice '%', checkValues;
	drop table if exists tmp_is_in_routing;	
	create temp table tmp_is_in_routing(b2x_code text);
	insert into tmp_is_in_routing(b2x_code)
	select unnest(checkValues);
	
	valueCount := (select count(distinct b2x_code) from tmp_is_in_routing);
	
	runQuery := format('select count(distinct %s) from %s where is_active = TRUE AND lower(%s::text) IN (select lower(b2x_code) from tmp_is_in_routing) ',columnName, tableName, columnName);
	raise notice '%', runQuery;
			
	execute runQuery into dbCount; 
	
	raise notice 'dbcount: %, inpCount: %', dbCount, valueCount;
	if(dbCount =  valueCount) then
		RETURN QUERY select 1;
	else
		RETURN QUERY select 0;
	end if;
END;
$function$
