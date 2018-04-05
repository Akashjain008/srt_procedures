CREATE OR REPLACE FUNCTION public.get_repair_status_code(b2xcode text, customercode text, statusname text, statusorder text, statusdesc text, isactive boolean)
 RETURNS TABLE("statusId" integer, "b2xCode" text, "customerCode" text, "statusName" text, "statusOrder" text, "statusDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	
	IF (b2xcode = 'null' AND customercode = 'null' AND statusname = 'null' AND statusorder = 'null' AND statusdesc = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, b2x_code, customer_code, status_name as "statusName", status_order as "statusOrder", status_description as "statusDesc", 
			is_active as "isActive", created_on as "createdOn", updated_on as "updatedOn" FROM public.mst_repair_status
			ORDER BY id;
	ELSE 
	
		RETURN QUERY SELECT id, b2x_code, customer_code, status_name as "statusName", status_order as "statusOrder", status_description as "statusDesc", 
			is_active as "isActive", created_on as "createdOn", updated_on as "updatedOn" FROM public.mst_repair_status
			WHERE (
				(LOWER(b2x_code) = LOWER(b2xcode) OR b2xcode = 'null') AND
				(LOWER(customer_code) = LOWER(customercode) OR customercode = 'null') AND
				(LOWER(status_name) = LOWER(statusname) OR statusname = 'null') AND
				(LOWER(status_order) = LOWER(statusorder) OR statusorder = 'null') AND
				(LOWER(status_description) = LOWER(statusdesc) OR statusdesc = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
END;
$function$
