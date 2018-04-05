CREATE OR REPLACE FUNCTION public.get_transaction_code(b2xcode integer, b2xdesc text, customercode text, customerdesc text, isactive boolean)
 RETURNS TABLE("transactionId" integer, "b2xCode" integer, "b2xDesc" text, "customerCode" text, "customerDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (b2xcode is null AND b2xdesc = 'null' AND customercode = 'null' AND customerdesc = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, b2x_transaction_code, b2x_transaction_description, cust_transaction_code, cust_transaction_description, is_active, 				created_on, updated_on
			FROM public.mst_transaction_code
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, b2x_transaction_code, b2x_transaction_description, cust_transaction_code, cust_transaction_description, is_active, 				created_on, updated_on
			FROM public.mst_transaction_code
			WHERE (
				(b2x_transaction_code) = b2xcode OR b2xcode is null AND
				(LOWER(b2x_transaction_description) = LOWER(b2xdesc) OR b2xdesc = 'null') AND
				(LOWER(cust_transaction_code) = LOWER(customercode) OR customercode = 'null') AND
				(LOWER(cust_transaction_description) = LOWER(customerdesc) OR customerdesc = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
