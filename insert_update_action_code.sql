CREATE OR REPLACE FUNCTION public.insert_update_action_code(action_id integer, b2xactioncode text, custactioncode text, actionname text, actiongroup text, actiondescription text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_action_code where LOWER(b2x_action_code) = LOWER(b2xactioncode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "B2X Action Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_action_code(action_name, b2x_action_code, customer_action_code, action_group, action_description, is_active, created_on, created_by)
			VALUES( actionname, b2xactioncode, custactioncode, actiongroup, actiondescription, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Action Code Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND action_id is not null) then
			update_count:= (select count(1) from mst_action_code where LOWER(b2x_action_code) = LOWER(b2xactioncode) AND id != action_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "B2X Action Code is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_action_code
				   SET action_name=actionname, b2x_action_code=b2xactioncode, customer_action_code=custactioncode, action_group=actiongroup, action_description=actiondescription, is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = action_id;
				return '{ "status": "pass", "message": "B2X Action Code Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
