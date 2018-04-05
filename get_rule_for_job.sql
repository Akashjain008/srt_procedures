CREATE OR REPLACE FUNCTION public.get_rule_for_job(eventtype text)
 RETURNS TABLE(code text, name text, column_name text, column_data_type text, column_data_min_length text, column_data_max_length text, column_format text, db_level boolean, type text, is_active boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
		select 
		r.code,
		r.name,
		r.column_name,
		r.column_data_type,
		r.column_data_min_length, 
		r.column_data_max_length,
		r.column_format,
		r.db_level,
		r.type,
		r.is_active
	from tr_rule r
	where r.is_active = true
	and r.event_type = eventType
	order by r.id asc;
END
$function$
