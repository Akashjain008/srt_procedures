CREATE OR REPLACE FUNCTION public.insert_second_status(status_id integer, repairstatus text, b2xcode text, customercode text, statusname text, statusdescription text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_second_status where LOWER(b2x_code) = LOWER(b2xcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Second Status is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_second_status(status_name, b2x_code, customer_code, status_description, repair_status, is_active,
				created_on, created_by)
			VALUES( statusname, b2xcode, customercode, statusdescription, repairstatus, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Second Status Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND status_id is not null) then
			update_count:= (select count(1) from mst_second_status where LOWER(b2x_code) = LOWER(b2xcode) AND id != status_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Second Status is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_second_status
				   SET b2x_code=b2xcode, customer_code=customercode, status_name=statusname, repair_status=repairstatus, status_description=statusdescription,
					is_active=isactive, updated_on=now(), updated_by=userid
				 WHERE id = status_id;
				return '{ "status": "pass", "message": "Second Status Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id",  "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
