CREATE OR REPLACE FUNCTION public.get_customer_complaint_codes()
 RETURNS TABLE(id integer, "b2xCode" text, "complaintDescription" text)
 LANGUAGE plpgsql
AS $function$
    BEGIN
	RETURN QUERY select c.id, c.b2x_code, c.complaint_description from mst_customer_complaint c where is_active = TRUE;
    END;
$function$
