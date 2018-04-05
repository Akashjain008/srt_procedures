CREATE OR REPLACE FUNCTION public.get_logistic_partner_data(partnername text, partnercode text, partnerdesc text, isactive boolean)
 RETURNS TABLE(id integer, "partnerName" text, "partnerCode" text, "partnerDesc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$

    BEGIN

	IF (partnername is null AND partnercode is null AND partnerdesc is null AND isActive is null) THEN

		RETURN QUERY SELECT lp.id, lp.partner_name, lp.partner_code, lp.description, lp.is_active, lp.created_on, lp.updated_on
			FROM public.mst_logistic_partner lp
			ORDER BY lp.id;
	ELSE 
		RETURN QUERY SELECT lp.id, lp.partner_name, lp.partner_code, lp.description, lp.is_active, lp.created_on, lp.updated_on
			FROM public.mst_logistic_partner lp
			WHERE (
				(LOWER(lp.partner_name) = LOWER(partnername) OR partnername = 'null') AND
				(LOWER(lp.partner_code) = LOWER(partnercode) OR partnercode = 'null') AND
				(LOWER(lp.description) = LOWER(partnerdesc) OR partnerdesc = 'null') AND
				(lp.is_active = isActive OR isActive IS NULL)
			)
			ORDER BY lp.id;
	END IF;	

    END;
$function$
