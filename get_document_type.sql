CREATE OR REPLACE FUNCTION public.get_document_type(b2xcode text, customercode text, documentname text, isactive boolean)
 RETURNS TABLE("documentId" integer, "b2xCode" text, "customerCode" text, "documentName" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (b2xcode = 'null' AND customercode = 'null' AND documentname = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, b2x_code, customer_code, document_name, is_active, created_on, updated_on
			FROM public.mst_document_type
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, b2x_code, customer_code, document_name, is_active, created_on, updated_on
			FROM public.mst_document_type
			WHERE (
				(LOWER(b2x_code) = LOWER(b2xcode) OR b2xcode = 'null') AND
				(LOWER(customer_code) = LOWER(customercode) OR customercode = 'null') AND
				(LOWER(document_name) = LOWER(documentname) OR documentname = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
