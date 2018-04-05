CREATE OR REPLACE FUNCTION public.get_rule_master(rulecode text, errortype text, eventtype text, columnname text, isactive boolean)
 RETURNS TABLE("ruleId" integer, "ruleCode" text, name text, description text, "errorType" text, "eventType" text, "columnName" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone, "isMandatory" boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (ruleCode = 'null' AND errorType = 'null' AND eventType = 'null' AND columnName= 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT r.id, r.code, r."name", r.description, r."type", r.event_type , r.column_name, r.is_active, r.created_on, r.updated_on, r.mandatory
			FROM tr_rule r
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT r.id, r.code, r."name", r.description, r."type", r.event_type , r.column_name, r.is_active, r.created_on, r.updated_on, r.mandatory
			FROM tr_rule r
			WHERE (
				(LOWER(r.code) = LOWER(ruleCode) OR ruleCode = 'null') AND
				(LOWER(r."type") = LOWER(errorType) OR errorType = 'null') AND
				(LOWER(r.event_type) = LOWER(eventType) OR eventType = 'null') AND
				(LOWER(r.column_name) = LOWER(columnName) OR columnName = 'null') AND
				(r.is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
