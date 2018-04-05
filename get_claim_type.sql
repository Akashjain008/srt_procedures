CREATE OR REPLACE FUNCTION public.get_claim_type(claimcode text, claimname text, claimdesc text, isactive boolean)
 RETURNS TABLE("claimId" integer, "claimCode" text, "claimName" text, "claimDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
BEGIN
	IF (claimcode = 'null' AND claimname = 'null' AND claimdesc = 'null' AND isActive is null) THEN
	
		RETURN QUERY SELECT id, claim_code, claim_name, claim_description, is_active, created_on, updated_on
			FROM public.mst_claim_type
			ORDER BY id;
	ELSE 
		RETURN QUERY SELECT id, claim_code, claim_name, claim_description, is_active, created_on, updated_on
			FROM public.mst_claim_type
			WHERE (
				(LOWER(claim_code) = LOWER(claimcode) OR claimcode = 'null') AND
				(LOWER(claim_name) = LOWER(claimname) OR claimname = 'null') AND
				(LOWER(claim_description) = LOWER(claimdesc) OR claimdesc = 'null') AND
				(is_active = isActive OR isActive IS NULL)
			)
			ORDER BY id;
	END IF;
	
END;
$function$
