CREATE OR REPLACE FUNCTION public.insert_update_language(lid integer, langcode text, langname text, isactive boolean, userid integer, flag text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
count integer;
count1 integer;
    BEGIN
	count:= (select count(1) from mst_language where code = langcode or LOWER(name) = LOWER(langname));
	IF (count > 0 AND flag = 'i') THEN
		return '{ "status": "fail", "message": "Language is Already Present.", "errorCode": "COM004" }';
	ELSE
		if(flag = 'i') then
			INSERT INTO public.mst_language(code, "name", is_active, created_on, created_by)
			VALUES(langcode, langname, isactive, now(), userid);
			return '{ "status": "pass", "message": "Language Inserted successfully.", "errorCode": "COM001" }';
			
		elseif (flag = 'u' AND lid is not null) then
			count1:= (select count(1) from mst_language where (LOWER(code) = LOWER(langcode) or LOWER(name) = LOWER(langname)) and id != lid);
			IF (count1 > 0) THEN
				return '{ "status": "fail", "message": "Language is Already Present.", "errorCode": "COM004" }';
			ELSE
					UPDATE public.mst_language
					   SET code = langcode, name = langname, is_active = isactive, 
					   	   updated_on = now(), updated_by = userid
					 WHERE id = lid;
				return '{ "status": "pass", "message": "Language Updated successfully.", "errorCode": "COM002" }';
			end if;	
		else
			return '{ "status": "fail", "message": "Invalid flag input or missing id", "errorCode": "COM003" }';
		end if;	
	END IF; 
	
    END;
$function$
