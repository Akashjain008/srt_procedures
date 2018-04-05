CREATE OR REPLACE FUNCTION public.get_rsp_data(rspid text, rspname text, city text, state text, pincode text, isocode text, isactive boolean)
 RETURNS TABLE(id integer, "rspId" text, "rspName" text, "rspAddress" text, "rspEmail" text, "rspContactPName" text, "rspContactPPhone" text, "rspContactPEmail" text, "rspCity" text, "rspState" text, "isoCode" text, "rspCountry" text, "rspPincode" text, "rspPhone" text, "rspBcc" text, "isActive" boolean, "createdOn" timestamp with time zone, "updatedOn" timestamp with time zone)
 LANGUAGE plpgsql
AS $function$

    BEGIN
	return query SELECT mr.id, mr.rsp_id, mr.rsp_name, mr.rsp_address, mr.rsp_email, mr.rsp_contact_person_name, 
			       mr.rsp_contact_person_phone_number, mr.rsp_contact_person_email, mr.rsp_city, 
			       mr.rsp_state, mr.rsp_iso_code, mc.iso_code||' - '||mc.name, mr.rsp_pincode, mr.rsp_phone_number, mr.rsp_bcc, mr.is_active, 
			       mr.created_on, mr.updated_on
			  FROM public.mst_rsp mr
			  LEFT JOIN mst_country mc on mc.iso_code = mr.rsp_iso_code
			  
	
			WHERE (
				(LOWER(mr.rsp_id) = LOWER(rspid) OR rspid IS NULL OR rspid = 'null' OR rspid = '') AND
				(LOWER(mr.rsp_name) = LOWER(rspname) OR rspname IS NULL OR rspname = 'null'OR rspname = '') AND
				(LOWER(mr.rsp_city) = LOWER(city) OR city IS NULL OR city = 'null' OR city = '') AND
				(LOWER(mr.rsp_state) = LOWER(state) OR state IS NULL OR state = 'null' OR state = '') AND
				(LOWER(mr.rsp_pincode) = LOWER(pincode) OR pincode IS NULL OR pincode = 'null' OR pincode = '') AND
				(LOWER(mr.rsp_iso_code) = LOWER(isocode) OR isocode IS NULL OR isocode = 'null' OR isocode = '') AND
				(mr.is_active = isactive OR isactive IS NULL)
			      )ORDER BY id;
			
 	
    END;
$function$
