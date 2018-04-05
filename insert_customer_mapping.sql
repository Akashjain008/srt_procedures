CREATE OR REPLACE FUNCTION public.insert_customer_mapping(customerid integer, countryid integer, currencyid integer, languageid integer, repairprogramid integer, isactive boolean, userid integer, mapid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
count1 integer;
    BEGIN
	count:= (select count(1) from map_customer_country_currency_language_repair_program 
		 where (customer_id = customerid AND country_id = countryid AND language_id = languageid AND repair_program_id = repairprogramid));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Customer Country Language Mapping is Already Present.", "errorCode": "COM004"  }';
	ELSE
		if(flag = 'i') then
			insert into public.map_customer_country_currency_language_repair_program
			(customer_id, country_id, currency_id, language_id, repair_program_id, is_active, created_on, created_by)
			values(customerId,countryId,currencyId,languageId,repairProgramId,isActive, now(), userid);
			return '{ "status": "pass", "message": "Customer Country Language Mapping inserted successfully.", "errorCode": "COM001"  }';
		elseif (flag = 'u' AND mapid IS NOT NULL) then
		
			count1:= (select count(1) from map_customer_country_currency_language_repair_program 
				where (customer_id = customerid AND country_id = countryid AND language_id = languageid AND 
				repair_program_id = repairprogramid) and id != mapid);
			IF (count1 > 0) THEN
				return '{ "status": "fail", "message": "Customer Country Language Mapping is Already Present.", "errorCode": "COM004"  }';
			ELSE
				UPDATE public.map_customer_country_currency_language_repair_program
				   SET customer_id=customerId, country_id=countryId, currency_id=currencyId, language_id=languageId, 
				       repair_program_id=repairProgramId, is_active=isActive, updated_on=now(), updated_by=userid
				 WHERE id = mapid;
				return '{ "status": "pass", "message": "Customer Country Language Mapping Updated successfully.", "errorCode": "COM002"  }';
			END IF; 
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003"  }';
		end if;	
	END IF; 
    END;
$function$
