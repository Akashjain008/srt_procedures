CREATE OR REPLACE FUNCTION public.update_part_processed(action_id integer, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	if (flag = 'u' AND action_id is not null) then
		update_count:= (select count(1) from temp_inventory_feed where id = action_id);
		IF (update_count = 0) THEN
			return '{ "status": "fail", "message": "Part id is not Present.", "errorCode": "COM004" }';
		ELSE		
			UPDATE public.temp_inventory_feed
			   SET is_active=isactive, updated_by=userid
			   WHERE id = action_id;
			return '{ "status": "pass", "message": "Part Updated successfully.", "errorCode": "COM002" }';
		END IF;
	else
		return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
	end if;
	
    END;
$function$
