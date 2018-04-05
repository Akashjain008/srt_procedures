CREATE OR REPLACE FUNCTION public.get_customer_complaint(b2xcode text, customercode text, complaintdesc text, isactive boolean)
 RETURNS TABLE("complaintId" integer, "b2xCode" text, "customerCode" text, "complaintDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (b2xcode = 'null' AND customercode = 'null' AND complaintdesc = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, b2x_code, customer_code, complaint_description, is_active, created_on, updated_on
			FROM public.mst_customer_complaint
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, b2x_code, customer_code, complaint_description, is_active, created_on, updated_on
			FROM public.mst_customer_complaint
			WHERE (
				(LOWER(b2x_code) = LOWER(b2xcode) OR b2xcode = 'null') AND
				(LOWER(customer_code) = LOWER(customercode) OR customercode = 'null') AND
				(LOWER(complaint_description) = LOWER(complaintdesc) OR complaintdesc = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
