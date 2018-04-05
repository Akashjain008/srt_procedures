CREATE OR REPLACE FUNCTION public.insert_update_logistic_partner(lpid integer, partnername text, partnercode text, partnerdesc text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
count1 integer;
last_id integer;
    BEGIN
	count:= (select count(1) from mst_logistic_partner where LOWER(partner_name) = LOWER(partnername) or LOWER(partner_code) = LOWER(partnercode));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Logistic Partner is Already Present.", "errorCode": "COM004"  }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_logistic_partner(partner_name, partner_code, description, is_active, created_on, created_by)
			VALUES(partnername, partnercode, partnerdesc, isactive, now(), userid);

			return '{ "status": "pass", "message": "Logistic Partner inserted successfully.", "errorCode": "COM001"  }';
			
		elseif (flag = 'u' AND lpid is not null) then
			count1:= (select count(1) from mst_logistic_partner where (LOWER(partner_name) = LOWER(partnername) or LOWER(partner_code) = LOWER(partnercode) or LOWER(description) = LOWER(partnerdesc)) and id != lpid);
			IF (count1 > 0) THEN
				return '{ "status": "fail", "message": "Logistic Partner is Already Present.", "errorCode": "COM004"  }';
			ELSE
				UPDATE public.mst_logistic_partner
				SET partner_name = partnername, partner_code = partnercode, description = partnerdesc, 
					is_active = isactive, updated_on = now(), updated_by = userid
				WHERE id = lpid;
				
				return '{ "status": "pass", "message": "Logistic Partner Updated successfully.", "errorCode": "COM002"  }';
			end if;	
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003"  }';
		end if;	
	END IF; 
	
    END;
$function$
