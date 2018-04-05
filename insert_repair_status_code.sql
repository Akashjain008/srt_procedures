CREATE OR REPLACE FUNCTION public.insert_repair_status_code(rsc_id integer, b2xcode text, customercode text, statusname text, statusorder text, statusdescription text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_repair_status where LOWER(b2x_code) = LOWER(b2xcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "B2X Status Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			insert into public.mst_repair_status
			(b2x_code, customer_code, status_name, status_order, status_description, is_active, created_on, created_by)
			values(b2xcode, customercode, statusname, statusorder, statusdescription, isactive, now(), userid);
			return '{ "status": "pass", "message": "B2X Status Code Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND rsc_id is not null) then
			update_count:= (select count(1) from mst_repair_status where LOWER(b2x_code) = LOWER(b2xcode) AND id != rsc_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "B2X Status Code is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_repair_status
				   SET b2x_code=b2xcode, customer_code=customercode, status_name=statusname, status_order=statusorder, status_description=statusdescription,
					is_active=isactive, updated_on=now(), updated_by=userid
				 WHERE id = rsc_id;
				return '{ "status": "pass", "message": "B2X Status Code Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
