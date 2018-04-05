CREATE OR REPLACE FUNCTION public.insert_update_customer_complaint(complaint_id integer, b2xcode text, customercode text, complaintdescription text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_customer_complaint where LOWER(b2x_code) = LOWER(b2xcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Customer Complaint B2X Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_customer_complaint(b2x_code, customer_code, complaint_description, is_active, created_on, created_by)
			VALUES( b2xcode, customercode, complaintdescription, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Customer Complaint Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND complaint_id is not null) then
			update_count:= (select count(1) from mst_customer_complaint where LOWER(b2x_code) = LOWER(b2xcode) AND id != complaint_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Customer Complaint Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_customer_complaint
				   SET b2x_code=b2xcode, customer_code=customercode, complaint_description=complaintdescription, is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = complaint_id;
				return '{ "status": "pass", "message": "Customer Complaint Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
