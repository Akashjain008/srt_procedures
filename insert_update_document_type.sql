CREATE OR REPLACE FUNCTION public.insert_update_document_type(document_id integer, b2xcode text, customercode text, documentname text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_document_type where LOWER(b2x_code) = LOWER(b2xcode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Document Type Code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_document_type(b2x_code, customer_code, document_name, is_active, created_on, created_by)
			VALUES( b2xcode, customercode, documentname, isactive, now(), userid);
			
			return '{ "status": "pass", "message": "Document Type Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND document_id is not null) then
			update_count:= (select count(1) from mst_document_type where LOWER(b2x_code) = LOWER(b2xcode) AND id != document_id);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "Document Type is Already Present.", "errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_document_type
				   SET b2x_code=b2xcode, customer_code=customercode, document_name=documentname, is_active=isactive, 
					updated_on=now(), updated_by=userid
				 WHERE id = document_id;
				return '{ "status": "pass", "message": "Document Type Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
