CREATE OR REPLACE FUNCTION public.insert_update_fault_code(fault_id integer, b2xfaultcode text, customerfaultcode text, faultname text, faultdescription text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_fault_code where LOWER(b2x_fault_code) = LOWER(b2xfaultcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Fault Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then	
			INSERT INTO public.mst_fault_code(fault_name, b2x_fault_code, customer_fault_code, fault_description, is_active, created_on, created_by)
			VALUES( faultname, b2xfaultcode, customerfaultcode, faultdescription, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Fault code Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND fault_id is not null) then
			update_count:= (select count(1) from mst_fault_code where LOWER(b2x_fault_code) = LOWER(b2xfaultcode) AND id != fault_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Fault Code is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_fault_code
				   SET fault_name=faultname, b2x_fault_code=b2xfaultcode, customer_fault_code=customerfaultcode, fault_description=faultdescription,is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = fault_id;
				return '{ "status": "pass", "message": "Fault Code Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
