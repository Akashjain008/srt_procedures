CREATE OR REPLACE FUNCTION public.get_second_status(repairstatus text, b2xcode text, customercode text, statusname text, statusdesc text, isactive boolean)
 RETURNS TABLE("statusId" integer, "statusName" text, "b2xCode" text, "customerCode" text, "statusDesc" text, "repairStatus" text, "repairStatusName" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (b2xcode = 'null' AND customercode = 'null' AND statusname = 'null' AND repairstatus = 'null' AND statusdesc = 'null' AND isactive is null) THEN
	
		RETURN QUERY SELECT mss.id, mss.status_name, mss.b2x_code, mss.customer_code, mss.status_description, mss.repair_status, mrs.status_name, mss.is_active, mss.created_on, mss.updated_on
			FROM public.mst_second_status mss
			left join mst_repair_status mrs on mrs.b2x_code = mss.repair_status
			ORDER BY mss.id;
	ELSE 
		RETURN QUERY SELECT mss.id, mss.status_name, mss.b2x_code, mss.customer_code, mss.status_description, mss.repair_status, mrs.status_name, mss.is_active, mss.created_on, mss.updated_on
			FROM public.mst_second_status mss
			left join mst_repair_status mrs on mrs.b2x_code = mss.repair_status
			WHERE (
				(LOWER(mss.b2x_code) = LOWER(b2xcode) OR b2xcode = 'null') AND
				(LOWER(mss.customer_code) = LOWER(customercode) OR customercode = 'null') AND
				(LOWER(mss.status_name) = LOWER(statusname) OR statusname = 'null') AND
				(LOWER(mss.status_description) = LOWER(statusdesc) OR statusdesc = 'null') AND
				(LOWER(mss.repair_status) = LOWER(repairstatus) OR repairstatus = 'null') AND
				(mss.is_active = isActive OR isActive IS NULL)
			)
			ORDER BY mss.id;
	END IF;
	
END;
$function$
