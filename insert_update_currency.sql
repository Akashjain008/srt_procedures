CREATE OR REPLACE FUNCTION public.insert_update_currency(cid integer, ccode text, cname text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
count1 integer;
    BEGIN
	count:= (select count(1) from mst_currency where LOWER(code) = LOWER(ccode) or LOWER(currency) = LOWER(cname));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Currency is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_currency(code, currency, is_active, created_on, created_by)
			VALUES(ccode, cname, isactive, now(), userid);
			return '{ "status": "pass", "message": "Currency Inserted successfully.", "errorCode": "COM001" }';
			
		elseif (flag = 'u' AND cid is not null) then
			count1:= (select count(1) from mst_currency where (LOWER(code) = LOWER(ccode) 
			or LOWER(currency) = LOWER(cname)) and id != cid);
			IF (count1 > 0) THEN
				return '{ "status": "fail", "message": "Currency is Already Present.", "errorCode": "COM004" }';
			ELSE
					UPDATE public.mst_currency
					   SET code = ccode, currency = cname, is_active = isactive, 
					   	   updated_on = now(), updated_by = userid
					 WHERE id = cid;
				return '{ "status": "pass", "message": "Currency Updated successfully.", "errorCode": "COM002" }';
			end if;	
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
