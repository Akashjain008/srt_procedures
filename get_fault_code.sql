CREATE OR REPLACE FUNCTION public.get_fault_code(b2xfaultcode text, customerfaultcode text, faultname text, faultdesc text, isactive boolean)
 RETURNS TABLE("faultCodeId" integer, "faultName" text, "b2xFaultCode" text, "customerFaultCode" text, "faultDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (b2xfaultcode = 'null' AND customerfaultcode = 'null' AND faultname = 'null' AND faultdesc = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, fault_name, b2x_fault_code, customer_fault_code, fault_description, is_active, created_on, updated_on
			FROM public.mst_fault_code
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, fault_name, b2x_fault_code, customer_fault_code, fault_description, is_active, created_on, updated_on
			FROM public.mst_fault_code
			WHERE (
				(LOWER(fault_name) = LOWER(faultname) OR faultname = 'null') AND
				(LOWER(b2x_fault_code) = LOWER(b2xfaultcode) OR b2xfaultcode = 'null') AND
				(LOWER(customer_fault_code) = LOWER(customerfaultcode) OR customerfaultcode = 'null') AND
				(LOWER(fault_description) = LOWER(faultdesc) OR faultdesc = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
