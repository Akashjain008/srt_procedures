CREATE OR REPLACE FUNCTION public.get_action_code(b2xactioncode text, actionname text, actiongroup text, actiondesc text, custactioncode text, isactive boolean)
 RETURNS TABLE("actionId" integer, "actionName" text, "b2xActionCode" text, "actionGroup" text, "actionDesc" text, "custActionCode" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (b2xactioncode = 'null' AND actionname = 'null' AND actiondesc = 'null' AND actiongroup = 'null' AND custactioncode = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, action_name, b2x_action_code, action_group, action_description, customer_action_code, is_active, created_on, updated_on
			FROM public.mst_action_code
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, action_name, b2x_action_code, action_group, action_description, customer_action_code, is_active, created_on, updated_on
			FROM public.mst_action_code
			WHERE (
				(LOWER(action_name) = LOWER(actionname) OR actionname = 'null') AND
				(LOWER(b2x_action_code) = LOWER(b2xactioncode) OR b2xactioncode = 'null') AND
				(LOWER(action_group) = LOWER(actiongroup) OR actiongroup = 'null') AND
				(LOWER(action_description) = LOWER(actiondesc) OR actiondesc = 'null') AND
				(LOWER(customer_action_code) = LOWER(custactioncode) OR custactioncode = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
