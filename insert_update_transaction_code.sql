CREATE OR REPLACE FUNCTION public.insert_update_transaction_code(transactionid integer, b2xcode integer, b2xdesc text, customercode text, customerdesc text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
update_count integer;
    BEGIN
	count:= (select count(1) from mst_transaction_code where b2x_transaction_code = b2xcode OR LOWER(cust_transaction_code) = LOWER(customercode) OR LOWER(b2x_transaction_description) = LOWER(b2xdesc));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "B2X Action Code or Customer code or B2X transaction code is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_transaction_code(cust_transaction_code, cust_transaction_description, is_active, created_on, 				b2x_transaction_code, b2x_transaction_description, created_by)
			VALUES( customercode, customerdesc, isactive, now(), b2xcode, b2xdesc, userid);
			
			return '{ "status": "pass", "message": "Transaction Code Inserted successfully.", "errorCode": "COM001" }';
		elseif (flag = 'u' AND b2xcode is not null) then
			update_count:= (select count(1) from mst_transaction_code where (b2x_transaction_code = b2xcode OR 
				LOWER(cust_transaction_code) = LOWER(customercode) OR LOWER(b2x_transaction_description) = LOWER(b2xdesc)) 
				AND id != transactionid);
			IF (update_count > 0) THEN
				return '{ "status": "fail", "message": "B2X Transaction Code or Customer code or B2X description is Already Present.", 	"errorCode": "COM004" }';
			ELSE
				UPDATE public.mst_transaction_code
				   SET cust_transaction_code=customercode, cust_transaction_description=customerdesc, is_active=isactive, 					b2x_transaction_code=b2xcode, b2x_transaction_description=b2xdesc, updated_on=now(), updated_by=userid
				 WHERE id = transactionid;
				return '{ "status": "pass", "message": "B2X Transaction Code Updated successfully.", "errorCode": "COM002" }';
			END IF;
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
